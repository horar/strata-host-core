#pragma once

#include <QObject>
#include <QVector>

#include "Client.h"
#include "logging/LoggingQtCategories.h"

class ClientsController : public QObject
{
    Q_OBJECT
public:
    ClientsController(QObject *parent = nullptr);
    ~ClientsController();
    // Client &getClient(QByteArray clientID) const;
    void notifyAllClients(/* Add a payload */); // maybe make this a slot?
    bool isRegisteredClient(QByteArray clientID);
    bool registerClient(Client client);
    bool unregisterClient(Client client);

private:
    std::vector<Client> clientsList_;
    // QVector<Client> clientsList_;
};
