/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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

    QCOMPARE(clientsController.isRegisteredClient(client1.getClientID()), false);
    QCOMPARE(clientsController.isRegisteredClient(client2.getClientID()), false);

    QCOMPARE(clientsController.registerClient(client1), true);

    QCOMPARE(clientsController.isRegisteredClient(client1.getClientID()), true);
    QCOMPARE(clientsController.isRegisteredClient(client2.getClientID()), false);
}

void ClientsControllerTest::testRegisterClient()
{
    ClientsController clientsController;
    QList<Client> testClientsList;
    constexpr int testClientListSize = 100;

    // create a list of random clients and register them.
    for (int i = 0; i < testClientListSize; i++) {
        testClientsList.append({QByteArray::number(i), strata::strataRPC::ApiVersion::v1});
        QCOMPARE(clientsController.registerClient(testClientsList[i]), true);
    }

    for (const auto &client : testClientsList) {
        QCOMPARE(clientsController.isRegisteredClient(client.getClientID()), true);
    }
}

void ClientsControllerTest::testRegisterDublicateClient()
{
    ClientsController clientsController;
    Client client("client", strata::strataRPC::ApiVersion::v1);
    Client clientDuplicateID("client", strata::strataRPC::ApiVersion::v1);

    QCOMPARE(clientsController.isRegisteredClient(client.getClientID()), false);
    QCOMPARE(clientsController.isRegisteredClient(clientDuplicateID.getClientID()), false);

    QCOMPARE(clientsController.registerClient(client), true);
    QCOMPARE(clientsController.registerClient(clientDuplicateID), false);
}

void ClientsControllerTest::testUnregisterClient()
{
    ClientsController clientsController;
    Client client1("client_1", strata::strataRPC::ApiVersion::v1);
    Client client2("client_2", strata::strataRPC::ApiVersion::v1);

    QCOMPARE(clientsController.registerClient(client1), true);
    QCOMPARE(clientsController.registerClient(client2), true);

    QCOMPARE(clientsController.isRegisteredClient(client1.getClientID()), true);
    QCOMPARE(clientsController.isRegisteredClient(client2.getClientID()), true);

    QCOMPARE(clientsController.unregisterClient(client1.getClientID()), true);
    QCOMPARE(clientsController.unregisterClient(client2.getClientID()), true);

    QCOMPARE(clientsController.unregisterClient(client1.getClientID()), false);
    QCOMPARE(clientsController.unregisterClient(client2.getClientID()), false);
}

void ClientsControllerTest::testGetApiVersion()
{
    ClientsController clientsController;

    clientsController.registerClient(Client("AA", strata::strataRPC::ApiVersion::v1));
    clientsController.registerClient(Client("BB", strata::strataRPC::ApiVersion::v2));
    clientsController.registerClient(Client("CC", strata::strataRPC::ApiVersion::none));

    QCOMPARE(clientsController.getClientApiVersion("AA"), strata::strataRPC::ApiVersion::v1);
    QCOMPARE(clientsController.getClientApiVersion("BB"), strata::strataRPC::ApiVersion::v2);
    QCOMPARE(clientsController.getClientApiVersion("CC"), strata::strataRPC::ApiVersion::none);
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
    QCOMPARE(client.getClientID(), "AA");
    QCOMPARE(client.getApiVersion(), strata::strataRPC::ApiVersion::v1);

    clientsController.unregisterClient("AA");
    QCOMPARE(client.getClientID(), "AA");
    QCOMPARE(client.getApiVersion(), strata::strataRPC::ApiVersion::v1);
}

void ClientsControllerTest::testUpdateClientApiVersion() 
{
    ClientsController clientsController;
    clientsController.registerClient(Client("AA", strata::strataRPC::ApiVersion::v1));

    Client client = clientsController.getClient("AA");
    QCOMPARE(client.getApiVersion(), strata::strataRPC::ApiVersion::v1);

    QVERIFY(false == clientsController.updateClientApiVersion("INVALID_ID", strata::strataRPC::ApiVersion::v2));

    QVERIFY(clientsController.updateClientApiVersion("AA", strata::strataRPC::ApiVersion::v2));
    
    Client clientUpdated = clientsController.getClient("AA");
    QCOMPARE(clientUpdated.getApiVersion(), strata::strataRPC::ApiVersion::v2);
}
