#pragma once

#include <QObject>

#include "../src/ClientConnector.h"
#include "../src/Dispatcher.h"
#include "../src/RequestsController.h"

namespace strata::strataComm
{
class StrataClient : public QObject
{
    Q_OBJECT

public:
    StrataClient(QString serverAddress, QObject *parent = nullptr);
    StrataClient(QString serverAddress, QByteArray dealerId, QObject *parent = nullptr);
    ~StrataClient();

    bool connectServer();
    bool disconnectServer();
    bool registerHandler(const QString &handlerName, StrataHandler handler);
    bool unregisterHandler(const QString &handlerName);
    bool sendRequest(const QString &method, const QJsonObject &payload);

signals:
    void dispatchHandler(const ClientMessage &ClientMessage);
    void sendMessage(const QByteArray &message);

private slots:
    void newServerMessage(const QByteArray &serverMessage);

private:
    bool buildServerMessage(const QByteArray &serverMessage, ClientMessage *clientMessage);

    Dispatcher dispatcher_;
    ClientConnector connector_;
    RequestsController requestController_;
};
}  // namespace strata::strataComm
