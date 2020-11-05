#include "ClientsControllerTest.h"

void ClientsControllerTest::notifyClientMock(const Client &client, const QJsonObject &payload) {
    qDebug() << "Sending " << payload << "To Client ID: " << client.getClientID() << " API Version: " << client.getApiVersion();
}

void ClientsControllerTest::testIsRegisteredClient() {
    ClientsController clientsController;
    Client client1("client_1", "v1.0.0");
    Client client2("client_2", "v1.0.0");

    QCOMPARE_(clientsController.isRegisteredClient(client1.getClientID()), false);
    QCOMPARE_(clientsController.isRegisteredClient(client2.getClientID()), false);

    QCOMPARE_(clientsController.registerClient(client1), true);

    QCOMPARE_(clientsController.isRegisteredClient(client1.getClientID()), true);
    QCOMPARE_(clientsController.isRegisteredClient(client2.getClientID()), false);
}

void ClientsControllerTest::testRegisterClient() {
    ClientsController clientsController;
    QList<Client> testClientsList;
    constexpr int testClientListSize = 100;

    // create a list of random clients and register them.
    for (int i=0; i<testClientListSize; i++) {
        testClientsList.append({QByteArray::number(i), "v1.0.0"});
        QCOMPARE_(clientsController.registerClient(testClientsList[i]), true);
    }

    for(const auto &client : testClientsList) {
        QCOMPARE_(clientsController.isRegisteredClient(client.getClientID()), true);
    }
}

void ClientsControllerTest::testRegisterDublicateClient() {
    ClientsController clientsController;
    Client client("client", "v1.0.0");
    Client clientDuplicateID("client", "v2.0.0");

    QCOMPARE_(clientsController.isRegisteredClient(client.getClientID()), false);
    QCOMPARE_(clientsController.isRegisteredClient(clientDuplicateID.getClientID()), false);

    QCOMPARE_(clientsController.registerClient(client), true);
    QCOMPARE_(clientsController.registerClient(clientDuplicateID), false);
}

void ClientsControllerTest::testUnregisterClient() {
    ClientsController clientsController;
    Client client1("client_1", "v1.0.0");
    Client client2("client_2", "v1.0.0");

    QCOMPARE_(clientsController.registerClient(client1), true);
    QCOMPARE_(clientsController.registerClient(client2), true);

    QCOMPARE_(clientsController.isRegisteredClient(client1.getClientID()), true);
    QCOMPARE_(clientsController.isRegisteredClient(client2.getClientID()), true);

    QCOMPARE_(clientsController.unregisterClient(client1.getClientID()), true);
    QCOMPARE_(clientsController.unregisterClient(client2.getClientID()), true);

    QCOMPARE_(clientsController.unregisterClient(client1.getClientID()), false);
    QCOMPARE_(clientsController.unregisterClient(client2.getClientID()), false);
}

void ClientsControllerTest::testNotifyAllCleints() {
    ClientsController clientsController;
    QSignalSpy signalSpy(&clientsController, &ClientsController::notifyClientSignal);
    
    connect(&clientsController, &ClientsController::notifyClientSignal, this, &ClientsControllerTest::notifyClientMock);

    clientsController.registerClient(Client("AA", "v1.0"));
    clientsController.registerClient(Client("BB", "v2.0"));
    clientsController.registerClient(Client("CC", "v3.0"));
    clientsController.registerClient(Client("DD", "v4.0"));
    clientsController.registerClient(Client("EE", "v5.0"));

    clientsController.notifyAllClients(QJsonObject({{"key", 1}}));

    QCOMPARE_(signalSpy.count(), 5);
    
    disconnect(&clientsController, &ClientsController::notifyClientSignal, this, &ClientsControllerTest::notifyClientMock);
}
