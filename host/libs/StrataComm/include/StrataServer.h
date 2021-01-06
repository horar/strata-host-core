#pragma once

#include <QObject>

#include "../src/ClientsController.h"
#include "../src/Dispatcher.h"
#include "../src/ServerConnector.h"

namespace strata::strataComm
{
class StrataServer : public QObject
{
    Q_OBJECT

public:
    /**
     * StrataServer constructor
     * @param [in] address Sets the server address
     */
    StrataServer(QString address, QObject *parent = nullptr);

    /**
     * StrataServer destructor
     */
    ~StrataServer();

    /**
     * Initialize and start up the server
     * @return true if the server initialization is successful. False otherwise.
     */
    bool initializeServer();

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

public slots:
    /**
     * Slot to handler new incoming messages.
     * @param [in] clientId client id of the sender
     * @param [in] message QByteArray of the message json string.
     */
    void newClientMessage(const QByteArray &clientId, const QByteArray &message);

    /**
     * Slot to send a message to a client. This overload is used when responding to a prevues client
     * message.
     * @param [in] clientMessage Message struct that have information about the client original
     * client message. This will be used to determine the client and message ids.
     * @param [in] jsonObject QJsonObject of response/notification payload.
     * @param [in] responseType The type of the server message.
     */
    void notifyClient(const Message &clientMessage, const QJsonObject &jsonObject,
                      ResponseType responseType);

    /**
     * Slot to send a message to a client. This overload is used to send unsolicited notifications
     * from the server where there is no corresponding client message.
     * @param [in] clientId client id.
     * @param [in] handlerName The name of the handler in the client side.
     * @param [in] jsonObject QJsonObject of response/notification payload.
     * @param [in] responseType The type of the server message.
     */
    void notifyClient(const QByteArray &clientId, const QString &handlerName,
                      const QJsonObject &jsonObject, ResponseType responseType);

    /**
     * Slot to notify all connected clients.
     * @param [in] handlerName The name of the handler in the client side.
     * @param [in] jsonObject QJsonObject of response/notification payload.
     */
    void notifyAllClients(const QString &handlerName, const QJsonObject &jsonObject);

signals:
    /**
     * Signal emitted when a new client message is parsed and ready to be dispatched
     * @param [in] clientMessage populated Message object with the command/notification metadata.
     */
    void dispatchHandler(const Message &clientMessage);

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
    QByteArray buildServerMessageAPIv2(const Message &clientMessage, const QJsonObject &payload,
                                       ResponseType responseType);

    /**
     * Build server message to be sent to clients using API v1.
     * @param [in] clientMessage Message struct that have information about the client original
     * client message. This will be used to determine the client and message ids.
     * @param [in] payload QJsonObject of response/notification payload.
     * @param [in] responseType The type of the server message.
     * @return QByteArray of the json message. Empty QByteArray when there is an error while
     * building the message.
     */
    QByteArray buildServerMessageAPIv1(const Message &clientMessage, const QJsonObject &payload,
                                       ResponseType responseType);

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

    Dispatcher dispatcher_;
    ClientsController clientsController_;
    ServerConnector connector_;
};

}  // namespace strata::strataComm
