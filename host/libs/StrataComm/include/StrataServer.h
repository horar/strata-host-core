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

    void init(); // TODO: make it bool and use better naming
    // void start();
    // void notifyClient();
    bool registerHandler(const QString &handlerName, StrataHandler handler);
    bool unregisterHandler(const QString &handlerName);

public slots:
    void newClientMessage(const QByteArray &clientId, const QByteArray &message);
    void notifyClient(const Message &clientMessage, const QJsonObject &jsonObject, ResponseType responseType);
    void notifyAllClients(const QString &handlerName, const QJsonObject &jsonObject);

signals:
    void dispatchHandler(const Message &clientMessage);

private:
    bool buildClientMessageAPIv2(const QJsonObject &jsonObject, Message *clientMessage);
    bool buildClientMessageAPIv1(const QJsonObject &jsonObject, Message *clientMessage);

    QByteArray buildServerMessageAPIv2(const Message &clientMessage, const QJsonObject &payload, ResponseType responseType);
    QByteArray buildServerMessageAPIv1(const Message &clientMessage, const QJsonObject &payload, ResponseType responseType);

    void registerNewClientHandler(const Message &clientMessage);
    void unregisterClientHandler(const Message &clientMessage);

    Dispatcher dispatcher_;
    ClientsController clientsController_;
    ServerConnector connector_;
};

}   // namespace strata::strataComm
