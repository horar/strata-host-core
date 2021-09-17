#include "ClientsController.h"
#include "Dispatcher.h"
#include "ServerConnector.h"
#include "logging/LoggingQtCategories.h"

#include <StrataRPC/StrataServer.h>
#include <QJsonDocument>
#include <QThread>

using namespace strata::strataRPC;

StrataServer::StrataServer(const QString &address, bool useDefaultHandlers, QObject *parent)
    : QObject(parent),
      dispatcher_(new Dispatcher<const Message &>()),
      clientsController_(new ClientsController(this)),
      connector_(new ServerConnector(address)),
      connectorThread_(new QThread())
{
    if (true == useDefaultHandlers) {
        dispatcher_->registerHandler(
            "register_client",
            std::bind(&StrataServer::registerNewClientHandler, this, std::placeholders::_1));
        dispatcher_->registerHandler("unregister", std::bind(&StrataServer::unregisterClientHandler,
                                                             this, std::placeholders::_1));
    }

    qRegisterMetaType<strataRPC::ServerConnectorError>("ServerConnectorError");
    connector_->moveToThread(connectorThread_.get());

    QObject::connect(this, &StrataServer::initializeConnector, connector_.get(),
                     &ServerConnector::initialize, Qt::QueuedConnection);
    QObject::connect(this, &StrataServer::sendMessage, connector_.get(),
                     &ServerConnector::sendMessage, Qt::QueuedConnection);
    QObject::connect(this, &StrataServer::MessageParsed, this, &StrataServer::dispatchHandler);
    QObject::connect(connector_.get(), &ServerConnector::messageReceived, this,
                     &StrataServer::messageReceived);
    QObject::connect(connector_.get(), &ServerConnector::errorOccurred, this,
                     &StrataServer::connectorErrorHandler);
    QObject::connect(connector_.get(), &ServerConnector::initialized, this, [this]() {
        qCInfo(logCategoryStrataServer) << "Strata Server initialized successfully.";
        emit initialized();
    });

    connectorThread_->start();
}

StrataServer::~StrataServer()
{
    connector_->deleteLater();
    connector_.release();

    connectorThread_->exit(0);
    if (false == connectorThread_->wait(500)) {
        qCCritical(logCategoryStrataServer) << "Terminating connector thread.";
        connectorThread_->terminate();
    }
    connectorThread_->deleteLater();
    connectorThread_.release();
}

void StrataServer::initialize()
{
    emit initializeConnector();
}

bool StrataServer::registerHandler(const QString &handlerName, StrataHandler handler)
{
    if (false == dispatcher_->registerHandler(handlerName, handler)) {
        QString errorMessage(QStringLiteral("Failed to register handler"));
        qCCritical(logCategoryStrataServer) << errorMessage;
        emit errorOccurred(ServerError::FailedToRegisterHandler, errorMessage);
        return false;
    }
    return true;
}

bool StrataServer::unregisterHandler(const QString &handlerName)
{
    if (false == dispatcher_->unregisterHandler(handlerName)) {
        QString errorMessage(QStringLiteral("Failed to unregister handler"));
        qCCritical(logCategoryStrataServer) << errorMessage;
        emit errorOccurred(ServerError::FailedToUnregisterHandler, errorMessage);
        return false;
    }
    return true;
}

void StrataServer::messageReceived(const QByteArray &clientId, const QByteArray &message)
{
    qCDebug(logCategoryStrataServer).noquote().nospace()
        << "StrataServer messageReceived, ClientID: 0x" << clientId.toHex()
        << ", Message: '" << message << '\'';

    QJsonParseError jsonParseError;
    QJsonDocument jsonDocument = QJsonDocument::fromJson(message, &jsonParseError);

    if (jsonParseError.error != QJsonParseError::NoError) {
        QString errorMessage(QStringLiteral("invalid JSON message."));
        qCCritical(logCategoryStrataServer) << errorMessage;
        emit errorOccurred(ServerError::FailedToBuildClientMessage, errorMessage);
        return;
    }
    QJsonObject jsonObject = jsonDocument.object();

    Message clientMessage;
    clientMessage.clientID = clientId;
    ApiVersion apiVersion = ApiVersion::none;

    Client client = clientsController_->getClient(clientMessage.clientID);

    // Check if registered client
    if (true == client.getClientID().isEmpty()) {
        qCDebug(logCategoryStrataServer) << "Client not registered";

        // Find out the client api version.
        if ((true == jsonObject.contains("jsonrpc"))) {
            if ((true == jsonObject.value("jsonrpc").isString()) &&
                (jsonObject.value("jsonrpc") == "2.0")) {
                apiVersion = ApiVersion::v2;
                qCDebug(logCategoryStrataServer) << "API v2";
            } else {
                QString errorMessage(QStringLiteral("Unknown API."));
                qCCritical(logCategoryStrataServer) << errorMessage;
                emit errorOccurred(ServerError::FailedToBuildClientMessage, errorMessage);
                return;
            }
        } else {
            qCDebug(logCategoryStrataServer) << "API v1";
            apiVersion = ApiVersion::v1;
        }

        // Register the client.
        if (false == clientsController_->registerClient(Client(clientId, apiVersion))) {
            QString errorMessage(QStringLiteral("Failed to register client"));
            qCCritical(logCategoryStrataServer) << errorMessage;
            emit errorOccurred(ServerError::FailedToRegisterClient, errorMessage);
            return;
        }

        qCInfo(logCategoryStrataServer) << "Client registered successfully";

    } else {
        // Client already registered
        apiVersion = client.getApiVersion();
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

    emit MessageParsed(clientMessage);
}

bool StrataServer::buildClientMessageAPIv2(const QJsonObject &jsonObject, Message *clientMessage)
{
    if (false == jsonObject.contains("jsonrpc") ||
        false == jsonObject.value("jsonrpc").isString() || jsonObject.value("jsonrpc") != "2.0") {
        QString errorMessage(QStringLiteral("Invalid or missing API identifier."));
        qCCritical(logCategoryStrataServer) << errorMessage;
        emit errorOccurred(ServerError::FailedToBuildClientMessage, errorMessage);
        return false;
    }

    // populate the handlerName -> method
    if ((true == jsonObject.contains("method")) && (jsonObject.value("method").isString())) {
        clientMessage->handlerName = jsonObject.value("method").toString();
    } else {
        QString errorMessage(QStringLiteral("Failed to process handler name."));
        qCCritical(logCategoryStrataServer) << errorMessage;
        emit errorOccurred(ServerError::FailedToBuildClientMessage, errorMessage);
        return false;
    }

    // populate the payload --> param
    if ((true == jsonObject.contains("params")) &&
        (true == jsonObject.value("params").isObject())) {
        clientMessage->payload = jsonObject.value("params").toObject();
    } else {
        QString errorMessage(QStringLiteral("Failed to process message payload."));
        qCCritical(logCategoryStrataServer) << errorMessage;
        emit errorOccurred(ServerError::FailedToBuildClientMessage, errorMessage);
        return false;
    }

    // populate messageID --> id
    if ((true == jsonObject.contains("id") && (true == jsonObject.value("id").isDouble()))) {
        clientMessage->messageID = jsonObject.value("id").toDouble();
    } else {
        QString errorMessage(QStringLiteral("Failed to process message id."));
        qCCritical(logCategoryStrataServer) << errorMessage;
        emit errorOccurred(ServerError::FailedToBuildClientMessage, errorMessage);
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
            true == jsonObject.value("device_id").isString()) {
            clientMessage->handlerName = "platform_message";
            isPlatformMessage = true;
        } else {
            clientMessage->handlerName = jsonObject.value("cmd").toString();
        }
    } else if ((true == jsonObject.contains("hcs::cmd")) &&
               (true == jsonObject.value("hcs::cmd").isString())) {
        clientMessage->handlerName = jsonObject.value("hcs::cmd").toString();
    } else {
        QString errorMessage(QStringLiteral("Failed to process handler name."));
        qCCritical(logCategoryStrataServer) << errorMessage;
        emit errorOccurred(ServerError::FailedToBuildClientMessage, errorMessage);
        return false;
    }

    // documentation show messages with no payload are valid.
    bool hasPayload =
        (true == jsonObject.contains("payload")) && (jsonObject.value("payload").isObject());
    QJsonObject payloadJsonObject{};

    if (true == isPlatformMessage) {
        payloadJsonObject.insert("device_id", jsonObject.value("device_id").toString());
        QJsonObject messageJsonObject;
        messageJsonObject.insert("cmd", jsonObject.value("cmd"));
        if (true == hasPayload) {
            messageJsonObject.insert("payload", jsonObject.value("payload").toObject());
        } else {
            messageJsonObject.insert("payload", QJsonObject{});
        }
        payloadJsonObject.insert(
            "message",
            QString(QJsonDocument(messageJsonObject).toJson(QJsonDocument::JsonFormat::Compact)));
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
                                const ResponseType responseType)
{
    switch (clientsController_->getClientApiVersion(clientMessage.clientID)) {
        case ApiVersion::v1:
            qCDebug(logCategoryStrataServer) << "Building message for API v1";
            emit sendMessage(clientMessage.clientID,
                             buildServerMessageAPIv1(clientMessage, jsonObject, responseType));
            break;

        case ApiVersion::v2:
            qCDebug(logCategoryStrataServer) << "Building message for API v2";
            emit sendMessage(clientMessage.clientID,
                             buildServerMessageAPIv2(clientMessage, jsonObject, responseType));
            break;

        case ApiVersion::none:
            QString errorMessage(
                QStringLiteral("Unsupported API version or client is not registered."));
            qCCritical(logCategoryStrataServer).noquote() << errorMessage;
            emit errorOccurred(ServerError::FailedToBuildClientMessage, errorMessage);
            break;
    }
}

void StrataServer::notifyClient(const QByteArray &clientId, const QString &handlerName,
                                const QJsonObject &jsonObject, const ResponseType responseType)
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

    // get all clients.
    auto allClients = clientsController_->getAllClients();

    for (const auto &client : allClients) {
        switch (client.getApiVersion()) {
            case ApiVersion::v1:
                emit sendMessage(
                        client.getClientID(),
                        buildServerMessageAPIv1(tempClientMessage, jsonObject, ResponseType::Notification)
                     );
                break;

            case ApiVersion::v2:
                emit sendMessage(
                        client.getClientID(),
                        buildServerMessageAPIv2(tempClientMessage, jsonObject, ResponseType::Notification)
                     );
                break;

            case ApiVersion::none:
                {
                    QString errorMessage(QStringLiteral("Unsupported client API version"));
                    qCCritical(logCategoryStrataServer) << errorMessage;
                    emit errorOccurred(ServerError::FailedToBuildClientMessage, errorMessage);
                }
                break;
        }
    }
}

void StrataServer::registerNewClientHandler(const Message &clientMessage)
{
    qCDebug(logCategoryStrataServer).noquote().nospace()
        << "Handle New Client Registration. ClientID 0x:" << clientMessage.clientID.toHex();

    // Find the client API version, if it was v1, ignore the parsing.
    if (ApiVersion currentApiVersion =
            clientsController_->getClientApiVersion(clientMessage.clientID);
        ApiVersion::v1 != currentApiVersion) {
        if (true == clientMessage.payload.contains("api_version") &&
            true == clientMessage.payload.value("api_version").isString()) {
            QString apiVersionPayload = clientMessage.payload.value("api_version").toString();

            // list of available api versions.
            if (apiVersionPayload == "2.0") {
                clientsController_->updateClientApiVersion(clientMessage.clientID, ApiVersion::v2);
            } else {
                QString errorMessage(QStringLiteral("Unknown API version."));
                qCCritical(logCategoryStrataServer) << errorMessage;
                emit errorOccurred(ServerError::FailedToRegisterClient, errorMessage);
                notifyClient(clientMessage,
                             {{"massage", "Failed to register client, Unknown API Version."}},
                             ResponseType::Error);
                clientsController_->unregisterClient(clientMessage.clientID);
                return;
            }
        } else {
            qCDebug(logCategoryStrataServer) << "No API version in payload, Assuming API v2.";
        }
    }

    if (true == clientsController_->isRegisteredClient(clientMessage.clientID)) {
        notifyClient(clientMessage, {{"status", "client registered."}}, ResponseType::Response);
    } else {
        QString errorMessage(QStringLiteral("Failed to register client."));
        qCCritical(logCategoryStrataServer) << errorMessage;
        emit errorOccurred(ServerError::FailedToRegisterClient, errorMessage);
        notifyClient(clientMessage, {{"massage", errorMessage}}, ResponseType::Error);
    }
}

void StrataServer::unregisterClientHandler(const Message &clientMessage)
{
    qCDebug(logCategoryStrataServer).noquote().nospace()
        << "Handle Client Unregistration. ClientID: 0x" << clientMessage.clientID.toHex();
    if (false == clientsController_->unregisterClient(clientMessage.clientID)) {
        QString errorMessage(
            QStringLiteral("Failed to unregister client. Client is not registered."));
        qCCritical(logCategoryStrataServer) << errorMessage;
        emit errorOccurred(ServerError::FailedToUnregisterClient, errorMessage);
        notifyClient(clientMessage, {{"massage", "Failed to unregister client"}},
                     ResponseType::Error);
    }
}

QByteArray StrataServer::buildServerMessageAPIv2(const Message &clientMessage,
                                                 const QJsonObject &payload,
                                                 const ResponseType responseType)
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

    return QJsonDocument(jsonObject).toJson(QJsonDocument::JsonFormat::Compact);
}

QByteArray StrataServer::buildServerMessageAPIv1(const Message &clientMessage,
                                                 const QJsonObject &payload,
                                                 const ResponseType responseType)
{
    QJsonObject jsonObject;
    QString notificationType = "";
    QJsonObject tempPayload(payload);

    switch (responseType) {
        case ResponseType::Error:
            qCDebug(logCategoryStrataServer) << "Error messages are not supported in API v1.";
            // send error as notification
            [[fallthrough]];
        case ResponseType::Notification:
        case ResponseType::Response:
            // determine the notification type
            // "document" --> "cloud::notification"
            // "document_progress" --> "cloud::notification"
            // "platform" message --> "notification"
            // all others       --> "hcs::notification"
            if (clientMessage.handlerName == "document" ||
                clientMessage.handlerName == "document_progress") {
                notificationType = "cloud::notification";
            } else {
                notificationType = "hcs::notification";
            }
            tempPayload.insert("type", clientMessage.handlerName);
            jsonObject.insert(notificationType, tempPayload);
            break;

        case ResponseType::PlatformMessage:
            jsonObject.insert("notification", payload);
            break;
    }

    return QJsonDocument(jsonObject).toJson(QJsonDocument::JsonFormat::Compact);
}

void StrataServer::dispatchHandler(const Message &clientMessage)
{
    if (false == dispatcher_->dispatch(clientMessage.handlerName, clientMessage)) {
        QString errorMessage(QStringLiteral("Handler not found."));
        qCCritical(logCategoryStrataServer) << errorMessage;
        emit errorOccurred(ServerError::HandlerNotFound, errorMessage);
        notifyClient(clientMessage, {{"massage", errorMessage}}, ResponseType::Error);
        return;
    }

    // qCDebug(logCategoryStrataServer) << "Handler executed.";
}

void StrataServer::connectorErrorHandler(const ServerConnectorError &errorType,
                                         const QString &errorMessage)
{
    switch (errorType) {
        case ServerConnectorError::FailedToInitialize:
            emit errorOccurred(ServerError::FailedToInitializeServer, errorMessage);
            break;
        case ServerConnectorError::FailedToSend:
            emit errorOccurred(ServerError::FailedToBuildClientMessage, errorMessage);
            break;
    }
}
