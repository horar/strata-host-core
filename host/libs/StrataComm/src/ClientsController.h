#pragma once

#include <QObject>
#include <QVector>

#include "Client.h"
#include "logging/LoggingQtCategories.h"

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
    std::vector<Client> clientsList_;
};
