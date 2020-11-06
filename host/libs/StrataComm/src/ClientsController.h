#pragma once

#include <QObject>
#include <QList>

#include "Client.h"
#include "logging/LoggingQtCategories.h"

namespace strata::strataComm {

class ClientsController : public QObject
{
    Q_OBJECT
public:
    ClientsController(QObject *parent = nullptr): QObject(parent) {}
    ~ClientsController(){}

    void notifyAllClients(const QJsonObject &payload); // maybe make this a slot?
    bool isRegisteredClient(const QByteArray &clientID);
    bool registerClient(const Client &client);
    bool unregisterClient(const QByteArray &clientID);

signals:
    void notifyClientSignal(const Client &client, const QJsonObject &payload);

private:
    QList<Client> clientsList_;
    // std::vector<Client> clientsList_;
};

}   // namespace strata::strataComm
