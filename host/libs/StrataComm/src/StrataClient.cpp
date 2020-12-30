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

void StrataClient::newServerMessage(const QByteArray &serverMessage)
{
    qCDebug(logCategoryStrataClient) << "New message from the server:" << serverMessage;

    // parse the message.
    Message message;
    if (false == buildServerMessage(serverMessage, &message)) {
        qCCritical(logCategoryStrataClient) << "Failed to build server message.";
        return;
    }

    qCDebug(logCategoryStrataClient) << "#########################################";
    qCDebug(logCategoryStrataClient) << "message:" << serverMessage;
    qCDebug(logCategoryStrataClient) << "message id:" << message.messageID;
    qCDebug(logCategoryStrataClient) << "method:" << message.handlerName;
    qCDebug(logCategoryStrataClient) << "payload:" << message.payload;
    qCDebug(logCategoryStrataClient) << "message type:" << static_cast<int>(message.messageType);
    qCDebug(logCategoryStrataClient) << "#########################################";

    emit dispatchHandler(message);
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

bool StrataClient::buildServerMessage(const QByteArray &serverMessage, Message *clientMessage)
{
    // Parse the message
    QJsonParseError jsonParseError;
    QJsonDocument jsonDocument = QJsonDocument::fromJson(serverMessage, &jsonParseError);

    if (jsonParseError.error != QJsonParseError::NoError) {
        qCDebug(logCategoryStrataServer) << "invalid JSON message.";
        return false;
    }
    QJsonObject jsonObject = jsonDocument.object();

    // Is it valid API?
    if (true == jsonObject.contains("jsonrpc") && true == jsonObject.value("jsonrpc").isString() &&
        jsonObject.value("jsonrpc").toString() == "2.0") {
        qCDebug(logCategoryStrataClient) << "API v2.0";
    } else {
        qCDebug(logCategoryStrataClient) << "Invalid API.";
        return false;
    }

    // Type? Response, Notification, Error?
    // outline -->

    // {
    //     "jsonrpc": "2.0",
    //     "result": {},
    //     "id": 1
    // }

    // {
    //     "jsonrpc": "2.0",
    //     "error": {},
    //     "id": "1"
    // }

    // {
    //     "jsonrpc": "2.0",
    //     "method":"Handler Name",
    //     "params": {}
    // }

    // {
    //     "jsonrpc": "2.0",
    //     "method": "platform_notification",
    //     "params": { }
    // }

    // check if the message has an id
    if (true == jsonObject.contains("id") && true == jsonObject.value("id").isDouble()) {
        clientMessage->messageID = jsonObject.value("id").toDouble();
        clientMessage->messageType = MessageType::Command;

        if (QString handlerName =
                requestController_.getMethodName(jsonObject.value("id").toDouble());
            false == handlerName.isEmpty()) {
            clientMessage->handlerName = handlerName;
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
            clientMessage->payload = jsonObject.value("result").toObject();
        } else if (true == jsonObject.contains("error") &&
                   true == jsonObject.value("error").isObject()) {
            clientMessage->payload = jsonObject.value("error").toObject();
        } else {
            qCDebug(logCategoryStrataClient) << "No payload.";
            clientMessage->payload = QJsonObject{};
        }

    } else if (true == jsonObject.contains("method") &&
               true == jsonObject.value("method").isString()) {
        clientMessage->handlerName = jsonObject.value("method").toString();

        if (true == jsonObject.contains("params") &&
            true == jsonObject.value("params").isObject()) {
            clientMessage->payload = jsonObject.value("params").toObject();
            clientMessage->messageType = MessageType::Notifiation;
        }

    } else {
        qCritical(logCategoryStrataClient) << "Invalid API.";
        return false;
    }

    return true;
}
