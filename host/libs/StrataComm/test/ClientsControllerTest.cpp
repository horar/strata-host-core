#include "ClientsControllerTest.h"

void ClientsControllerTest::notifyClientMock(const Client &client, const QString &handlerName,
                                             const QJsonObject &payload)
{
    qDebug() << "Sending " << payload << "To Client ID: " << client.getClientID()
             << " API Version: " << static_cast<int>(client.getApiVersion())
             << " Handler: " << handlerName;
}

void ClientsControllerTest::testIsRegisteredClient()
{
    ClientsController clientsController;

    Client client1("client_1", strata::strataComm::ApiVersion::v1);
    Client client2("client_2", strata::strataComm::ApiVersion::v1);

    QCOMPARE_(clientsController.isRegisteredClient(client1.getClientID()), false);
    QCOMPARE_(clientsController.isRegisteredClient(client2.getClientID()), false);

    QCOMPARE_(clientsController.registerClient(client1), true);

    QCOMPARE_(clientsController.isRegisteredClient(client1.getClientID()), true);
    QCOMPARE_(clientsController.isRegisteredClient(client2.getClientID()), false);
}

void ClientsControllerTest::testRegisterClient()
{
    ClientsController clientsController;
    QList<Client> testClientsList;
    constexpr int testClientListSize = 100;

    // create a list of random clients and register them.
    for (int i = 0; i < testClientListSize; i++) {
        testClientsList.append({QByteArray::number(i), strata::strataComm::ApiVersion::v1});
        QCOMPARE_(clientsController.registerClient(testClientsList[i]), true);
    }

    for (const auto &client : testClientsList) {
        QCOMPARE_(clientsController.isRegisteredClient(client.getClientID()), true);
    }
}

void ClientsControllerTest::testRegisterDublicateClient()
{
    ClientsController clientsController;
    Client client("client", strata::strataComm::ApiVersion::v1);
    Client clientDuplicateID("client", strata::strataComm::ApiVersion::v1);

    QCOMPARE_(clientsController.isRegisteredClient(client.getClientID()), false);
    QCOMPARE_(clientsController.isRegisteredClient(clientDuplicateID.getClientID()), false);

    QCOMPARE_(clientsController.registerClient(client), true);
    QCOMPARE_(clientsController.registerClient(clientDuplicateID), false);
}

void ClientsControllerTest::testUnregisterClient()
{
    ClientsController clientsController;
    Client client1("client_1", strata::strataComm::ApiVersion::v1);
    Client client2("client_2", strata::strataComm::ApiVersion::v1);

    QCOMPARE_(clientsController.registerClient(client1), true);
    QCOMPARE_(clientsController.registerClient(client2), true);

    QCOMPARE_(clientsController.isRegisteredClient(client1.getClientID()), true);
    QCOMPARE_(clientsController.isRegisteredClient(client2.getClientID()), true);

    QCOMPARE_(clientsController.unregisterClient(client1.getClientID()), true);
    QCOMPARE_(clientsController.unregisterClient(client2.getClientID()), true);

    QCOMPARE_(clientsController.unregisterClient(client1.getClientID()), false);
    QCOMPARE_(clientsController.unregisterClient(client2.getClientID()), false);
}

void ClientsControllerTest::testNotifyAllCleints()
{
    ClientsController clientsController;
    QSignalSpy signalSpy(&clientsController, &ClientsController::notifyClientSignal);

    connect(&clientsController, &ClientsController::notifyClientSignal, this,
            &ClientsControllerTest::notifyClientMock);

    clientsController.registerClient(Client("AA", strata::strataComm::ApiVersion::v1));
    clientsController.registerClient(Client("BB", strata::strataComm::ApiVersion::v2));
    clientsController.registerClient(Client("CC", strata::strataComm::ApiVersion::v2));
    clientsController.registerClient(Client("DD", strata::strataComm::ApiVersion::v1));
    clientsController.registerClient(Client("EE", strata::strataComm::ApiVersion::v2));

    clientsController.notifyAllClients("test", QJsonObject({{"key", 1}}));

    QCOMPARE_(signalSpy.count(), 5);

    disconnect(&clientsController, &ClientsController::notifyClientSignal, this,
               &ClientsControllerTest::notifyClientMock);
}

void ClientsControllerTest::testGetApiVersion()
{
    ClientsController clientsController;

    clientsController.registerClient(Client("AA", strata::strataComm::ApiVersion::v1));
    clientsController.registerClient(Client("BB", strata::strataComm::ApiVersion::v2));
    clientsController.registerClient(Client("CC", strata::strataComm::ApiVersion::none));

    QCOMPARE_(clientsController.getClientApiVersion("AA"), strata::strataComm::ApiVersion::v1);
    QCOMPARE_(clientsController.getClientApiVersion("BB"), strata::strataComm::ApiVersion::v2);
    QCOMPARE_(clientsController.getClientApiVersion("CC"), strata::strataComm::ApiVersion::none);
}

void ClientsControllerTest::testGetClient()
{
    ClientsController clientsController;

    clientsController.registerClient(Client("AA", strata::strataComm::ApiVersion::v1));
    clientsController.registerClient(Client("BB", strata::strataComm::ApiVersion::v2));
    clientsController.registerClient(Client("CC", strata::strataComm::ApiVersion::v2));
    clientsController.registerClient(Client("DD", strata::strataComm::ApiVersion::v2));
    clientsController.registerClient(Client("EE", strata::strataComm::ApiVersion::v2));

    Client client = clientsController.getClient("AA");
    QCOMPARE_(client.getClientID(), "AA");
    QCOMPARE_(client.getApiVersion(), strata::strataComm::ApiVersion::v1);

    clientsController.unregisterClient("AA");
    QCOMPARE_(client.getClientID(), "AA");
    QCOMPARE_(client.getApiVersion(), strata::strataComm::ApiVersion::v1);
}
