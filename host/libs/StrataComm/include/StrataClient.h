#pragma once

#include <QObject>

#include "../src/Dispatcher.h"
#include "../src/ClientConnector.h"

namespace strata::strataComm {

class StrataClient : public QObject {
    Q_OBJECT

public:
    StrataClient(QString serverAddress, QObject *parent = nullptr);
    ~StrataClient();

    bool connectServer();
    bool disconnectServer();
    bool registerHandler(const QString &handlerName, StrataHandler handler);
    bool unregisterHandler(const QString &handlerName);

signals:
    void dispatchHandler(const ClientMessage &ClientMessage); // maybe implement an overload or find an alternative way to do this.
    void sendMessage(const QByteArray &message);

private slots:
    void newServerMessage(const QByteArray &serverMessage);

private:
    Dispatcher dispatcher_;
    ClientConnector connector_;
};

}   // namespace strata::strataComm
