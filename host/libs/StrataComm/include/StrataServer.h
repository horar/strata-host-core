#pragma once

#include <QObject>

#include "../src/ClientsController.h"
#include "../src/ServerConnector.h"
#include "../src/Dispatcher.h"

namespace strata::strataComm {

class StrataServer : public QObject {
    Q_OBJECT

public:
    StrataServer(QString address, QObject *parent = nullptr);
    ~StrataServer();
    
    void init();
    // void start();
    // void notifyClient();
    void registerHandler(const QString &handlerName, StrataHandler handler);
    // void unregisterHandler();
public slots:
    void newClientMessage(const QByteArray &clientId, const QByteArray &message);
    void notifyClient(const ClientMessage &clientMessage, const QJsonObject &jsonObject, ClientMessage::ResponseType respnseType);
    void notifyAllClients();

signals:
    void dispatchHandler(const ClientMessage &clientMessage);

private:
    bool buildClientMessage(const QByteArray &message, ClientMessage *clientMessage);
    bool buildClientMessageApiV2(const QJsonObject &jsonObject, ClientMessage *clientMessage);
    bool buildClientMessageApiV1(const QJsonObject &jsonObject, ClientMessage *clientMessage);
    
    QByteArray buildNotificationApiv2(const ClientMessage &clientMessage, const QJsonObject &payload);
    QByteArray buildResponseApiv2(const ClientMessage &clientMessage, const QJsonObject &payload);
    QByteArray buildErrorResponseApiv2(const ClientMessage &clientMessage, const QJsonObject &payload);
    
    QByteArray buildResponseApiv1(const ClientMessage &clientMessage, const QJsonObject &payload);
    QByteArray buildPlatformMessageApiV1(const QJsonObject &payload);
    
    // QString buidNotification(const ClientMessage &ClientMessage, const QJsonObject &payload);   // maybe we need to change it to QByteArray based on what zmq requires
    // QString buildResponse(const ClientMessage &ClientMessage, const QJsonObject &payload);      // ^ same comment!

    Dispatcher dispatcher_;
    ClientsController clientsController_;
    ServerConnector connector_;

};

}   // namespace strata::strataComm
