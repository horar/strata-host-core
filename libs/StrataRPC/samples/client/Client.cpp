#include "Client.h"
#include "logging/LoggingQtCategories.h"

#include <QElapsedTimer>
#include <QJsonArray>
#include <QJsonObject>
#include <QList>

using namespace strata::strataRPC;

Client::Client(QString clientId, QObject *parent)
    : QObject(parent),
      strataClient_(new StrataClient(address_, clientId.toUtf8())),
      connectionStatus_(false),
      serverTime_()
{
    qCInfo(logCategoryStrataClientSample).nospace().noquote()
        << "ClientID 0x" << clientId.toUtf8().toHex();

    connect(strataClient_.get(), &StrataClient::connected, this, [this]() {
        connectionStatus_ = true;
        emit connectionStatusUpdated();
    });

    connect(strataClient_.get(), &StrataClient::disconnected, this, [this]() {
        connectionStatus_ = false;
        emit connectionStatusUpdated();
    });

    connect(strataClient_.get(), &StrataClient::errorOccurred, this,
            &Client::strataClientErrorHandler);

    strataClient_->registerHandler(
        "server_time", std::bind(&Client::serverTimeHandler, this, std::placeholders::_1));

    strataClient_->registerHandler(
        "generate_graph", std::bind(&Client::randomGraphHandler, this, std::placeholders::_1));
}

Client::~Client()
{
}

bool Client::init()
{
    return true;
}

void Client::start()
{
}

bool Client::getConnectionStatus() const
{
    return connectionStatus_;
}

QString Client::getServerTime() const
{
    return serverTime_;
}

void Client::connectToServer()
{
    qCDebug(logCategoryStrataClientSample) << "Connecting to the server.";
    strataClient_->connect();
}

void Client::disconnectServer()
{
    qCDebug(logCategoryStrataClientSample) << "Disconnecting from the server.";
    strataClient_->disconnect();
}

void Client::closeServer()
{
    auto deferredRequest = strataClient_->sendRequest("close_server", QJsonObject());

    if (deferredRequest == nullptr) {
        qCCritical(logCategoryStrataClientSample) << "Failed To send unregister_client request.";
        return;
    }

    connect(deferredRequest, &DeferredRequest::finishedSuccessfully, this, [](const QJsonObject &) {
        qCInfo(logCategoryStrataClientSample) << "Server closed successfully.";
    });
}

void Client::requestRandomGraph()
{
    qCInfo(logCategoryStrataClientSample) << "Requesting random graph from the server.";
    auto deferredRequest = strataClient_->sendRequest("generate_graph", QJsonObject{{"size", 6}});

    if (deferredRequest == nullptr) {
        qCCritical(logCategoryStrataClientSample) << "Failed To send generate_graph request.";
        return;
    }

    connect(deferredRequest, &DeferredRequest::finishedSuccessfully, this, [](const QJsonObject &) {
        qCInfo(logCategoryStrataClientSample) << "Server is generating graph.";
    });

    connect(deferredRequest, &DeferredRequest::finishedWithError, this, [](const QJsonObject &) {
        qCCritical(logCategoryStrataClientSample) << "Failed to request graph from the server.";
    });
}

void Client::requestServerStatus()
{
    auto deferredRequest = strataClient_->sendRequest("server_status", QJsonObject());

    if (deferredRequest == nullptr) {
        qCCritical(logCategoryStrataClientSample) << "Failed To send server_status request.";
        return;
    }

    connect(deferredRequest, &DeferredRequest::finishedSuccessfully, this,
            [this](const QJsonObject &) {
                qCInfo(logCategoryStrataClientSample) << "Server is alive.";
                connectionStatus_ = true;
                emit connectionStatusUpdated();
            });

    connect(deferredRequest, &DeferredRequest::finishedWithError, this,
            &Client::serverDisconnectedHandler);
}

void Client::pingServer()
{
    QElapsedTimer *elapsedTimer = new QElapsedTimer();
    elapsedTimer->start();

    auto deferredRequest = strataClient_->sendRequest("ping", QJsonObject());

    if (deferredRequest == nullptr) {
        qCCritical(logCategoryStrataClientSample) << "Failed to send ping request.";
        delete elapsedTimer;
        return;
    }

    connect(deferredRequest, &DeferredRequest::finishedSuccessfully, this,
            [this, elapsedTimer](const QJsonObject &) {
                auto serverDelay = elapsedTimer->elapsed();
                qCDebug(logCategoryStrataClientSample) << "Server Delay:" << serverDelay << "ms.";
                emit serverDelayUpdated(serverDelay);
                delete elapsedTimer;
            });

    connect(deferredRequest, &DeferredRequest::finishedWithError, this,
            [this, elapsedTimer](const QJsonObject &) {
                qCCritical(logCategoryStrataClientSample) << "Failed to get server delay.";
                emit serverDelayUpdated(-1);
                delete elapsedTimer;
            });
}

void Client::serverDisconnectedHandler(const QJsonObject &)
{
    disconnectServer();
}

void Client::strataClientErrorHandler(StrataClient::ClientError errorType,
                                      const QString &errorMessage)
{
    qCCritical(logCategoryStrataClientSample)
        << "Client Error:" << errorType << "Message:" << errorMessage;
    emit errorOccurred(errorMessage);
}

void Client::serverTimeHandler(const QJsonObject &payload)
{
    serverTime_ = payload["time"].toString();
    emit serverTimeUpdated();
}

void Client::randomGraphHandler(const QJsonObject &payload)
{
    QList<int> randomNumbersList;
    QJsonArray jsonArray = payload.value("list").toArray();

    for (const auto num : jsonArray) {
        randomNumbersList.append(num.toInt());
    }

    emit randomGraphUpdated(randomNumbersList);
}
