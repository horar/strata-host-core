/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QObject>

#include "RpcError.h"
#include "RpcRequest.h"

class QThread;

namespace strata::strataRPC
{
template <class HandlerArgument>
class Dispatcher;
class ServerConnector;
class ClientsController;
enum class ServerConnectorError : short;

class StrataServer : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(StrataServer);

public:
    typedef std::function<void(const RpcRequest &)> ServerHandler;

    /**
     * StrataServer constructor
     * @param [in] address Sets the server address
     * @param [in] useDefaultHandlers boolean to use the built in handlers for register_client and
     * unregister commands. The default value is true.
     */
    StrataServer(
            const QString &address,
            bool useDefaultHandlers = true,
            QObject *parent = nullptr);

    /**
     * StrataServer destructor
     */
    ~StrataServer();

    /**
     * Initialize and start up the server
     * @note If the server is initialized successfully StrataServer will emit initialized
     * signal. Otherwise it will emit errorOccurred.
     */
    void initialize();

    /**
     * Register a command handler in the server's dispatcher.
     * @param [in] handlerName The name of the handlers associated with its commands, requests, or
     * notifications
     * @param [in] handler function pointer to function of type StrataHandler.
     * @return True if the handler is added to the handlers list. False otherwise.
     */
    bool registerHandler(
            const QString &handlerName,
            ServerHandler handler);

    /**
     * Remove a handler from the registered handlers in the server's dispatcher.
     * @param [in] handlerName The name of the handlers associated with its commands, requests, or
     * notifications
     * @return True if the handler was found and removed successfully from the dispatcher. False
     * otherwise.
     */
    bool unregisterHandler(const QString &handlerName);

    /**
     * Cliend Id of the first client.
     * @return client id if client exists, otherwise empty QByteArray
     */
    QByteArray firstClientId() const;

public slots:
    /**
     * Sends json-rpc reply to specified client
     */
    void sendReply(
            const QByteArray &clientId,
            const QJsonValue &id,
            const QJsonObject &result);

    /**
     * Sends json-rpc notification to specified client
     */
    void sendNotification(
            const QByteArray &clientId,
            const QString &method,
            const QJsonObject &params);

    /**
     * Sends json-rpc notification to all clients
     */
    void broadcastNotification(
            const QString &method,
            const QJsonObject &params);

    /**
     * Sends json-rpc error to specified client
     */
    void sendError(
            const QByteArray &clientId,
            const QJsonValue &id,
            const strata::strataRPC::RpcError &error);

private slots:
    /**
     * Process new incoming request from client
     * @param [in] clientId client id of the sender
     * @param [in] message QByteArray of the message json string.
     */
    void processRequest(const QByteArray &clientId, const QByteArray &message);

signals:
    /**
     * Signal to initialize the server.
     */
    void initializeConnector();

    /**
     * Emitted when the server is initialize successfully.
     */
    void initialized();

    /**
     * Signal to send a message to a client.
     * @param [in] clientId QByteArray of the client id.
     * @param [in] message QByteArray of the message.
     */
    void sendMessage(const QByteArray &clientId, const QByteArray &message);

private:
    RpcError::ErrorCode parseRpcRequest(const QByteArray &message, RpcRequest &request);

    QByteArray buildReplyMessage(
            const QJsonValue &id,
            const QJsonObject &result);

    QByteArray buildNotificationMessage(
            const QString &method,
            const QJsonObject &params);

    QByteArray buildErrorMessage(
            const QJsonValue &id,
            const strata::strataRPC::RpcError &error);

    /**
     * StrataServer handler for client registration.
     * @param [in] clientMessage Message object containing the client request metadata
     */
    void registerNewClientHandler(const RpcRequest &request);

    /**
     * StrataServer handler for client unregistration.
     * @param [in] clientMessage Message object containing the client request metadata
     */
    void unregisterClientHandler(const RpcRequest &request);

    std::unique_ptr<Dispatcher<const RpcRequest &>> dispatcher_;
    std::unique_ptr<ClientsController> clientsController_;
    std::unique_ptr<ServerConnector> connector_;
    std::unique_ptr<QThread> connectorThread_;
};

}  // namespace strata::strataRPC
