#pragma once

#include <QObject>
#include <QSignalSpy>

#include "ClientsController.h"
#include "QtTest.h"

using strata::strataRPC::Client;
using strata::strataRPC::ClientsController;

class ClientsControllerTest : public QObject
{
    Q_OBJECT
public:
public slots:
    void notifyClientMock(const Client &client, const QString &handlerName,
                          const QJsonObject &payload);

private slots:
    void testIsRegisteredClient();
    void testRegisterClient();
    void testRegisterDublicateClient();
    void testUnregisterClient();
    void testGetApiVersion();
    void testGetClient();

private:
    ClientsController *clientsController_;
};