#pragma once

#include <QList>
#include <QObject>

#include "Client.h"
#include "logging/LoggingQtCategories.h"

namespace strata::strataComm
{
class ClientsController : public QObject
{
    Q_OBJECT
public:
    ClientsController(QObject *parent = nullptr) : QObject(parent)
    {
    }
    ~ClientsController()
    {
    }

    void notifyAllClients(const QString &handlerName,
                          const QJsonObject &payload);
    QList<Client> getAllClients();
    bool isRegisteredClient(const QByteArray &clientID);
    bool registerClient(const Client &client);
    bool unregisterClient(const QByteArray &clientID);
    ApiVersion getClientApiVersion(const QByteArray &clientID);
    Client getClient(const QByteArray &clientID);
signals:
    void notifyClientSignal(const Client &client, const QString &handlerName,
                            const QJsonObject &payload);

private:
    QList<Client> clientsList_;
};

}  // namespace strata::strataComm
