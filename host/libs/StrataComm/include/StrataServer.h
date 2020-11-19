#pragma once

#include <QObject>

#include "../src/ClientsController.h"
#include "../src/Dispatcher.h"
#include "../src/ServerConnector.h"

namespace strata::strataComm {

class StrataServer : public QObject {
    Q_OBJECT

public:
    StrataServer(QString address, QObject *parent = nullptr);
    ~StrataServer();

    void init();
    // void start();
    // void notifyClient();
    bool registerHandler(const QString &handlerName, StrataHandler handler);
    bool unregisterHandler(const QString &handlerName);

public slots:
    void newClientMessage(const QByteArray &clientId, const QByteArray &message);
    void notifyClient(const ClientMessage &clientMessage, const QJsonObject &jsonObject, ClientMessage::ResponseType responseType);
    void notifyAllClients(const QString &handlerName, const QJsonObject &jsonObject);

signals:
    void dispatchHandler(const ClientMessage &clientMessage);

private:
    bool buildClientMessageAPIv2(const QJsonObject &jsonObject, ClientMessage *clientMessage);
    bool buildClientMessageAPIv1(const QJsonObject &jsonObject, ClientMessage *clientMessage);

    QByteArray buildServerMessageAPIv2(const ClientMessage &clientMessage, const QJsonObject &payload, ClientMessage::ResponseType responseType);
    QByteArray buildServerMessageAPIv1(const ClientMessage &clientMessage, const QJsonObject &payload, ClientMessage::ResponseType responseType);

    // QString buidNotification(const ClientMessage &ClientMessage, const QJsonObject &payload);   // maybe we need to change it to QByteArray based on what zmq requires
    // QString buildResponse(const ClientMessage &ClientMessage, const QJsonObject &payload);      // ^ same comment!

    void registerNewClientHandler(const ClientMessage &clientMessage);
    void unregisterClientHandler(const ClientMessage &clientMessage);

    Dispatcher dispatcher_;
    ClientsController clientsController_;
    ServerConnector connector_;
};

}   // namespace strata::strataComm
