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

#include "Message.h"

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
    /**
     * Enum to describe errors
     */
    enum class ServerError {
        FailedToInitializeServer,
        FailedToRegisterHandler,
        FailedToUnregisterHandler,
        FailedToRegisterClient,
        FailedToUnregisterClient,
        FailedToBuildClientMessage,
        HandlerNotFound
    };
    Q_ENUM(ServerError);

    /**
     * StrataServer constructor
     * @param [in] address Sets the server address
     * @param [in] useDefaultHandlers boolean to use the built in handlers for register_client and
     * unregister commands. The default value is true.
     */
    StrataServer(const QString &address, bool useDefaultHandlers = true, QObject *parent = nullptr);

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
    bool registerHandler(const QString &handlerName, StrataHandler handler);

    /**
     * Remove a handler from the registered handlers in the server's dispatcher.
     * @param [in] handlerName The name of the handlers associated with its commands, requests, or
     * notifications
     * @return True if the handler was found and removed successfully from the dispatcher. False
     * otherwise.
     */
    bool unregisterHandler(const QString &handlerName);

    QByteArray firstClientId() const;

public slots:
    /**
     * Slot to send a message to a client. This overload is used when responding to a prevues client
     * message.
     * @param [in] clientMessage Message struct that have information about the client original
     * client message. This will be used to determine the client and message ids.
     * @param [in] jsonObject QJsonObject of response/notification payload.
     * @param [in] responseType The type of the server message.
     */
    void notifyClient(const Message &clientMessage, const QJsonObject &jsonObject,
                      const ResponseType responseType);

    /**
     * Slot to send a message to a client. This overload is used to send unsolicited notifications
     * from the server where there is no corresponding client message.
     * @param [in] clientId client id.
     * @param [in] handlerName The name of the handler in the client side.
     * @param [in] jsonObject QJsonObject of response/notification payload.
     * @param [in] responseType The type of the server message.
     */
    void notifyClient(const QByteArray &clientId, const QString &handlerName,
                      const QJsonObject &jsonObject, const ResponseType responseType);

    /**
     * Slot to notify all connected clients.
     * @param [in] handlerName The name of the handler in the client side.
     * @param [in] jsonObject QJsonObject of response/notification payload.
     */
    void notifyAllClients(const QString &handlerName, const QJsonObject &jsonObject);

private slots:
    /**
     * Slot to handler new incoming messages.
     * @param [in] clientId client id of the sender
     * @param [in] message QByteArray of the message json string.
     */
    void messageReceived(const QByteArray &clientId, const QByteArray &message);

    /**
     * Slot to handle dispatching client notification/requests handlers.
     * @note This will emit errorOccurred signal if the handler is not registered.
     * @param [in] clientMessage parsed server message.
     */
    void dispatchHandler(const Message &clientMessage);

    /**
     * Slot to handle errors from the ServerConnector.
     * @param [in] errorType enum of the the error.
     * @param [in] errorMessage description of the error.
     */
    void connectorErrorHandler(const ServerConnectorError &errorType, const QString &errorMessage);

signals:
    /**
     * Signal emitted when a new client message is parsed and ready to be dispatched
     * @param [in] clientMessage populated Message object with the command/notification metadata.
     */
    void MessageParsed(const Message &clientMessage);

    /**
     * Emitted when an error has occurred.
     * @param [in] errorType error category description.
     * @param [in] errorMessage QString of the actual error.
     */
    void errorOccurred(const StrataServer::ServerError &errorType, const QString &errorMessage);

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
    /**
     * Parse json client message based on API v2.
     * @param [in] jsonObject QJsonObject of the json message received from the client.
     * @param [out] clientMessage Populated Message object containing the message meta data.
     * @return True if the message is parsed successfully, False otherwise.
     */
    bool buildClientMessageAPIv2(const QJsonObject &jsonObject, Message *clientMessage);

    /**
     * Parse json client message based on API v1.
     * @param [in] jsonObject QJsonObject of the json message received from the client.
     * @param [out] clientMessage Populated Message object containing the message meta data.
     * @return True if the message is parsed successfully, False otherwise.
     */
    bool buildClientMessageAPIv1(const QJsonObject &jsonObject, Message *clientMessage);

    /**
     * Build server message to be sent to clients using API v2.
     * @param [in] clientMessage Message struct that have information about the client original
     * client message. This will be used to determine the client and message ids.
     * @param [in] payload QJsonObject of response/notification payload.
     * @param [in] responseType The type of the server message.
     * @return QByteArray of the json message. Empty QByteArray when there is an error while
     * building the message.
     */
    [[nodiscard]] QByteArray buildServerMessageAPIv2(const Message &clientMessage,
                                                     const QJsonObject &payload,
                                                     const ResponseType responseType);

    /**
     * Build server message to be sent to clients using API v1.
     * @param [in] clientMessage Message struct that have information about the client original
     * client message. This will be used to determine the client and message ids.
     * @param [in] payload QJsonObject of response/notification payload.
     * @param [in] responseType The type of the server message.
     * @return QByteArray of the json message. Empty QByteArray when there is an error while
     * building the message.
     */
    [[nodiscard]] QByteArray buildServerMessageAPIv1(const Message &clientMessage,
                                                     const QJsonObject &payload,
                                                     const ResponseType responseType);

    /**
     * StrataServer handler for client registration.
     * @param [in] clientMessage Message object containing the client request metadata
     */
    void registerNewClientHandler(const Message &clientMessage);

    /**
     * StrataServer handler for client unregistration.
     * @param [in] clientMessage Message object containing the client request metadata
     */
    void unregisterClientHandler(const Message &clientMessage);

    std::unique_ptr<Dispatcher<const Message &>> dispatcher_;
    std::unique_ptr<ClientsController> clientsController_;
    std::unique_ptr<ServerConnector> connector_;
    std::unique_ptr<QThread> connectorThread_;
};

}  // namespace strata::strataRPC
