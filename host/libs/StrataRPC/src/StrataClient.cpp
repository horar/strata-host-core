#include "ClientConnector.h"
#include "Dispatcher.h"
#include "RequestsController.h"
#include "logging/LoggingQtCategories.h"

#include <StrataRPC/StrataClient.h>
#include <QJsonDocument>

using namespace strata::strataRPC;

StrataClient::StrataClient(QString serverAddress, QObject *parent)
    : QObject(parent),
      dispatcher_(new Dispatcher(this)),
      connector_(new ClientConnector(serverAddress)),
      requestController_(new RequestsController())
{
}

StrataClient::StrataClient(QString serverAddress, QByteArray dealerId, QObject *parent)
    : QObject(parent),
      dispatcher_(new Dispatcher(this)),
      connector_(new ClientConnector(serverAddress, dealerId)),
      requestController_(new RequestsController())
{
}

StrataClient::~StrataClient()
{
}

bool StrataClient::connectServer()
{
    if (false == connector_->initializeConnector()) {
        qCCritical(logCategoryStrataClient) << "Failed to connect to the server";
        return false;
    }

    connect(connector_.get(), &ClientConnector::newMessageReceived, this,
            &StrataClient::newServerMessage);
    connect(this, &StrataClient::newServerMessageParsed, dispatcher_.get(),
            &Dispatcher::dispatchHandler);

    sendRequest("register_client", {{"api_version", "2.0"}});

    return true;
}

bool StrataClient::disconnectServer()
{
    sendRequest("unregister", {});
    disconnect(connector_.get(), &ClientConnector::newMessageReceived, this,
               &StrataClient::newServerMessage);

    if (false == connector_->disconnectClient()) {
        qCCritical(logCategoryStrataClient) << "Failed to disconnect client";
        return false;
    }

    return true;
}

void StrataClient::newServerMessage(const QByteArray &jsonServerMessage)
{
    qCDebug(logCategoryStrataClient) << "New message from the server:" << jsonServerMessage;

    Message serverMessage;
    StrataHandler callbackHandler = nullptr;

    if (false == buildServerMessage(jsonServerMessage, &serverMessage, callbackHandler)) {
        qCCritical(logCategoryStrataClient) << "Failed to build server message.";
        return;
    }

    if (callbackHandler) {
        qCDebug(logCategoryStrataClient) << "Dispatching request callback.";
        callbackHandler(serverMessage);
    } else {
        qCDebug(logCategoryStrataClient) << "Dispatching registered handler.";
        emit newServerMessageParsed(serverMessage);
    }
}

bool StrataClient::registerHandler(const QString &handlerName, StrataHandler handler)
{
    qCDebug(logCategoryStrataClient) << "Registering Handler:" << handlerName;
    if (false == dispatcher_->registerHandler(handlerName, handler)) {
        qCCritical(logCategoryStrataClient) << "Failed to register handler.";
        return false;
    }
    return true;
}

bool StrataClient::unregisterHandler(const QString &handlerName)
{
    qCDebug(logCategoryStrataClient) << "Unregistering handler:" << handlerName;
    if (false == dispatcher_->unregisterHandler(handlerName)) {
        qCCritical(logCategoryStrataClient) << "Failed to unregister handler.";
        return false;
    }
    return true;
}

std::pair<bool, int> StrataClient::sendRequest(const QString &method, const QJsonObject &payload,
                                               StrataHandler errorCallback,
                                               StrataHandler resultCallback)
{
    const auto [pendingRequest, message] =
        requestController_->addNewRequest(method, payload, errorCallback, resultCallback);

    if (true == message.isEmpty()) {
        qCCritical(logCategoryStrataClient) << "Failed to add request.";
        return {false, 0};
    }

    return {connector_->sendMessage(message), pendingRequest->getId()};
}

bool StrataClient::buildServerMessage(const QByteArray &jsonServerMessage, Message *serverMessage,
                                      StrataHandler &callbackHandler)
{
    QJsonParseError jsonParseError;
    QJsonDocument jsonDocument = QJsonDocument::fromJson(jsonServerMessage, &jsonParseError);

    serverMessage->clientID = "";
    serverMessage->messageID = 0;

    if (jsonParseError.error != QJsonParseError::NoError) {
        qCCritical(logCategoryStrataServer) << "invalid JSON message.";
        return false;
    }
    QJsonObject jsonObject = jsonDocument.object();

    if (true == jsonObject.contains("jsonrpc") && true == jsonObject.value("jsonrpc").isString() &&
        jsonObject.value("jsonrpc").toString() == "2.0") {
        qCDebug(logCategoryStrataClient) << "API v2.0";
    } else {
        qCCritical(logCategoryStrataClient) << "Invalid API.";
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
        const auto [requestFound, request] =
            requestController_->popPendingRequest(jsonObject.value("id").toDouble());

        if (false == requestFound || request.method_ == "") {
            qCritical(logCategoryStrataClient) << "Failed to pop pending request.";
            return false;
        }

        serverMessage->handlerName = request.method_;

        if (true == jsonObject.contains("error") && true == jsonObject.value("error").isObject()) {
            serverMessage->payload = jsonObject.value("error").toObject();
            serverMessage->messageType = Message::MessageType::Error;
            if (request.errorCallback_) {
                qCDebug(logCategoryStrataClient) << "Error callback is set.";
                callbackHandler = request.errorCallback_;
            }
        } else {
            if (true == jsonObject.contains("result") &&
                true == jsonObject.value("result").isObject()) {
                serverMessage->payload = jsonObject.value("result").toObject();
            } else {
                qCDebug(logCategoryStrataClient) << "No payload.";
                serverMessage->payload = QJsonObject{};
            }
            serverMessage->messageType = Message::MessageType::Response;
            if (request.resultCallback_) {
                qCDebug(logCategoryStrataClient) << "Response callback is set.";
                callbackHandler = request.resultCallback_;
            }
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
        qCritical(logCategoryStrataClient) << "Invalid API.";
        return false;
    }

    return true;
}
