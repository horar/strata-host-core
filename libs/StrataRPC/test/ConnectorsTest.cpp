/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "ConnectorsTest.h"

#include <QSignalSpy>
#include <QVector>

QTEST_MAIN(ConnectorsTest)

using strata::strataRPC::ServerConnector;
using strata::strataRPC::ClientConnector;

constexpr int zmqWaitTimeSuccess = 250; // newarly always skipped, will never wait this long unless CPU is stalled
constexpr int zmqWaitTime = 50;         // will always wait this long checking for failures, etc

void ConnectorsTest::waitForZmqMessages(int delay)
{
    QTimer timer;

    // wait for the messages
    timer.setSingleShot(true);
    timer.start(delay);
    do {
        QCoreApplication::processEvents(QEventLoop::WaitForMoreEvents);
    } while (timer.isActive());
}

void ConnectorsTest::testOpenServerConnectorFaild()
{
    ServerConnector connector(address_);
    QSignalSpy serverConnected_1(&connector, &ServerConnector::initialized);
    QSignalSpy errorOccured_1(&connector, &ServerConnector::errorOccurred);
    QVERIFY(serverConnected_1.isValid());
    QVERIFY(errorOccured_1.isValid());
    QCOMPARE(connector.initialize(), true);
    QVERIFY((serverConnected_1.count() == 1) || (serverConnected_1.wait(zmqWaitTimeSuccess) == true));
    QVERIFY((errorOccured_1.count() == 0) && (errorOccured_1.wait(zmqWaitTime) == false));

    ServerConnector connectorDublicate(address_);
    QSignalSpy serverConnected_2(&connectorDublicate, &ServerConnector::initialized);
    QSignalSpy errorOccured_2(&connectorDublicate, &ServerConnector::errorOccurred);
    QVERIFY(serverConnected_2.isValid());
    QVERIFY(errorOccured_2.isValid());
    QCOMPARE(connectorDublicate.initialize(), false);
    QVERIFY((serverConnected_2.count() == 0) && (serverConnected_2.wait(zmqWaitTime) == false));
    QVERIFY((errorOccured_2.count() == 1) || (errorOccured_2.wait(zmqWaitTimeSuccess) == true));
    auto errorType =
        qvariant_cast<strata::strataRPC::ServerConnectorError>(errorOccured_2.takeFirst().at(0));
    QCOMPARE(errorType, strata::strataRPC::ServerConnectorError::FailedToInitialize);
}

void ConnectorsTest::testServerAndClient()
{
    QTimer timer;
    bool testPassed = false;
    ServerConnector server(address_);
    QSignalSpy serverInitialized(&server, &ServerConnector::initialized);
    QVERIFY(serverInitialized.isValid());
    QCOMPARE(server.initialize(), true);
    QVERIFY((serverInitialized.count() == 1) || (serverInitialized.wait(zmqWaitTimeSuccess) == true));

    QByteArray client_id = "client_1";
    ClientConnector client(address_, client_id);

    QSignalSpy clientConnected(&client, &ClientConnector::connected);
    QSignalSpy clientInitialized(&client, &ClientConnector::initialized);
    QVERIFY(clientConnected.isValid());
    QVERIFY(clientInitialized.isValid());

    QCOMPARE(client.initialize(), true);

    QVERIFY((clientConnected.count() == 1) || (clientConnected.wait(zmqWaitTimeSuccess) == true));
    QVERIFY((clientInitialized.count() == 1) || (clientInitialized.wait(zmqWaitTimeSuccess) == true));
    QCOMPARE(client.isConnected(), true);

    connect(&server, &ServerConnector::messageReceived, this,
            [&server](const QByteArray &clientId, const QByteArray &message) {
                QCOMPARE(clientId, "client_1");
                if (message == "Start Test") {
                    server.sendMessage(clientId, "Hello from ServerConnector!");
                }
            });

    connect(&client, &ClientConnector::messageReceived, this,
            [&client, &timer, &testPassed]() {
                client.sendMessage("Hello from ClientConnector!");
                testPassed = true;
                timer.stop();
            });

    client.sendMessage("Start Test");

    // wait for the messages
    timer.setSingleShot(true);
    timer.start(zmqWaitTimeSuccess);
    do {
        QCoreApplication::processEvents(QEventLoop::WaitForMoreEvents);
    } while (timer.isActive());

    QVERIFY(testPassed);
}

void ConnectorsTest::testMultipleClients()
{
    int count = 15;
    int clientMessages = 0;
    int serverMessages = 0;
    ServerConnector server(address_);
    QSignalSpy serverInitialized(&server, &ServerConnector::initialized);
    QVERIFY(serverInitialized.isValid());
    QCOMPARE(server.initialize(), true);
    QVERIFY((serverInitialized.count() == 1) || (serverInitialized.wait(zmqWaitTimeSuccess) == true));

    connect(&server, &ServerConnector::messageReceived, this,
            [&serverMessages, &server](const QByteArray &clientId, const QString &) {
                ++serverMessages;
                server.sendMessage(clientId, clientId);
            });

    std::vector<ClientConnector *> clientsList;
    for (int i = 0; i < count; i++) {
        ClientConnector* client = new ClientConnector(address_, QByteArray::number(i));
        clientsList.push_back(client);

        QSignalSpy clientConnected(client, &ClientConnector::connected);
        QVERIFY(clientConnected.isValid());
        QCOMPARE(client->initialize(), true);
        QVERIFY((clientConnected.count() == 1) || (clientConnected.wait(zmqWaitTimeSuccess) == true));

        connect(client, &ClientConnector::messageReceived, this,
                [&clientMessages, i](const QByteArray &message) {
                    ++clientMessages;
                    QCOMPARE(message, QByteArray::number(i));
                });
    }

    // send Messages
    for (auto &client : clientsList) {
        client->sendMessage("testClient");
    }

    QTRY_VERIFY_WITH_TIMEOUT(clientMessages == count, zmqWaitTimeSuccess);
    QTRY_VERIFY_WITH_TIMEOUT(serverMessages == count, zmqWaitTimeSuccess);

    // clean-up
    for (auto client : clientsList) {
        delete client;
    }
}

void ConnectorsTest::testFloodTheServer()
{
    ServerConnector server(address_);
    QSignalSpy serverInitialized(&server, &ServerConnector::initialized);
    QVERIFY(serverInitialized.isValid());
    QCOMPARE(server.initialize(), true);
    QVERIFY((serverInitialized.count() == 1) || (serverInitialized.wait(zmqWaitTimeSuccess) == true));

    connect(&server, &ServerConnector::messageReceived, this,
            [&server](const QByteArray &clientId, const QByteArray &message) {
                if (message == "Start Test") {
                    server.sendMessage(clientId, "Hello from ServerConnector!");
                }
            });

    ClientConnector client(address_);
    QSignalSpy clientConnected(&client, &ClientConnector::connected);
    QVERIFY(clientConnected.isValid());
    QCOMPARE(client.initialize(), true);
    QVERIFY((clientConnected.count() == 1) || (clientConnected.wait(zmqWaitTimeSuccess) == true));

    connect(&client, &ClientConnector::messageReceived, this,
            [&client](const QByteArray &) {
                for (int i = 0; i < 1000; i++) {
                    client.sendMessage(QByteArray::number(i));
                }
            });

    client.sendMessage("Start Test");

    waitForZmqMessages(zmqWaitTime);
}

void ConnectorsTest::testFloodTheClient()
{
    QTimer timer;
    ServerConnector server(address_);
    QSignalSpy serverInitialized(&server, &ServerConnector::initialized);
    QVERIFY(serverInitialized.isValid());
    QCOMPARE(server.initialize(), true);
    QVERIFY((serverInitialized.count() == 1) || (serverInitialized.wait(zmqWaitTimeSuccess) == true));

    connect(&server, &ServerConnector::messageReceived, this,
            [&server, &timer](const QByteArray &clientId, const QByteArray &message) {
                if (message == "Start Test") {
                    for (int i = 0; i < 1000; i++) {
                        server.sendMessage(clientId, QByteArray::number(i));
                    }
                }
                timer.start(zmqWaitTimeSuccess);    // increase the timer to process the client messages
            });

    ClientConnector client(address_);
    QSignalSpy clientConnected(&client, &ClientConnector::connected);
    QVERIFY(clientConnected.isValid());
    QCOMPARE(client.initialize(), true);
    QVERIFY((clientConnected.count() == 1) || (clientConnected.wait(zmqWaitTimeSuccess) == true));

    connect(&client, &ClientConnector::messageReceived, this,
            [](const QByteArray &) {});

    client.sendMessage("Start Test");

    // wait for the messages
    timer.setSingleShot(true);
    timer.start(zmqWaitTimeSuccess);
    do {
        QCoreApplication::processEvents(QEventLoop::WaitForMoreEvents);
    } while (timer.isActive());
}

void ConnectorsTest::testDisconnectClient()
{
    ServerConnector server(address_);
    QSignalSpy serverInitialized(&server, &ServerConnector::initialized);
    QVERIFY(serverInitialized.isValid());
    QCOMPARE(server.initialize(), true);
    QVERIFY((serverInitialized.count() == 1) || (serverInitialized.wait(zmqWaitTimeSuccess) == true));

    QSignalSpy serverMessageReceived(&server, &ServerConnector::messageReceived);
    QVERIFY(serverMessageReceived.isValid());
    connect(&server, &ServerConnector::messageReceived, this,
            [&server](const QByteArray &clientId, const QByteArray &) {
                server.sendMessage(clientId, "test from the server");
            });

    ClientConnector client(address_, "AA");

    QSignalSpy clientDisconnected(&client, &ClientConnector::disconnected);
    QVERIFY(clientDisconnected.isValid());

    QSignalSpy clientConnected(&client, &ClientConnector::connected);
    QVERIFY(clientConnected.isValid());
    QCOMPARE(client.initialize(), true);
    QVERIFY((clientConnected.count() == 1) || (clientConnected.wait(zmqWaitTimeSuccess) == true));
    clientConnected.clear();

    QSignalSpy clientMessageReceived(&client, &ClientConnector::messageReceived);
    QVERIFY(clientMessageReceived.isValid());

    serverMessageReceived.clear();
    clientMessageReceived.clear();
    client.sendMessage("test from the client");
    QVERIFY((serverMessageReceived.count() == 1) || (serverMessageReceived.wait(zmqWaitTimeSuccess) == true));
    QVERIFY((clientMessageReceived.count() == 1) || (clientMessageReceived.wait(zmqWaitTimeSuccess) == true));

    QCOMPARE(client.disconnect(), true);
    QVERIFY((clientDisconnected.count() == 1) || (clientDisconnected.wait(zmqWaitTimeSuccess) == true));
    clientDisconnected.clear();

    QCOMPARE(client.connect(), true);
    QVERIFY((clientConnected.count() == 1) || (clientConnected.wait(zmqWaitTimeSuccess) == true));
    clientConnected.clear();

    serverMessageReceived.clear();
    clientMessageReceived.clear();
    client.sendMessage("test from the client");
    QVERIFY((serverMessageReceived.count() == 1) || (serverMessageReceived.wait(zmqWaitTimeSuccess) == true));
    QVERIFY((clientMessageReceived.count() == 1) || (clientMessageReceived.wait(zmqWaitTimeSuccess) == true));

    serverMessageReceived.clear();
    clientMessageReceived.clear();
    QCOMPARE(client.disconnect(), true);
    QVERIFY((clientDisconnected.count() == 1) || (clientDisconnected.wait(zmqWaitTimeSuccess) == true));
    clientDisconnected.clear();

    server.sendMessage("AA", "test from the server");
    QVERIFY((serverMessageReceived.count() == 0) && (serverMessageReceived.wait(zmqWaitTime) == false));
    QVERIFY((clientMessageReceived.count() == 0) && (clientMessageReceived.wait(zmqWaitTime) == false));

    QCOMPARE(client.disconnect(), false);
    QVERIFY((clientDisconnected.count() == 0) && (clientDisconnected.wait(zmqWaitTime) == false));
    clientDisconnected.clear();

    QCOMPARE(client.connect(), true);
    QVERIFY((clientConnected.count() == 1) || (clientConnected.wait(zmqWaitTimeSuccess) == true));
    clientConnected.clear();
    QCOMPARE(client.connect(), false);
    QVERIFY((clientConnected.count() == 0) && (clientConnected.wait(zmqWaitTime) == false));
    QCOMPARE(client.disconnect(), true);
    QVERIFY((clientDisconnected.count() == 1) || (clientDisconnected.wait(zmqWaitTimeSuccess) == true));
}

void ConnectorsTest::testFailedToSendMessageFromClientConnector()
{
    ClientConnector client(address_);

    QVERIFY(false == client.sendMessage("This should fail!"));

    QSignalSpy clientConnected(&client, &ClientConnector::connected);
    QSignalSpy clientDisonnected(&client, &ClientConnector::disconnected);
    QVERIFY(clientConnected.isValid());
    QVERIFY(clientDisonnected.isValid());
    QCOMPARE(client.initialize(), true);
    QVERIFY((clientConnected.count() == 1) || (clientConnected.wait(zmqWaitTimeSuccess) == true));
    QVERIFY(client.sendMessage("This should pass!"));

    QVERIFY(client.disconnect());
    QVERIFY((clientDisonnected.count() == 1) || (clientDisonnected.wait(zmqWaitTimeSuccess) == true));
    QVERIFY(false == client.sendMessage("This should fail!"));
}

void ConnectorsTest::testFailedToSendMessageFromServerConnector()
{
    qRegisterMetaType<strata::strataRPC::ServerConnectorError>("ServerConnectorError");
    ServerConnector server(address_);
    QSignalSpy errorOccured(&server, &ServerConnector::errorOccurred);
    QVERIFY(errorOccured.isValid());
    QVERIFY(false == server.sendMessage("RANDOMID", "This should fail."));
    QVERIFY((errorOccured.count() == 1) || (errorOccured.wait(zmqWaitTimeSuccess) == true));
    auto errorType =
        qvariant_cast<strata::strataRPC::ServerConnectorError>(errorOccured.takeFirst().at(0));
    QCOMPARE(errorType, strata::strataRPC::ServerConnectorError::FailedToSend);

    QSignalSpy serverInitialized(&server, &ServerConnector::initialized);
    QVERIFY(serverInitialized.isValid());
    QCOMPARE(server.initialize(), true);
    QVERIFY((serverInitialized.count() == 1) || (serverInitialized.wait(zmqWaitTimeSuccess) == true));
    QVERIFY(server.sendMessage("RANDOMID", "This should pass."));
}

void ConnectorsTest::testClientConnectorErrorSignals()
{
    qRegisterMetaType<strata::strataRPC::ClientConnectorError>("ClientConnectorError");

    ClientConnector client(address_);
    QCOMPARE(client.isConnected(), false);
    QSignalSpy clientConnected(&client, &ClientConnector::connected);
    QVERIFY(clientConnected.isValid());
    QCOMPARE(client.initialize(), true);
    QVERIFY((clientConnected.count() == 1) || (clientConnected.wait(zmqWaitTimeSuccess) == true));

    QSignalSpy errorOccurred(&client, &ClientConnector::errorOccurred);
    QVERIFY(errorOccurred.isValid());
    {
        QCOMPARE(client.initialize(), false);
        QVERIFY((errorOccurred.count() == 1) || (errorOccurred.wait(zmqWaitTimeSuccess) == true));
        auto errorType =
            qvariant_cast<strata::strataRPC::ClientConnectorError>(errorOccurred.takeFirst().at(0));
        QCOMPARE(errorType, strata::strataRPC::ClientConnectorError::FailedToConnect);
        errorOccurred.clear();
    }

    {
        QCOMPARE(client.connect(), false);
        QCOMPARE(errorOccurred.count(), 1);
        auto errorType =
            qvariant_cast<strata::strataRPC::ClientConnectorError>(errorOccurred.takeFirst().at(0));
        QCOMPARE(errorType, strata::strataRPC::ClientConnectorError::FailedToConnect);
        errorOccurred.clear();
    }

    client.disconnect();
    QCOMPARE(client.isConnected(), false);

    {
        QCOMPARE(client.disconnect(), false);
        QCOMPARE(errorOccurred.count(), 1);
        auto errorType =
            qvariant_cast<strata::strataRPC::ClientConnectorError>(errorOccurred.takeFirst().at(0));
        QCOMPARE(errorType, strata::strataRPC::ClientConnectorError::FailedToDisconnect);
        errorOccurred.clear();
    }

    {
        QCOMPARE(client.sendMessage("test"), false);
        QCOMPARE(errorOccurred.count(), 1);
        auto errorType =
            qvariant_cast<strata::strataRPC::ClientConnectorError>(errorOccurred.takeFirst().at(0));
        QCOMPARE(errorType, strata::strataRPC::ClientConnectorError::FailedToSend);
        errorOccurred.clear();
    }
}
