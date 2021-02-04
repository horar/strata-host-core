#pragma once

#include <QObject>

#include "DeferredRequest.h"
#include "Message.h"

namespace strata::strataRPC
{
class Dispatcher;
class ClientConnector;
class RequestsController;

class StrataClient : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(StrataClient);

public:
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
     * @param [in] errorCallback lambda to handle error response. defaults to nullptr.
     * @param [in] resultCallback lambda to handle result response.  defaults to nullptr.
     * @return std::pair<bool, int>, Boolean to indicate if the request was sent successfully or
     * not, and an int of the request id.
     */
    std::pair<bool, std::shared_ptr<DeferredRequest>> sendRequest(const QString &method,
                                                                  const QJsonObject &payload);

signals:
    /**
     * Emitted when a new server message is parsed and ready to be handled
     * @param [in] serverMessage populated Message object with the notification meta data.
     */
    void newServerMessageParsed(const Message &serverMessage);

private slots:
    /**
     * Slot to handle new incoming messages from StrataServer.
     * @param [in] jsonServerMessage QByteArray json of StrataServer's message.
     */
    void newServerMessage(const QByteArray &jsonServerMessage);

private:
    /**
     * Parse the incoming json message from StrataServer into a Message object.
     * @param [in] jsonServerMessage QByteArray json of StrataServer's message.
     * @param [out] serverMessage populated Message object with the notification meta data.
     * @param [out] callbackHandler function pointer to the request callback if it exist.
     * @return True if the json message was parsed successfully. False otherwise.
     */
    bool buildServerMessage(const QByteArray &jsonServerMessage, Message *serverMessage,
                            std::shared_ptr<DeferredRequest> &deferredRequest);

    std::unique_ptr<Dispatcher> dispatcher_;
    std::unique_ptr<ClientConnector> connector_;
    std::unique_ptr<RequestsController> requestController_;
};
}  // namespace strata::strataRPC
