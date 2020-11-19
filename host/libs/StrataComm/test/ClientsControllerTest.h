#pragma once

#include <QObject>
#include <QSignalSpy>

#include "QtTest.h"
#include "../src/ClientsController.h"

using strata::strataComm::ClientsController;
using strata::strataComm::Client;

class ClientsControllerTest : public QObject {
    Q_OBJECT
public:

public slots:
    void notifyClientMock(const Client &client, const QString &handlerName, const QJsonObject &payload);

private slots:
    void testIsRegisteredClient();
    void testRegisterClient();
    void testRegisterDublicateClient();
    void testUnregisterClient();
    void testNotifyAllCleints();
    void testGetApiVersion();
    void testGetClient();

private:
    ClientsController *clientsController_;
};