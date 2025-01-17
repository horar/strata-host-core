/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "ClientConnector.h"
#include "Dispatcher.h"
#include "logging/LoggingQtCategories.h"
#include <StrataRPC/StrataClient.h>
#include <QJsonDocument>
#include <QThread>
#include <QDateTime>

namespace strata::strataRPC
{

StrataClient::StrataClient(
        const QString &serverAddress,
        const QByteArray &dealerId,
        std::chrono::milliseconds checkReplyInterval,
        std::chrono::milliseconds replyExpirationTime,
        QObject *parent)
    : QObject(parent),
      dispatcher_(new Dispatcher<const QJsonObject &>()),
      connector_(new ClientConnector(serverAddress, dealerId)),
      connectorThread_(new QThread()),
      replyExpirationTime_(replyExpirationTime)
{
    connector_->moveToThread(connectorThread_.get());

    QObject::connect(
                connector_.get(),
                &ClientConnector::messageReceived,
                this,
                &StrataClient::processMessageFromServer);

    QObject::connect(
                connector_.get(),
                &ClientConnector::errorOccurred,
                this,
                &StrataClient::errorOccurred);

    QObject::connect(
                connector_.get(),
                &ClientConnector::initialized,
                this,
                &StrataClient::clientInitializedHandler);

    QObject::connect(
                connector_.get(),
                &ClientConnector::disconnected,
                this,
                [this]() { emit disconnected(); });

    QObject::connect(
                &expiredReplyTimer_,
                &QTimer::timeout,
                this,
                &StrataClient::removeExpiredReplies);

    connectorThread_->start();

    expiredReplyTimer_.start(checkReplyInterval);
}

StrataClient::~StrataClient()
{
    connector_->deleteLater();
    connector_.release();

    connectorThread_->exit(0);
    if (false == connectorThread_->wait(500)) {
        qCCritical(lcStrataClient) << "Terminating connector thread.";
        connectorThread_->terminate();
    }

    connectorThread_->deleteLater();
    connectorThread_.release();

    qDeleteAll(replies_);
    replies_.clear();
}

void StrataClient::initializeAndConnect()
{
    QMetaObject::invokeMethod(connector_.get(), &ClientConnector::initialize, Qt::QueuedConnection);
}

void StrataClient::disconnect()
{
    QMetaObject::invokeMethod(connector_.get(), &ClientConnector::disconnect, Qt::QueuedConnection);
}

void StrataClient::processMessageFromServer(const QByteArray &message)
{
    qCDebug(lcStrataServer).noquote().nospace()
        << "message: '" << message << "'";

    QJsonParseError jsonParseError;
    QJsonDocument jsonDocument = QJsonDocument::fromJson(message, &jsonParseError);
    if (jsonParseError.error != QJsonParseError::NoError) {
        qCCritical(lcStrataClient).noquote().nospace()
                << "invalid jsonrpc message received "
                << jsonParseError.error
                << " "
                << jsonParseError.errorString()
                << ", message:" << message;

        return;
    }

    QJsonObject messageObject = jsonDocument.object();

    //jsonrpc
    QString jsonVersion = messageObject.value("jsonrpc").toString();
    if (jsonVersion.isEmpty() || jsonVersion != "2.0") {
        qCCritical(lcStrataClient).noquote().nospace()
                << "invalid jsonrpc message received"
                << ", message:" << message;
        return;
    }

    if (messageObject.contains("result") && messageObject.contains("id")) {
        //reply with result
        QJsonValue idValue = messageObject.value("id");
        if (idValue.isDouble() == false) {
            qCCritical(lcStrataClient).noquote().nospace()
                    << "invalid jsonrpc message received"
                    << ", message:" << message;
            return;
        }

        processResult(idValue.toInt(), messageObject.value("result").toObject());
    } else if (messageObject.contains("error") && messageObject.contains("id")) {
        //reply with error
        QJsonValue errorValue = messageObject.value("error");
        if (errorValue.isObject() == false) {
            qCCritical(lcStrataClient).noquote().nospace()
                    << "invalid jsonrpc message received"
                    << ", message:" << message;
            return;
        }

        QJsonValue idValue = messageObject.value("id");
        if (idValue.isNull()) {
            //id can be null if there was problem to parse request on server side
            //there is nothing we can do, original request will expire

            qCCritical(lcStrataClient).noquote().nospace()
                    << "invalid jsonrpc message received"
                    << ", message:" << message;
            return;
        }

        if (idValue.isDouble() == false) {
            qCCritical(lcStrataClient).noquote().nospace()
                    << "invalid jsonrpc message received"
                    << ", message:" << message;
            return;
        }

        processError(idValue.toInt(), errorValue.toObject());
    } else if (messageObject.contains("method") && messageObject.contains("params")) {
        //notification
        QJsonValue methodValue = messageObject.value("method");
        if (methodValue.isString() == false) {
            qCCritical(lcStrataClient).noquote().nospace()
                    << "invalid jsonrpc message received"
                    << ", message:" << message;
            return;
        }

        QJsonValue paramsValue = messageObject.value("params");
        if (paramsValue.isObject() == false) {
            qCCritical(lcStrataClient).noquote().nospace()
                    << "invalid jsonrpc message received"
                    << ", message:" << message;
            return;
        }

        processNotification(methodValue.toString(), paramsValue.toObject());
    } else {
        qCCritical(lcStrataClient).noquote().nospace()
                << "invalid jsonrpc message received"
                << ", message:" << message;
        return;
    }
}

bool StrataClient::registerHandler(const QString &handlerName, ClientHandler handler)
{
    qCDebug(lcStrataClient) << "Registering Handler:" << handlerName;
    if (false == dispatcher_->registerHandler(handlerName, handler)) {
        qCCritical(lcStrataClient) << "Failed to register handler.";
        emit errorOccurred(RpcErrorCode::HandlerRegistrationError);
        return false;
    }
    return true;
}

bool StrataClient::unregisterHandler(const QString &handlerName)
{
    qCDebug(lcStrataClient) << "Unregistering handler:" << handlerName;
    if (false == dispatcher_->unregisterHandler(handlerName)) {
        qCCritical(lcStrataClient) << "Failed to unregister handler.";
        emit errorOccurred(RpcErrorCode::HandlerUnregistrationError);
        return false;
    }
    return true;
}

DeferredReply* StrataClient::sendRequest(const QString &method, const QJsonObject &params)
{
    qCDebug(lcStrataClient) << method << params;

    int id = getNextRequestId();

    QByteArray message = buildRequestMessage(id, method, params);

    DeferredReply *deferred = new DeferredReply(this);
    if (deferred == nullptr) {
        qCCritical(lcStrataClient) << "failed to create DeferredReply object";
        return nullptr;
    }

    deferred->setId(id);
    deferred->setMethod(method);
    deferred->setParams(params);
    deferred->setTimestamp(QDateTime::currentMSecsSinceEpoch());

    replies_.insert(id, deferred);

    sendMessageToConnector(message);

    return deferred;
}

void StrataClient::sendNotification(const QString &method, const QJsonObject &params)
{
    qCDebug(lcStrataClient) << method << params;

    QByteArray message = buildNotificationMessage(method, params);
    sendMessageToConnector(message);
}

QByteArray StrataClient::buildRequestMessage(int id, const QString &method, const QJsonObject &params)
{
    QJsonObject jsonObject;
    jsonObject.insert("jsonrpc", "2.0");
    jsonObject.insert("id", id);
    jsonObject.insert("method", method);
    jsonObject.insert("params", params);

    return QJsonDocument(jsonObject).toJson(QJsonDocument::JsonFormat::Compact);
}

QByteArray StrataClient::buildNotificationMessage(const QString &method, const QJsonObject &params)
{
    QJsonObject jsonObject;
    jsonObject.insert("jsonrpc", "2.0");
    jsonObject.insert("method", method);
    jsonObject.insert("params", params);

    return QJsonDocument(jsonObject).toJson(QJsonDocument::JsonFormat::Compact);
}

QJsonObject StrataClient::buildErrorPayload(const RpcError &error)
{
    QJsonObject jsonObject;
    jsonObject.insert("code", error.code());
    jsonObject.insert("message", error.message());

    return jsonObject;
}

void StrataClient::processResult(int id, const QJsonObject &result)
{
    if (replies_.contains(id) == false) {
        qCCritical(lcStrataClient) << "unknown id" << id;
        return;
    }

    DeferredReply *reply = replies_.value(id);
    reply->callSuccessCallback(result);

    replies_.remove(id);
    reply->deleteLater();
}

void StrataClient::processError(int id, const QJsonObject &error)
{
    if (replies_.contains(id) == false) {
        qCCritical(lcStrataClient) << "unknown id" << id;
        return;
    }

    DeferredReply *reply = replies_.value(id);
    reply->callErrorCallback(error);

    replies_.remove(reply->id());
    reply->disconnect();
    reply->deleteLater();

    RpcErrorCode code = static_cast<RpcErrorCode>(error.value("code").toInt());
    emit errorOccurred(code);
}


void StrataClient::processNotification(const QString &method, const QJsonObject &params)
{
    bool dispatched = dispatcher_->dispatch(method, params);
    if (dispatched == false) {
        qCCritical(lcStrataClient) << "handler for notification not found" << method;
        emit errorOccurred(RpcErrorCode::MethodNotFoundError);
        return;
    }
}

int StrataClient::getNextRequestId()
{
    return nextRequestId_++;
}

void StrataClient::sendMessageToConnector(const QByteArray &message)
{
    QMetaObject::invokeMethod(
                connector_.get(),
                [=](){connector_->sendMessage(message);},
                Qt::QueuedConnection);
}

void StrataClient::removeExpiredReplies()
{
    qint64 currentTime = QDateTime::currentMSecsSinceEpoch();

    QMutableHashIterator<int, DeferredReply*> iter(replies_);
    while (iter.hasNext()) {
        iter.next();
        qint64 duration = currentTime - iter.value()->timestamp();
        if (duration > replyExpirationTime_.count()) {
            qCInfo(lcStrataClient) << "reply timeout expired, id=" << iter.value()->id();
            RpcError error(RpcErrorCode::ReplyTimeoutError);
            processError(iter.value()->id(), buildErrorPayload(error));
        }
    }
}

void StrataClient::clientInitializedHandler()
{
    emit connected();
}

} // namespace strata::strataRPC
