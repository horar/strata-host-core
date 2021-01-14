#include "StrataServer.h"
#include "logging/LoggingQtCategories.h"

#include <QJsonDocument>

using namespace strata::strataRPC;

StrataServer::StrataServer(QString address, QObject *parent)
    : QObject(parent), dispatcher_(this), clientsController_(this), connector_(address, this)
{
}

StrataServer::~StrataServer()
{
}

bool StrataServer::initializeServer()
{
    if (true == connector_.initilizeConnector()) {
        qCInfo(logCategoryStrataServer) << "Strata Server initialized successfully.";
        connect(&connector_, &ServerConnector::newMessageReceived, this,
                &StrataServer::newClientMessage);
        connect(this, &StrataServer::newClientMessageParsed, &dispatcher_, &Dispatcher::dispatchHandler);
        return true;
    } else {
        qCCritical(logCategoryStrataServer) << "Failed to initialize Strata Server.";
        return false;
    }
}

bool StrataServer::registerHandler(const QString &handlerName, StrataHandler handler)
{
    if (false == dispatcher_.registerHandler(handlerName, handler)) {
        qCCritical(logCategoryStrataServer) << "Failed to register handler";
        return false;
    }
    return true;
}

bool StrataServer::unregisterHandler(const QString &handlerName)
{
    if (false == dispatcher_.unregisterHandler(handlerName)) {
        qCCritical(logCategoryStrataServer) << "Failed to unregister handler";
        return false;
    }
    return true;
}

void StrataServer::newClientMessage(const QByteArray &clientId, const QByteArray &message)
{
    qCDebug(logCategoryStrataServer) << "StrataServer newClientMessage"
                                     << "Client ID:" << clientId << "Message:" << message;

    QJsonParseError jsonParseError;
    QJsonDocument jsonDocument = QJsonDocument::fromJson(message, &jsonParseError);

    if (jsonParseError.error != QJsonParseError::NoError) {
        qCCritical(logCategoryStrataServer) << "invalid JSON message.";
        return;
    }
    QJsonObject jsonObject = jsonDocument.object();

    Message clientMessage;
    clientMessage.clientID = clientId;
    ApiVersion apiVersion;

    // Check if registered client
    if (false == clientsController_.isRegisteredClient(clientId)) {
        qCDebug(logCategoryStrataServer) << "client not registered";

        // Find out the client api version.
        if ((true == jsonObject.contains("jsonrpc"))) {
            if ((true == jsonObject.value("jsonrpc").isString()) &&
                (jsonObject.value("jsonrpc") == "2.0")) {
                apiVersion = ApiVersion::v2;
                qCDebug(logCategoryStrataServer) << "API v2";
            } else {
                apiVersion = ApiVersion::none;
                qCCritical(logCategoryStrataServer) << "Unknown API.";
                return;
            }
        } else {
            qCDebug(logCategoryStrataServer) << "API v1";
            apiVersion = ApiVersion::v1;
        }

        // Register the client.
        if (false == clientsController_.registerClient(Client(clientId, apiVersion))) {
            qCCritical(logCategoryStrataServer) << "Failed to register client";
            return;
        }

        qCInfo(logCategoryStrataServer) << "Client registered successfully";

    } else {
        // Returning client. get the api from the client controller.
        apiVersion = clientsController_.getClientApiVersion(clientId);
    }

    if (apiVersion == ApiVersion::v2) {
        if (false == buildClientMessageAPIv2(jsonObject, &clientMessage)) {
            return;
        }
    } else {
        if (false == buildClientMessageAPIv1(jsonObject, &clientMessage)) {
            return;
        }
    }

    emit newClientMessageParsed(clientMessage);
}

bool StrataServer::buildClientMessageAPIv2(const QJsonObject &jsonObject, Message *clientMessage)
{
    if (false == jsonObject.contains("jsonrpc") ||
        false == jsonObject.value("jsonrpc").isString() || jsonObject.value("jsonrpc") != "2.0") {
        qCCritical(logCategoryStrataServer) << "Invalid or missing API identifier.";
        return false;
    }

    // populate the handlerName -> method
    if ((true == jsonObject.contains("method")) && (jsonObject.value("method").isString())) {
        clientMessage->handlerName = jsonObject.value("method").toString();
    } else {
        qCCritical(logCategoryStrataServer) << "Failed to process handler name.";
        return false;
    }

    // populate the payload --> param
    if ((true == jsonObject.contains("params")) &&
        (true == jsonObject.value("params").isObject())) {
        clientMessage->payload = jsonObject.value("params").toObject();
    } else {
        qCCritical(logCategoryStrataServer) << "Failed to process message payload.";
        return false;
    }

    // populate messageID --> id
    if ((true == jsonObject.contains("id") && (true == jsonObject.value("id").isDouble()))) {
        clientMessage->messageID = jsonObject.value("id").toDouble();
    } else {
        qCCritical(logCategoryStrataServer) << "Failed to process message id.";
        return false;
    }

    // populate message type --> request.
    clientMessage->messageType = Message::MessageType::Command;
    return true;
}

bool StrataServer::buildClientMessageAPIv1(const QJsonObject &jsonObject, Message *clientMessage)
{
    bool isPlatformMessage = false;

    if ((true == jsonObject.contains("cmd")) && (true == jsonObject.value("cmd").isString())) {
        // Check if this command is meant to be sent to a platform
        if (true == jsonObject.contains("device_id") &&
            true == jsonObject.value("device_id").isDouble()) {
            clientMessage->handlerName = "platform_message";
            isPlatformMessage = true;
        } else {
            clientMessage->handlerName = jsonObject.value("cmd").toString();
        }
    } else if ((true == jsonObject.contains("hcs::cmd")) &&
               (true == jsonObject.value("hcs::cmd").isString())) {
        clientMessage->handlerName = jsonObject.value("hcs::cmd").toString();
    } else {
        qCCritical(logCategoryStrataServer) << "Failed to process handler name.";
        return false;
    }

    // documentation show messages with no payload are valid.
    bool hasPayload =
        (true == jsonObject.contains("payload")) && (jsonObject.value("payload").isObject());
    QJsonObject payloadJsonObject{};

    if (true == isPlatformMessage) {
        payloadJsonObject.insert("device_id", jsonObject.value("device_id").toDouble());
        QJsonObject messageJsonObject;
        messageJsonObject.insert("cmd", jsonObject.value("cmd"));
        if (true == hasPayload) {
            messageJsonObject.insert("payload", jsonObject.value("payload").toObject());
        } else {
            messageJsonObject.insert("payload", QJsonObject{});
        }
        payloadJsonObject.insert("message", messageJsonObject);
    } else {
        if (true == hasPayload) {
            payloadJsonObject = jsonObject.value("payload").toObject();
        }
    }

    clientMessage->payload = payloadJsonObject;
    clientMessage->messageID = 0;
    clientMessage->messageType = Message::MessageType::Command;

    return true;
}

void StrataServer::notifyClient(const Message &clientMessage, const QJsonObject &jsonObject,
                                ResponseType responseType)
{
    QByteArray serverMessage;

    switch (clientsController_.getClientApiVersion(clientMessage.clientID)) {
        case ApiVersion::v1:
            qCDebug(logCategoryStrataServer) << "building message for API v1";
            serverMessage = buildServerMessageAPIv1(clientMessage, jsonObject, responseType);
            if (serverMessage == "") {
                return;
            }
            break;

        case ApiVersion::v2:
            qCDebug(logCategoryStrataServer) << "building message for API v2";
            serverMessage = buildServerMessageAPIv2(clientMessage, jsonObject, responseType);
            break;

        case ApiVersion::none:
            qCCritical(logCategoryStrataServer)
                << "unsupported API version or client is not registered.";
            return;
            break;
    }

    connector_.sendMessage(clientMessage.clientID, serverMessage);
}

void StrataServer::notifyClient(const QByteArray &clientId, const QString &handlerName,
                                const QJsonObject &jsonObject, ResponseType responseType)
{
    Message message;
    message.clientID = clientId;
    message.handlerName = handlerName;
    message.messageID = 0;
    message.messageType = Message::MessageType::Command;
    message.payload = QJsonObject({});
    notifyClient(message, jsonObject, responseType);
}

void StrataServer::notifyAllClients(const QString &handlerName, const QJsonObject &jsonObject)
{
    Message tempClientMessage;
    tempClientMessage.handlerName = handlerName;

    QByteArray serverMessageAPI_v1 =
        buildServerMessageAPIv1(tempClientMessage, jsonObject, ResponseType::Notification);
    QByteArray serverMessageAPI_v2 =
        buildServerMessageAPIv2(tempClientMessage, jsonObject, ResponseType::Notification);

    // get all clients.
    auto allClients = clientsController_.getAllClients();

    for (const auto &client : allClients) {
        switch (client.getApiVersion()) {
            case ApiVersion::v1:
                connector_.sendMessage(client.getClientID(), serverMessageAPI_v1);
                break;

            case ApiVersion::v2:
                connector_.sendMessage(client.getClientID(), serverMessageAPI_v2);
                break;

            case ApiVersion::none:
                qCCritical(logCategoryStrataServer) << "Unsupported client API version";
                break;
        }
    }
}

void StrataServer::registerNewClientHandler(const Message &clientMessage)
{
    qCDebug(logCategoryStrataServer)
        << "Handle New Client Registration. Client ID:" << clientMessage.clientID;
    if (true == clientsController_.isRegisteredClient(clientMessage.clientID)) {
        notifyClient(clientMessage, {{"status", "client registered."}}, ResponseType::Response);
    } else {
        notifyClient(clientMessage, {{"massage", "Failed to register client"}},
                     ResponseType::Error);
    }
}

void StrataServer::unregisterClientHandler(const Message &clientMessage)
{
    qCDebug(logCategoryStrataServer)
        << "Handle Client Unregistration. Client ID:" << clientMessage.clientID;
    if (true == clientsController_.isRegisteredClient(clientMessage.clientID)) {
        qCCritical(logCategoryStrataServer) << "Failed to unregister client.";
        notifyClient(clientMessage, {{"massage", "Failed to unregister client"}},
                     ResponseType::Error);
    }
}

QByteArray StrataServer::buildServerMessageAPIv2(const Message &clientMessage,
                                                 const QJsonObject &payload,
                                                 ResponseType responseType)
{
    QJsonObject jsonObject{{"jsonrpc", "2.0"}};

    switch (responseType) {
        case ResponseType::Notification:
            jsonObject.insert("method", clientMessage.handlerName);
            jsonObject.insert("params", payload);
            break;

        case ResponseType::Response:
            jsonObject.insert("result", payload);
            jsonObject.insert("id", clientMessage.messageID);
            break;

        case ResponseType::Error:
            jsonObject.insert("error", payload);
            jsonObject.insert("id", clientMessage.messageID);
            break;

        case ResponseType::PlatformMessage:
            jsonObject.insert("method", "platform_notification");
            jsonObject.insert("params", payload);
            break;
    }

    QJsonDocument jsonDocument(jsonObject);
    QByteArray jsonByteArray = jsonDocument.toJson(QJsonDocument::JsonFormat::Compact);

    return jsonByteArray;
}

QByteArray StrataServer::buildServerMessageAPIv1(const Message &clientMessage,
                                                 const QJsonObject &payload,
                                                 ResponseType responseType)
{
    QJsonObject jsonObject;
    QString notificationType = "";
    QJsonObject tempPayload(payload);

    switch (responseType) {
        case ResponseType::Notification:
        case ResponseType::Response:
            // determine the notification type
            // "load_documents" --> "cloud::notification"
            // "platform" message --> "notification"
            // all others       --> "hcs::notification"
            if (clientMessage.handlerName == "load_documents") {
                notificationType = "cloud::notification";
            } else {
                notificationType = "hcs::notification";
            }
            tempPayload.insert("type", clientMessage.handlerName);
            jsonObject.insert(notificationType, tempPayload);
            break;

        case ResponseType::Error:
            qCDebug(logCategoryStrataServer) << "Error messages are not supported in API v1.";
            return "";
            break;

        case ResponseType::PlatformMessage:
            jsonObject.insert("notification", payload);
            break;
    }

    QJsonDocument jsonDocument(jsonObject);
    QByteArray jsonByteArray = jsonDocument.toJson(QJsonDocument::JsonFormat::Compact);

    return jsonByteArray;
}
