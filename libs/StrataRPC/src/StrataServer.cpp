/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "ClientsController.h"
#include "Dispatcher.h"
#include "ServerConnector.h"
#include "logging/LoggingQtCategories.h"
#include <StrataRPC/StrataServer.h>
#include <StrataRPC/RpcRequest.h>
#include <QJsonDocument>
#include <QThread>

using namespace strata::strataRPC;

StrataServer::StrataServer(
        const QString &address,
        QObject *parent)
    : QObject(parent),
      dispatcher_(new Dispatcher<const RpcRequest &>()),
      clientsController_(new ClientsController(this)),
      connector_(new ServerConnector(address)),
      connectorThread_(new QThread())
{

    dispatcher_->registerHandler(
                "register_client",
                std::bind(&StrataServer::registerNewClientHandler, this, std::placeholders::_1));
    dispatcher_->registerHandler(
                "unregister_client",
                std::bind(&StrataServer::unregisterClientHandler, this, std::placeholders::_1));

    connector_->moveToThread(connectorThread_.get());

    QObject::connect(
                this,
                &StrataServer::initializeConnector,
                connector_.get(),
                &ServerConnector::initialize,
                Qt::QueuedConnection);

    QObject::connect(
                this,
                &StrataServer::sendMessage,
                connector_.get(),
                &ServerConnector::sendMessage,
                Qt::QueuedConnection);

    QObject::connect(
                connector_.get(),
                &ServerConnector::messageReceived,
                this,
                &StrataServer::processRequest);

    QObject::connect(
                connector_.get(),
                &ServerConnector::initialized,
                this,
                [this]() {
        qCInfo(lcStrataServer) << "Strata Server initialized successfully.";
        emit initialized();
    });

    connectorThread_->start();
}

StrataServer::~StrataServer()
{
    connector_->deleteLater();
    connector_.release();

    connectorThread_->exit(0);
    if (connectorThread_->wait(500) == false) {
        qCCritical(lcStrataServer) << "Terminating connector thread.";
        connectorThread_->terminate();
    }
    connectorThread_->deleteLater();
    connectorThread_.release();
}

void StrataServer::initialize()
{
    emit initializeConnector();
}

bool StrataServer::registerHandler(const QString &handlerName, ServerHandler handler)
{
    bool registered = dispatcher_->registerHandler(handlerName, handler);
    if (registered == false) {
        qCCritical(lcStrataServer) << "Failed to register handler";
        return false;
    }
    return true;
}

bool StrataServer::unregisterHandler(const QString &handlerName)
{
    bool unregistered = dispatcher_->unregisterHandler(handlerName);
    if (unregistered == false) {
        qCCritical(lcStrataServer) << "Failed to unregister handler";
        return false;
    }
    return true;
}

QByteArray StrataServer::firstClientId() const
{
    QList<Client> clientList = clientsController_->getAllClients();

    if (clientList.isEmpty() == false) {
        return clientList.first().getClientID();
    }

    return QByteArray();
}

void StrataServer::processRequest(const QByteArray &clientId, const QByteArray &message)
{
    qCDebug(lcStrataServer).noquote().nospace()
        << "clientID: 0x" << clientId.toHex()
        << ", message: '" << message << "'";

    RpcRequest request;
    RpcErrorCode code = parseRpcRequest(message, request);
    if (code != RpcErrorCode::NoError) {
        RpcError error(code);
        qCWarning(lcStrataServer) << error;
        sendError(clientId, request.id(), error);
        return;
    }

    // Check if registered client
    Client client = clientsController_->getClient(clientId);
    if (client.getClientID().isEmpty() && request.method() != "register_client") {
        RpcError error(RpcErrorCode::ClientNotRegistered);
        qCWarning(lcStrataServer) << error;
        sendError(clientId, request.id(), error);
        return;
    }

    request.setClientId(clientId);
    bool dispatched = dispatcher_->dispatch(request.method(), request);
    if (dispatched == false) {
        RpcError error(RpcErrorCode::MethodNotFoundError);
        qCWarning(lcStrataServer) << error;
        sendError(clientId, request.id(), error);
        return;
    }
}

RpcErrorCode StrataServer::parseRpcRequest(const QByteArray &message, RpcRequest &request)
{
    QJsonParseError jsonParseError;
    QJsonDocument jsonDocument = QJsonDocument::fromJson(message, &jsonParseError);
    if (jsonParseError.error != QJsonParseError::NoError) {
        return RpcErrorCode::ParseError;
    }

    QJsonObject messageObject = jsonDocument.object();

    //jsonrpc
    QString jsonVersion = messageObject.value("jsonrpc").toString();
    if (jsonVersion.isEmpty() || jsonVersion != "2.0") {
        return RpcErrorCode::InvalidRequestError;
    }

    //method
    QString method = messageObject.value("method").toString();
    if (method.isEmpty()) {
        return RpcErrorCode::InvalidRequestError;
    } else {
        request.setMethod(method);
    }

    //params (optional)
    if (messageObject.contains("params")) {
        QJsonValue paramsValue = messageObject.value("params");
        if (paramsValue.isObject()) {
            request.setParams(paramsValue.toObject());
        } else {
            return RpcErrorCode::InvalidRequestError;
        }
    }

    //id (optional)
    if (messageObject.contains("id")) {
         QJsonValue idValue = messageObject.value("id");
         if (idValue.isDouble() == false && idValue.isString() == false) {
             return RpcErrorCode::InvalidRequestError;
         }
         request.setId(idValue);
    }

    return RpcErrorCode::NoError;
}

void StrataServer::sendReply(
        const QByteArray &clientId,
        const QJsonValue &id,
        const QJsonObject &result)
{
    QByteArray message =  buildReplyMessage(id, result);
    emit sendMessage(clientId, message);
}

void StrataServer::sendNotification(
        const QByteArray &clientId,
        const QString &method,
        const QJsonObject &params)
{
    QByteArray message = buildNotificationMessage(method, params);
    emit sendMessage(clientId, message);
}

void StrataServer::broadcastNotification(
        const QString &method,
        const QJsonObject &params)
{
    QByteArray message = buildNotificationMessage(method, params);
    auto allClients = clientsController_->getAllClients();
    for (const auto &client : allClients) {
        emit sendMessage(client.getClientID(), message);
    }
}

void StrataServer::sendError(
        const QByteArray &clientId,
        const QJsonValue &id,
        const RpcError &error)
{
    QByteArray message = buildErrorMessage(id, error);
    emit sendMessage(clientId, message);
}

void StrataServer::registerNewClientHandler(const RpcRequest &request)
{
    qCDebug(lcStrataServer).noquote().nospace()
        << "Handle New Client Registration. ClientID 0x:" << request.clientId().toHex();

    if (clientsController_->isRegisteredClient(request.clientId())) {
        qCDebug(lcStrataServer) << "client already registered";
    } else {
        QString apiVersion = request.params().value("api_version").toString();
        if (apiVersion.isEmpty()) {
            RpcError error(RpcErrorCode::InvalidParamsError);
            qCWarning(lcStrataServer) << error;
            sendError(request.clientId(), request.id(), error);
            return;
        }

        ApiVersion currentApiVersion = ApiVersion::none;
        if (apiVersion == "2.0") {
            currentApiVersion = ApiVersion::v2;
        } else {
            RpcError error(RpcErrorCode::UnknownApiVersionError);
            qCWarning(lcStrataServer) << error;
            sendError(request.clientId(), request.id(), error);
            return;
        }

        bool registered = clientsController_->registerClient(Client(request.clientId(), currentApiVersion));
        if (registered == false) {
            RpcError error(RpcErrorCode::ClientRegistrationError);
            qCWarning(lcStrataServer) << error;
            sendError(request.clientId(), request.id(), error);
            return;
        }

        qCDebug(lcStrataServer) << "client registered successfully";
    }

    sendReply(request.clientId(), request.id(), {{"status", "client registered"}});
}

void StrataServer::unregisterClientHandler(const RpcRequest &request)
{
    qCDebug(lcStrataServer).noquote().nospace()
        << "Handle Client Unregistration. ClientID: 0x" << request.clientId().toHex();

    if (clientsController_->isRegisteredClient(request.clientId())) {
        bool unregistered = clientsController_->unregisterClient(request.clientId());
        if (unregistered == false) {
            RpcError error(RpcErrorCode::ClientUnregistrationError);
            qCWarning(lcStrataServer) << error;
            sendError(request.clientId(), request.id(), error);
            return;
        }
    }

    sendReply(request.clientId(), request.id(), {{"status", "client unregistered"}});
}

QByteArray StrataServer::buildReplyMessage(
        const QJsonValue &id,
        const QJsonObject &result)
{
    QJsonObject jsonObject;
    jsonObject.insert("jsonrpc", "2.0");
    jsonObject.insert("result", result);
    jsonObject.insert("id", id);

    return QJsonDocument(jsonObject).toJson(QJsonDocument::JsonFormat::Compact);
}

QByteArray StrataServer::buildNotificationMessage(
        const QString &method,
        const QJsonObject &params)
{
    QJsonObject jsonObject;
    jsonObject.insert("jsonrpc", "2.0");
    jsonObject.insert("method", method);
    jsonObject.insert("params", params);

    return QJsonDocument(jsonObject).toJson(QJsonDocument::JsonFormat::Compact);
}

QByteArray StrataServer::buildErrorMessage(
        const QJsonValue &id,
        const RpcError &error)
{
    QJsonObject errorObject;
    errorObject.insert("code", error.code());
    errorObject.insert("message", error.message());
    if (error.data().isEmpty() == false) {
        errorObject.insert("data", error.data());
    }

    QJsonObject jsonObject;
    jsonObject.insert("jsonrpc", "2.0");
    jsonObject.insert("error", errorObject);
    jsonObject.insert("id", id);

    return QJsonDocument(jsonObject).toJson(QJsonDocument::JsonFormat::Compact);
}
