#pragma once

#include <QObject>

#include "DeferredRequest.h"
#include "Message.h"

namespace strata::strataRPC
{
template <class HandlerArgument>
class Dispatcher;
class ClientConnector;
class RequestsController;

class StrataClient : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(StrataClient);

public:
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
        PendingRequestNotFound,
        RequestTimeout,
        HandlerNotFound
    };
    Q_ENUM(ClientError);

    /**
     * StrataClient constructor
     * @param [in] serverAddress Sets the server address.
     */
    StrataClient(QString serverAddress, QObject *parent = nullptr);

    /**
     * StrataClient constructor
     * @param [in] serverAddress Sets the server address.
     * @param [in] dealerId Sets the client id.
     */
    StrataClient(QString serverAddress, QByteArray dealerId, QObject *parent = nullptr);

    /**
     * StrataClient destructor
     */
    ~StrataClient();

    /**
     * Function to establish the server connection
     * @return True if the connection is established successfully, False otherwise.
     */
    bool connectServer();

    /**
     * Function to close the connection to the server.
     * @return True if the connection was disconnected successfully, False otherwise.
     */
    bool disconnectServer();

    /**
     * Register a command handler in the client's dispatcher.
     * @param [in] handlerName The name of the handlers associated with its commands, requests, or
     * notifications
     * @param [in] handler function pointer to function of type StrataHandler.
     * @return True if the handler is added to the handlers list. False otherwise.
     */
    bool registerHandler(const QString &handlerName, StrataHandler handler);

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
     * @note callbacks are optional, if a callback is not provided, then the response is handled by
     * the registered handlers in the dispatcher.
     * @param [in] method The handler name in StrataServer.
     * @param [in] payload QJsonObject of the request payload.
     * @return pointer to DeferredRequest to connect callbacks, on failure, this will return
     * nullptr
     */
    DeferredRequest *sendRequest(const QString &method, const QJsonObject &payload);

signals:
    /**
     * Emitted when a new server message is parsed and ready to be handled
     * @param [in] serverMessage populated Message object with the notification meta data.
     */
    void newServerMessageParsed(const Message &serverMessage);

    /**
     * Emitted when an error has occurred.
     * @param [in] errorType error category description.
     * @param [in] errorMessage QString of the actual error.
     */
    void errorOccurred(StrataClient::ClientError errorType, const QString &errorMessage);

private slots:
    /**
     * Slot to handle new incoming messages from StrataServer.
     * @param [in] jsonServerMessage QByteArray json of StrataServer's message.
     */
    void newServerMessage(const QByteArray &jsonServerMessage);

    /**
     * Handles timed out requests.
     * @param [in] requestId request id of the timed out request.
     */
    void requestTimeoutHandler(int requestId);

    /**
     * Slot to handle dispatching server notification handlers.
     * @param [in] serverMessage parsed server message.
     * NOTE: This will emit errorOccurred signal if the handler is not registered.
     */
    void dispatchHandler(const Message &serverMessage);

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

    std::unique_ptr<Dispatcher<const Message &>> dispatcher_;
    std::unique_ptr<ClientConnector> connector_;
    std::unique_ptr<RequestsController> requestController_;
};
}  // namespace strata::strataRPC
