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
#include <functional>
#include <chrono>
#include <QTimer>

#include "DeferredReply.h"
#include "RpcError.h"

class QThread;

namespace strata::strataRPC
{
template <class HandlerArgument>
class Dispatcher;
class ClientConnector;

static constexpr std::chrono::milliseconds default_check_reply_interval = std::chrono::seconds(1);
static constexpr std::chrono::milliseconds default_reply_expiration_time = std::chrono::seconds(2);

class StrataClient : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(StrataClient);

public:
    typedef std::function<void(const QJsonObject &)> ClientHandler;

    /**
     * StrataClient constructor
     * @param [in] serverAddress Sets the server address.
     * @param [in] dealerId Sets the client id.
     */
    StrataClient(
            const QString &serverAddress,
            const QByteArray &dealerId = "StrataClient",
            std::chrono::milliseconds checkReplyInterval = default_check_reply_interval,
            std::chrono::milliseconds replyExpirationTime = default_reply_expiration_time,
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
    void initializeAndConnect();

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
     * @param [in] params QJsonObject of the request params.
     * @return pointer to DeferredRequest to connect callbacks, on failure, this will return
     * nullptr
     */
    Q_INVOKABLE strata::strataRPC::DeferredReply* sendRequest(
            const QString &method,
            const QJsonObject &params);

    /**
     * Sends a notification to the server.
     * @note The response is handled by the registered handlers in the dispatcher.
     * @param [in] method The handler name in StrataServer.
     * @param [in] params QJsonObject of the request params.
     */
    Q_INVOKABLE void sendNotification(
            const QString &method,
            const QJsonObject &params);

signals:
    /**
     * Emitted when the client connects to the server successfully.
     */
    void connected();

    /**
     * Emitted when the client is disconnected from the server.
     */
    void disconnected();

    /**
     * Emitted when an error has occurred. For testing purposes only.
     * @param [in] errorType error category description.
     * @param [in] errorMessage QString of the actual error.
     */
    void errorOccurred(const strata::strataRPC::RpcErrorCode code);

private slots:
    /**
     * Slot to handle new incoming messages from StrataServer.
     * @param [in] jsonServerMessage QByteArray json of StrataServer's message.
     */
    void processMessageFromServer(const QByteArray &message);

    /**
     * Removes expired replies.
     */
    void removeExpiredReplies();

    /**
     * Slot to handle initialized signal from ClientConnector by sending register_client
     * message to the server.
     */
    void clientInitializedHandler();

private:
    QByteArray buildRequestMessage(
            int id,
            const QString &method,
            const QJsonObject &params);

    QByteArray buildNotificationMessage(
            const QString &method,
            const QJsonObject &params);

    void processResult(int id, const QJsonObject &result);
    void processError(int id, const QJsonObject &error);
    void processNotification(const QString &method, const QJsonObject &params);
    int getNextRequestId();
    void sendMessageToConnector(const QByteArray &message);

    std::unique_ptr<Dispatcher<const QJsonObject &>> dispatcher_;
    std::unique_ptr<ClientConnector> connector_;
    std::unique_ptr<QThread> connectorThread_;

    QHash<int /*id*/, DeferredReply*> replies_;
    int nextRequestId_ = 0;

    QTimer expiredReplyTimer_;
    std::chrono::milliseconds replyExpirationTime_;
};

}  // namespace strata::strataRPC
