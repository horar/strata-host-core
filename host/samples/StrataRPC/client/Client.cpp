#include "Client.h"
#include "logging/LoggingQtCategories.h"

#include <QJsonObject>

using namespace strata::strataRPC;

Client::Client(QString clientId, QObject *parent)
    : QObject(parent),
      strataClient_(new StrataClient(address_, clientId.toUtf8())),
      connectionStatus_(false)
{
    qCInfo(logCategoryStrataClientSample).nospace().noquote()
        << "Client ID 0x" << clientId.toUtf8().toHex();

    connect(strataClient_.get(), &StrataClient::clientConnected, this, [this]() {
        connectionStatus_ = true;
        emit connectionStatusUpdated();
    });

    connect(strataClient_.get(), &StrataClient::errorOccurred, this,
            &Client::strataClientErrorHandler);
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

bool Client::getConnectionStatus()
{
    return connectionStatus_;
}

void Client::connectToServer()
{
    qCDebug(logCategoryStrataClientSample) << "gui connecting";
    strataClient_->connectServer();
}

void Client::disconnectServer()
{
    qCDebug(logCategoryStrataClientSample) << "gui disconnecting";
    if (true == strataClient_->disconnectServer()) {
        connectionStatus_ = false;
        emit connectionStatusUpdated();
    }
}

void Client::closeServer()
{
    auto deferredRequest = strataClient_->sendRequest("close_server", QJsonObject{{}});

    if (deferredRequest == nullptr) {
        qCCritical(logCategoryStrataClientSample) << "Failed To send unregister_client request.";
        return;
    }

    connect(deferredRequest, &DeferredRequest::finishedSuccessfully, this,
            [](const QJsonObject &) { qCInfo(logCategoryStrataClientSample) << "server closed"; });
}

void Client::requestServerStatus()
{
    auto deferredRequest = strataClient_->sendRequest("server_status", QJsonObject{{}});

    if (deferredRequest == nullptr) {
        qCCritical(logCategoryStrataClientSample) << "Failed To send server_status request.";
        return;
    }

    connect(deferredRequest, &DeferredRequest::finishedSuccessfully, this, [](const QJsonObject &) {
        qCInfo(logCategoryStrataClientSample) << "Server is alive.";
    });

    connect(deferredRequest, &DeferredRequest::finishedWithError, this,
            &Client::serverDisconnectedHandler);
}

void Client::serverDisconnectedHandler(const QJsonObject &)
{
    disconnectServer();
}

void Client::strataClientErrorHandler(StrataClient::ClientError errorType,
                                      const QString &errorMessage)
{
    qCCritical(logCategoryStrataClientSample) << "Client Error:" << errorType << "Message:" << errorMessage;
}
