#include "ClientsControllerTest.h"

QTEST_MAIN(ClientsControllerTest)

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

    Client client1("client_1", strata::strataRPC::ApiVersion::v1);
    Client client2("client_2", strata::strataRPC::ApiVersion::v1);

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
        testClientsList.append({QByteArray::number(i), strata::strataRPC::ApiVersion::v1});
        QCOMPARE_(clientsController.registerClient(testClientsList[i]), true);
    }

    for (const auto &client : testClientsList) {
        QCOMPARE_(clientsController.isRegisteredClient(client.getClientID()), true);
    }
}

void ClientsControllerTest::testRegisterDublicateClient()
{
    ClientsController clientsController;
    Client client("client", strata::strataRPC::ApiVersion::v1);
    Client clientDuplicateID("client", strata::strataRPC::ApiVersion::v1);

    QCOMPARE_(clientsController.isRegisteredClient(client.getClientID()), false);
    QCOMPARE_(clientsController.isRegisteredClient(clientDuplicateID.getClientID()), false);

    QCOMPARE_(clientsController.registerClient(client), true);
    QCOMPARE_(clientsController.registerClient(clientDuplicateID), false);
}

void ClientsControllerTest::testUnregisterClient()
{
    ClientsController clientsController;
    Client client1("client_1", strata::strataRPC::ApiVersion::v1);
    Client client2("client_2", strata::strataRPC::ApiVersion::v1);

    QCOMPARE_(clientsController.registerClient(client1), true);
    QCOMPARE_(clientsController.registerClient(client2), true);

    QCOMPARE_(clientsController.isRegisteredClient(client1.getClientID()), true);
    QCOMPARE_(clientsController.isRegisteredClient(client2.getClientID()), true);

    QCOMPARE_(clientsController.unregisterClient(client1.getClientID()), true);
    QCOMPARE_(clientsController.unregisterClient(client2.getClientID()), true);

    QCOMPARE_(clientsController.unregisterClient(client1.getClientID()), false);
    QCOMPARE_(clientsController.unregisterClient(client2.getClientID()), false);
}

void ClientsControllerTest::testGetApiVersion()
{
    ClientsController clientsController;

    clientsController.registerClient(Client("AA", strata::strataRPC::ApiVersion::v1));
    clientsController.registerClient(Client("BB", strata::strataRPC::ApiVersion::v2));
    clientsController.registerClient(Client("CC", strata::strataRPC::ApiVersion::none));

    QCOMPARE_(clientsController.getClientApiVersion("AA"), strata::strataRPC::ApiVersion::v1);
    QCOMPARE_(clientsController.getClientApiVersion("BB"), strata::strataRPC::ApiVersion::v2);
    QCOMPARE_(clientsController.getClientApiVersion("CC"), strata::strataRPC::ApiVersion::none);
}

void ClientsControllerTest::testGetClient()
{
    ClientsController clientsController;

    clientsController.registerClient(Client("AA", strata::strataRPC::ApiVersion::v1));
    clientsController.registerClient(Client("BB", strata::strataRPC::ApiVersion::v2));
    clientsController.registerClient(Client("CC", strata::strataRPC::ApiVersion::v2));
    clientsController.registerClient(Client("DD", strata::strataRPC::ApiVersion::v2));
    clientsController.registerClient(Client("EE", strata::strataRPC::ApiVersion::v2));

    Client client = clientsController.getClient("AA");
    QCOMPARE_(client.getClientID(), "AA");
    QCOMPARE_(client.getApiVersion(), strata::strataRPC::ApiVersion::v1);

    clientsController.unregisterClient("AA");
    QCOMPARE_(client.getClientID(), "AA");
    QCOMPARE_(client.getApiVersion(), strata::strataRPC::ApiVersion::v1);
}

void ClientsControllerTest::testUpdateClientApiVersion() 
{
    ClientsController clientsController;
    clientsController.registerClient(Client("AA", strata::strataRPC::ApiVersion::v1));

    Client client = clientsController.getClient("AA");
    QCOMPARE_(client.getApiVersion(), strata::strataRPC::ApiVersion::v1);

    QVERIFY_(false == clientsController.updateClientApiVersion("INVALID_ID", strata::strataRPC::ApiVersion::v2));

    QVERIFY_(clientsController.updateClientApiVersion("AA", strata::strataRPC::ApiVersion::v2));
    
    Client clientUpdated = clientsController.getClient("AA");
    QCOMPARE_(clientUpdated.getApiVersion(), strata::strataRPC::ApiVersion::v2);
}
