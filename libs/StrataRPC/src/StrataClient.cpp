#include "ClientConnector.h"
#include "Dispatcher.h"
#include "RequestsController.h"
#include "logging/LoggingQtCategories.h"

#include <StrataRPC/Message.h>
#include <StrataRPC/StrataClient.h>
#include <QJsonDocument>

using namespace strata::strataRPC;

StrataClient::StrataClient(QString serverAddress, QObject *parent)
    : QObject(parent),
      dispatcher_(new Dispatcher<const QJsonObject &>()),
      connector_(new ClientConnector(serverAddress)),
      requestController_(new RequestsController()),
      connectorThread_(new QThread())
{
    connectorSetup();
}

StrataClient::StrataClient(QString serverAddress, QByteArray dealerId, QObject *parent)
    : QObject(parent),
      dispatcher_(new Dispatcher<const QJsonObject &>()),
      connector_(new ClientConnector(serverAddress, dealerId)),
      requestController_(new RequestsController()),
      connectorThread_(new QThread())
{
    connectorSetup();
}

StrataClient::~StrataClient()
{
    connector_->deleteLater();
    connector_.release();

    connectorThread_->exit(0);
    if (false == connectorThread_->wait(500)) {
        qCCritical(logCategoryStrataClient) << "Terminating connector thread.";
        connectorThread_->terminate();
    }
    connectorThread_->deleteLater();
}

void StrataClient::connectorSetup()
{
    connector_->moveToThread(connectorThread_);

    connect(this, &StrataClient::initializeConnector, connector_.get(),
            &ClientConnector::initializeConnector);
    connect(this, &StrataClient::connectClient, connector_.get(), &ClientConnector::connectClient);
    connect(this, &StrataClient::disconnectClient, connector_.get(),
            &ClientConnector::disconnectClient);
    connect(this, &StrataClient::sendMessage, connector_.get(), &ClientConnector::sendMessage);
    connect(connector_.get(), &ClientConnector::newMessageReceived, this,
            &StrataClient::newServerMessage);
    connect(this, &StrataClient::newServerMessageParsed, this, &StrataClient::dispatchHandler);
    connect(connector_.get(), &ClientConnector::errorOccurred, this,
            &StrataClient::connectorErrorHandler);

    connectorThread_->start();
}

bool StrataClient::connectServer()
{
    // this might duplicate signal/slot connection!
    connect(connector_.get(), &ClientConnector::clientInitialized, this, [this]() {
        auto deferredRequest = sendRequest("register_client", {{"api_version", "2.0"}});

        if (deferredRequest != nullptr) {
            connect(deferredRequest, &DeferredRequest::finishedSuccessfully, this,
                    [this](const QJsonObject &) {
                        qCInfo(logCategoryStrataClient)
                            << "Client connected successfully to the server.";
                        emit clientConnected();
                    });

            connect(deferredRequest, &DeferredRequest::finishedWithError, this,
                    [this](const QJsonObject &) {
                        QString errorMessage(QStringLiteral("Failed to connect to the server."));
                        qCCritical(logCategoryStrataClient) << errorMessage;
                        emit errorOccurred(ClientError::FailedToConnect, errorMessage);
                    });
        }
    });

    connect(connector_.get(), &ClientConnector::errorOccurred, this, [this]() {
        QString errorMessage(QStringLiteral("Failed to connect to the server."));
        qCCritical(logCategoryStrataClient) << errorMessage;
        emit errorOccurred(ClientError::FailedToConnect, errorMessage);
    });

    emit initializeConnector();
    return true;
}

bool StrataClient::disconnectServer()
{
    // we might need to sunchornize this, to make sure that the message is sent before closing the socket.
    sendRequest("unregister", {});
    emit disconnectClient();

    return true;
}

void StrataClient::newServerMessage(const QByteArray &jsonServerMessage)
{
    qCDebug(logCategoryStrataClient) << "New message from the server:" << jsonServerMessage;

    Message serverMessage;
    DeferredRequest *deferredRequest = nullptr;

    if (false == buildServerMessage(jsonServerMessage, &serverMessage, &deferredRequest)) {
        QString errorMessage(QStringLiteral("Failed to build server message."));
        qCCritical(logCategoryStrataClient) << errorMessage;
        emit errorOccurred(ClientError::FailedToBuildServerMessage, errorMessage);
        return;
    }

    if (deferredRequest != nullptr) {
        deferredRequest->stopTimer();
        if (serverMessage.messageType == Message::MessageType::Error) {
            qCDebug(logCategoryStrataClient) << "Dispatching error callback.";
            deferredRequest->callErrorCallback(serverMessage.payload);
        } else if (serverMessage.messageType == Message::MessageType::Response) {
            qCDebug(logCategoryStrataClient) << "Dispatching success callback.";
            deferredRequest->callSuccessCallback(serverMessage.payload);
        }
        deferredRequest->deleteLater();
        return;
    }

    qCDebug(logCategoryStrataClient) << "Dispatching registered handler.";
    emit newServerMessageParsed(serverMessage);
}

bool StrataClient::registerHandler(const QString &handlerName, ClientHandler handler)
{
    qCDebug(logCategoryStrataClient) << "Registering Handler:" << handlerName;
    if (false == dispatcher_->registerHandler(handlerName, handler)) {
        QString errorMessage(QStringLiteral("Failed to register handler."));
        qCCritical(logCategoryStrataClient) << errorMessage;
        emit errorOccurred(ClientError::FailedToRegisterHandler, errorMessage);
        return false;
    }
    return true;
}

bool StrataClient::unregisterHandler(const QString &handlerName)
{
    qCDebug(logCategoryStrataClient) << "Unregistering handler:" << handlerName;
    if (false == dispatcher_->unregisterHandler(handlerName)) {
        QString errorMessage(QStringLiteral("Failed to unregister handler."));
        qCCritical(logCategoryStrataClient) << errorMessage;
        emit errorOccurred(ClientError::FailedToUnregisterHandler, errorMessage);
        return false;
    }
    return true;
}

DeferredRequest *StrataClient::sendRequest(const QString &method, const QJsonObject &payload)
{
    // find a way to return nullptr for the deferred request if we fail!
    const auto [deferredRequest, message] = requestController_->addNewRequest(method, payload);

    if (true == message.isEmpty()) {
        QString errorMessage(QStringLiteral("Failed to add request."));
        qCCritical(logCategoryStrataClient) << errorMessage;
        emit errorOccurred(ClientError::FailedToAddReequest, errorMessage);
        return nullptr;
    }

    emit sendMessage(message);
    // if (false == connector_->sendMessage(message)) {
    //     QString errorMessage(QStringLiteral("Failed to send request."));
    //     qCCritical(logCategoryStrataClient) << errorMessage;
    //     emit errorOccurred(ClientError::FailedToSendRequest, errorMessage);
    //     return nullptr;
    // }

    connect(deferredRequest, &DeferredRequest::requestTimedout, this,
            &StrataClient::requestTimeoutHandler);
    deferredRequest->startTimer();

    return deferredRequest;
}

bool StrataClient::sendNotification(const QString &method, const QJsonObject &payload)
{
    qCDebug(logCategoryStrataClient) << "Sending notification to the server";
    QJsonObject jsonObject{{"jsonrpc", "2.0"}, {"method", method}, {"params", payload}, {"id", 0}};

    emit sendMessage(QJsonDocument(jsonObject).toJson(QJsonDocument::JsonFormat::Compact));
    // if (false == connector_->sendMessage(
    //                  QJsonDocument(jsonObject).toJson(QJsonDocument::JsonFormat::Compact))) {
    //     QString errorMessage(QStringLiteral("Failed notification to the server."));
    //     qCCritical(logCategoryStrataClient) << errorMessage;
    //     emit errorOccurred(ClientError::FailedToSendNotification, errorMessage);
    //     return false;
    // }

    return true;
}

bool StrataClient::buildServerMessage(const QByteArray &jsonServerMessage, Message *serverMessage,
                                      DeferredRequest **deferredRequest)
{
    QJsonParseError jsonParseError;
    QJsonDocument jsonDocument = QJsonDocument::fromJson(jsonServerMessage, &jsonParseError);

    serverMessage->clientID = "";
    serverMessage->messageID = 0;

    if (jsonParseError.error != QJsonParseError::NoError) {
        QString errorMessage(QStringLiteral("invalid JSON message."));
        qCCritical(logCategoryStrataServer) << errorMessage;
        emit errorOccurred(ClientError::FailedToBuildServerMessage, errorMessage);
        return false;
    }
    QJsonObject jsonObject = jsonDocument.object();

    if (true == jsonObject.contains("jsonrpc") && true == jsonObject.value("jsonrpc").isString() &&
        jsonObject.value("jsonrpc").toString() == "2.0") {
        qCDebug(logCategoryStrataClient) << "API v2.0";
    } else {
        QString errorMessage(QStringLiteral("Invalid API."));
        qCCritical(logCategoryStrataClient) << errorMessage;
        emit errorOccurred(ClientError::FailedToBuildServerMessage, errorMessage);
        return false;
    }

    // Possible message types

    // Response
    // {
    //     "jsonrpc": "2.0",
    //     "result": {},
    //     "id": 1
    // }

    // Error
    // {
    //     "jsonrpc": "2.0",
    //     "error": {},
    //     "id": "1"
    // }

    // Notification
    // {
    //     "jsonrpc": "2.0",
    //     "method":"Handler Name",
    //     "params": {}
    // }

    // Notification
    // {
    //     "jsonrpc": "2.0",
    //     "method": "platform_notification",
    //     "params": {}
    // }

    if (true == jsonObject.contains("id") && true == jsonObject.value("id").isDouble()) {
        serverMessage->messageID = jsonObject.value("id").toDouble();
        auto [requestFound, request] =
            requestController_->popPendingRequest(jsonObject.value("id").toDouble());

        if (false == requestFound || request.method_ == "") {
            QString errorMessage(QStringLiteral("Pending Request not found."));
            qCCritical(logCategoryStrataClient) << errorMessage;
            emit errorOccurred(ClientError::PendingRequestNotFound, errorMessage);
            return false;
        }

        serverMessage->handlerName = request.method_;
        *deferredRequest = request.deferredRequest_;

        if (true == jsonObject.contains("error") && true == jsonObject.value("error").isObject()) {
            serverMessage->payload = jsonObject.value("error").toObject();
            serverMessage->messageType = Message::MessageType::Error;
        } else {
            if (true == jsonObject.contains("result") &&
                true == jsonObject.value("result").isObject()) {
                serverMessage->payload = jsonObject.value("result").toObject();
            } else {
                qCDebug(logCategoryStrataClient) << "No payload.";
                serverMessage->payload = QJsonObject{};
            }
            serverMessage->messageType = Message::MessageType::Response;
        }

    } else if (true == jsonObject.contains("method") &&
               true == jsonObject.value("method").isString()) {
        serverMessage->handlerName = jsonObject.value("method").toString();
        serverMessage->messageType = Message::MessageType::Notification;

        if (true == jsonObject.contains("params") &&
            true == jsonObject.value("params").isObject()) {
            serverMessage->payload = jsonObject.value("params").toObject();
        }

    } else {
        QString errorMessage(QStringLiteral("Invalid API."));
        qCCritical(logCategoryStrataClient) << errorMessage;
        emit errorOccurred(ClientError::FailedToBuildServerMessage, errorMessage);
        return false;
    }

    return true;
}

void StrataClient::requestTimeoutHandler(int requestId)
{
    QString timeoutErrorMessage("Request timed out. request ID: " + QString::number(requestId));
    qCCritical(logCategoryStrataClient) << timeoutErrorMessage;
    emit errorOccurred(ClientError::RequestTimeout, timeoutErrorMessage);

    auto [requestFound, request] = requestController_->popPendingRequest(requestId);
    if (false == requestFound && request.deferredRequest_ == nullptr) {
        QString requestNotFoundErrorMessage(QStringLiteral("Failed to remove timed out request."));
        qCCritical(logCategoryStrataClient) << requestNotFoundErrorMessage;
        emit errorOccurred(ClientError::PendingRequestNotFound, requestNotFoundErrorMessage);
        return;
    }

    qCDebug(logCategoryStrataClient) << "Dispatching error callback.";
    request.deferredRequest_->callErrorCallback(QJsonObject({{"message", "Request timed out."}}));

    request.deferredRequest_->deleteLater();
    qCDebug(logCategoryStrataClient) << "Timed out request removed successfully.";
}

void StrataClient::dispatchHandler(const Message &serverMessage)
{
    if (false == dispatcher_->dispatch(serverMessage.handlerName, serverMessage.payload)) {
        QString errorMessage(QStringLiteral("Handler not found."));
        emit errorOccurred(ClientError::HandlerNotFound, errorMessage);
        return;
    }

    qCDebug(logCategoryStrataClient) << "Handler executed.";
}

void StrataClient::connectorErrorHandler(ClientConnectorError errorType,
                                         const QString &errorMessage)
{
    switch (errorType) {
        case ClientConnectorError::FailedToInitialize:
            // log and handle the error here!
            // QString errorMessage(QStringLiteral("Failed to connect to the server."));
            qCCritical(logCategoryStrataClient) << errorMessage;
            emit errorOccurred(ClientError::FailedToConnect, errorMessage);
            break;
        case ClientConnectorError::FailedToConnect:
            // log and handle the error here!
            // QString errorMessage(QStringLiteral("Failed to connect to the server."));
            qCCritical(logCategoryStrataClient) << errorMessage;
            emit errorOccurred(ClientError::FailedToConnect, errorMessage);
            break;
        case ClientConnectorError::FailedToDisconnect:
            // log and handle the error here!
            qCCritical(logCategoryStrataClient) << errorMessage;
            emit errorOccurred(ClientError::FailedToDisconnect, errorMessage);
            break;
        case ClientConnectorError::FailedToSend:
            // log and handle the error here!
            qCCritical(logCategoryStrataClient) << errorMessage;
            emit errorOccurred(ClientError::FailedToSendRequest, errorMessage);
            break;
    }
}