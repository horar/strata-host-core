#pragma once

#include <QObject>
#include <functional>

#include "DeferredRequest.h"

class QThread;

namespace strata::strataRPC
{
template <class HandlerArgument>
class Dispatcher;
class ClientConnector;
class RequestsController;
struct Message;
enum class ClientConnectorError : short;

class StrataClient : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(StrataClient);

public:
    typedef std::function<void(const QJsonObject &)> ClientHandler;

    /**
     * Enum to describe errors
     */
    enum class ClientError {
        FailedToConnect,
        FailedToDisconnect,
        FailedToBuildServerMessage,
        FailedToRegisterHandler,
        FailedToUnregisterHandler,
        FailedToAddReequest,
        FailedToSendRequest,
        FailedToSendNotification,
        PendingRequestNotFound,
        RequestTimeout,
        HandlerNotFound
    };
    Q_ENUM(ClientError);

    /**
     * StrataClient constructor
     * @param [in] serverAddress Sets the server address.
     * @param [in] dealerId Sets the client id.
     */
    StrataClient(const QString &serverAddress, const QByteArray &dealerId = "StrataClient",
                 QObject *parent = nullptr);

    /**
     * StrataClient destructor
     */
    ~StrataClient();

    /**
     * Function to establish the server connection
     * @note If the client connected successfully StrataClient will emit connected signal,
     * Otherwise it will emit errorOccurred signal.
     */
    void connect();

    /**
     * Function to close the connection to the server.
     * @note If the connection was disconnected successfully, StrataClient will emit
     * disconnected signal.
     */
    void disconnect();

    /**
     * Register a command handler in the client's dispatcher.
     * @param [in] handlerName The name of the handlers associated with its commands, requests, or
     * notifications
     * @param [in] handler function pointer to function of type ClientHandler.
     * @return True if the handler is added to the handlers list. False otherwise.
     */
    bool registerHandler(const QString &handlerName, ClientHandler handler);

    /**
     * Remove a handler from the registered handlers in the client's dispatcher.
     * @param [in] handlerName The name of the handlers associated with its commands, requests, or
     * notifications
     * @return True if the handler was found and removed successfully from the dispatcher. False
     * otherwise.
     */
    bool unregisterHandler(const QString &handlerName);

    /**
     * Sends a request to the server.
     * @note If a callback is not provided the response will not be handled.
     * @param [in] method The handler name in StrataServer.
     * @param [in] payload QJsonObject of the request payload.
     * @return pointer to DeferredRequest to connect callbacks, on failure, this will return
     * nullptr
     */
    Q_INVOKABLE DeferredRequest *sendRequest(const QString &method, const QJsonObject &payload);

    /**
     * Sends a notification to the server.
     * @note The response is handled by the registered handlers in the dispatcher.
     * @param [in] method The handler name in StrataServer.
     * @param [in] payload QJsonObject of the request payload.
     * @return True if the notification was sent successfully, false otherwise.
     */
    Q_INVOKABLE bool sendNotification(const QString &method, const QJsonObject &payload);

signals:
    /**
     * Emitted when a new server message is parsed and ready to be handled
     * @param [in] serverMessage populated Message object with the notification meta data.
     */
    void messageParsed(const Message &serverMessage);

    /**
     * Emitted when the client connects to the server successfully.
     */
    void connected();

    /**
     * Emitted when the client is disconnected from the server.
     */
    void disconnected();

    /**
     * Emitted when an error has occurred.
     * @param [in] errorType error category description.
     * @param [in] errorMessage QString of the actual error.
     */
    void errorOccurred(const StrataClient::ClientError &errorType, const QString &errorMessage);

    /**
     * Signal to initialize the ClientConnector.
     */
    void initializeConnector();

    /**
     * Signal to connect to the server.
     */
    void connectClient();

    /**
     * signal to disconnect the server.
     */
    void disconnectClient();

    /**
     * Signal to send a message to the server.
     * @param [in] message QByteArray of the message.
     */
    void sendMessage(const QByteArray &message);

private slots:
    /**
     * Slot to handle new incoming messages from StrataServer.
     * @param [in] jsonServerMessage QByteArray json of StrataServer's message.
     */
    void messageReceivedHandler(const QByteArray &jsonServerMessage);

    /**
     * Handles timed out requests.
     * @param [in] requestId request id of the timed out request.
     */
    void requestTimeoutHandler(const int &requestId);

    /**
     * Slot to handle dispatching server notification handlers.
     * @note This will emit errorOccurred signal if the handler is not registered.
     * @param [in] serverMessage parsed server message.
     */
    void dispatchHandler(const Message &serverMessage);

    /**
     * Slot to handle initialized signal from ClientConnector by sending register_client
     * message to the server.
     */
    void clientInitializedHandler();

    /**
     * Slot to handle errors from the ClientConnector.
     * @param [in] errorType enum of the the error.
     * @param [in] errorMessage description of the error.
     */
    void connectorErrorHandler(const ClientConnectorError &errorType, const QString &errorMessage);

private:
    /**
     * Parse the incoming json message from StrataServer into a Message object.
     * @param [in] jsonServerMessage QByteArray json of StrataServer's message.
     * @param [out] serverMessage populated Message object with the notification meta data.
     * @param [out] deferredRequest pointer to the request's callbacks.
     * @return True if the json message was parsed successfully. False otherwise.
     */
    bool buildServerMessage(const QByteArray &jsonServerMessage, Message *serverMessage,
                            DeferredRequest **deferredRequest);

    std::unique_ptr<Dispatcher<const QJsonObject &>> dispatcher_;
    std::unique_ptr<ClientConnector> connector_;
    std::unique_ptr<RequestsController> requestController_;
    std::unique_ptr<QThread> connectorThread_;
};
}  // namespace strata::strataRPC
