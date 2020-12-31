#include "StrataClient.h"
#include "logging/LoggingQtCategories.h"

#include <QJsonDocument>

#include "Request.h"

using namespace strata::strataComm;

StrataClient::StrataClient(QString serverAddress, QObject *parent)
    : QObject(parent), dispatcher_(this), connector_(serverAddress)
{
}

StrataClient::StrataClient(QString serverAddress, QByteArray dealerId, QObject *parent)
    : QObject(parent), dispatcher_(this), connector_(serverAddress, dealerId)
{
}

StrataClient::~StrataClient()
{
}

bool StrataClient::connectServer()
{
    if (false == connector_.initilize()) {
        qCCritical(logCategoryStrataClient) << "Failed to connect to the server";
        return false;
    }

    connect(&connector_, &ClientConnector::newMessageRecived, this,
            &StrataClient::newServerMessage);
    connect(this, &StrataClient::dispatchHandler, &dispatcher_, &Dispatcher::dispatchHandler);

    sendRequest("register_client", {{"api_version", "1.0"}});

    return true;
}

bool StrataClient::disconnectServer()
{
    qCDebug(logCategoryStrataClient) << "Disconnecting client";

    sendRequest("unregister", {});
    disconnect(&connector_, &ClientConnector::newMessageRecived, this,
               &StrataClient::newServerMessage);

    if (false == connector_.disconnectClient()) {
        qCCritical(logCategoryStrataClient) << "Failed to disconnect client";
        return false;
    }

    return true;
}

void StrataClient::newServerMessage(const QByteArray &jsonServerMessage)
{
    qCDebug(logCategoryStrataClient) << "New message from the server:" << jsonServerMessage;

    // parse the message.
    Message serverMessage;
    if (false == buildServerMessage(jsonServerMessage, &serverMessage)) {
        qCCritical(logCategoryStrataClient) << "Failed to build server message.";
        return;
    }

    qCDebug(logCategoryStrataClient) << "#########################################";
    qCDebug(logCategoryStrataClient) << "message:" << jsonServerMessage;
    qCDebug(logCategoryStrataClient) << "message id:" << serverMessage.messageID;
    qCDebug(logCategoryStrataClient) << "method:" << serverMessage.handlerName;
    qCDebug(logCategoryStrataClient) << "payload:" << serverMessage.payload;
    qCDebug(logCategoryStrataClient) << "message type:" << static_cast<int>(serverMessage.messageType);
    qCDebug(logCategoryStrataClient) << "#########################################";

    emit dispatchHandler(serverMessage);
}

bool StrataClient::registerHandler(const QString &handlerName, StrataHandler handler)
{
    qCDebug(logCategoryStrataClient) << "Registering Handler:" << handlerName;
    if (false == dispatcher_.registerHandler(handlerName, handler)) {
        qCCritical(logCategoryStrataClient) << "Failed to register handler.";
        return false;
    }
    return true;
}

bool StrataClient::unregisterHandler(const QString &handlerName)
{
    qCDebug(logCategoryStrataClient) << "Unregistering handler:" << handlerName;
    if (false == dispatcher_.unregisterHandler(handlerName)) {  // always return true.
        qCCritical(logCategoryStrataClient) << "Failed to unregister handler.";
        return false;
    }
    return true;
}

bool StrataClient::sendRequest(const QString &method, const QJsonObject &payload)
{
    qCDebug(logCategoryStrataClient) << "building request: " << method;

    auto message = requestController_.addNewRequest(method, payload);

    if (true == message.isEmpty()) {
        qCCritical(logCategoryStrataClient) << "Failed to add request.";
        return false;
    }

    return connector_.sendMessage(message);
}

bool StrataClient::buildServerMessage(const QByteArray &jsonServerMessage, Message *serverMessage)
{
    QJsonParseError jsonParseError;
    QJsonDocument jsonDocument = QJsonDocument::fromJson(jsonServerMessage, &jsonParseError);

    if (jsonParseError.error != QJsonParseError::NoError) {
        qCDebug(logCategoryStrataServer) << "invalid JSON message.";
        return false;
    }
    QJsonObject jsonObject = jsonDocument.object();

    if (true == jsonObject.contains("jsonrpc") && true == jsonObject.value("jsonrpc").isString() &&
        jsonObject.value("jsonrpc").toString() == "2.0") {
        qCDebug(logCategoryStrataClient) << "API v2.0";
    } else {
        qCDebug(logCategoryStrataClient) << "Invalid API.";
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
    //     "params": { }
    // }

    if (true == jsonObject.contains("id") && true == jsonObject.value("id").isDouble()) {
        serverMessage->messageID = jsonObject.value("id").toDouble();

        // Get the handler name from the request controller based on the message id 
        if (QString handlerName =
                requestController_.getMethodName(jsonObject.value("id").toDouble());
            false == handlerName.isEmpty()) {
            serverMessage->handlerName = handlerName;
        } else {
            qCritical(logCategoryStrataClient) << "Failed to get handler name.";
            return false;
        }

        if (false == requestController_.removePendingRequest(jsonObject.value("id").toDouble())) {
            qCCritical(logCategoryStrataClient) << "Failed to remove pending request.";
            return false;
        }

        if (true == jsonObject.contains("result") &&
            true == jsonObject.value("result").isObject()) {
            serverMessage->payload = jsonObject.value("result").toObject();
            serverMessage->messageType = Message::MessageType::Response;
        } else if (true == jsonObject.contains("error") &&
                   true == jsonObject.value("error").isObject()) {
            serverMessage->payload = jsonObject.value("error").toObject();
            serverMessage->messageType = Message::MessageType::Error;
        } else {
            qCDebug(logCategoryStrataClient) << "No payload.";
            serverMessage->payload = QJsonObject{};
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
        qCritical(logCategoryStrataClient) << "Invalid API.";
        return false;
    }

    serverMessage->clientID = "";
    return true;
}
