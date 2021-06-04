#include "ConnectorsTest.h"

#include <QSignalSpy>
#include <QVector>

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
    strata::strataRPC::ServerConnector connector(address_);
    QSignalSpy serverConnected_1(&connector, &strata::strataRPC::ServerConnector::serverConnected);
    QSignalSpy errorOccured_1(&connector, &strata::strataRPC::ServerConnector::errorOccred);
    QCOMPARE_(connector.initilizeConnector(), true);
    QCOMPARE_(serverConnected_1.isEmpty(), false);
    QCOMPARE_(errorOccured_1.isEmpty(), true);

    strata::strataRPC::ServerConnector connectorDublicate(address_);
    QSignalSpy serverConnected_2(&connectorDublicate,
                                 &strata::strataRPC::ServerConnector::serverConnected);
    QSignalSpy errorOccured_2(&connectorDublicate,
                              &strata::strataRPC::ServerConnector::errorOccred);
    QCOMPARE_(connectorDublicate.initilizeConnector(), false);
    QCOMPARE_(serverConnected_2.isEmpty(), true);
    QCOMPARE_(errorOccured_2.isEmpty(), false);
    QCOMPARE_(errorOccured_2.count(), 1);
    auto errorType =
        qvariant_cast<strata::strataRPC::ServerConnectorError>(errorOccured_2.takeFirst().at(0));
    QCOMPARE_(errorType, strata::strataRPC::ServerConnectorError::FailedToInitialize);
}

void ConnectorsTest::testServerAndClient()
{
    QTimer timer;
    bool testPassed = false;
    strata::strataRPC::ServerConnector server(address_);
    QCOMPARE_(server.initilizeConnector(), true);

    QByteArray client_id = "client_1";
    strata::strataRPC::ClientConnector client(address_, client_id);

    QSignalSpy clientInitialized(&client, &strata::strataRPC::ClientConnector::clientInitialized);
    QSignalSpy clientConnected(&client, &strata::strataRPC::ClientConnector::clientConnected);

    QCOMPARE_(client.initializeConnector(), true);

    QCOMPARE_(clientInitialized.count(), 1);
    QCOMPARE_(clientConnected.count(), 1);
    QCOMPARE_(client.isConnected(), true);

    connect(&server, &strata::strataRPC::ServerConnector::newMessageReceived, this,
            [&server](const QByteArray &clientId, const QByteArray &message) {
                QCOMPARE_(clientId, "client_1");
                if (message == "Start Test") {
                    server.sendMessage(clientId, "Hello from ServerConnector!");
                }
            });

    connect(&client, &strata::strataRPC::ClientConnector::newMessageReceived, this,
            [&client, &timer, &testPassed]() {
                client.sendMessage("Hello from ClientConnector!");
                testPassed = true;
                timer.stop();
            });

    client.sendMessage("Start Test");

    // wait for the messages
    timer.setSingleShot(true);
    timer.start(100);
    do {
        QCoreApplication::processEvents(QEventLoop::WaitForMoreEvents);
    } while (timer.isActive());

    QVERIFY_(testPassed);
}

void ConnectorsTest::testMultipleClients()
{
    strata::strataRPC::ServerConnector server(address_);
    QCOMPARE_(server.initilizeConnector(), true);

    connect(&server, &strata::strataRPC::ServerConnector::newMessageReceived, this,
            [&server](const QByteArray &clientId, const QString &) {
                server.sendMessage(clientId, clientId);
            });

    std::vector<strata::strataRPC::ClientConnector *> clientsList;
    for (int i = 0; i < 15; i++) {
        clientsList.push_back(
            new strata::strataRPC::ClientConnector(address_, QByteArray::number(i)));
        clientsList.back()->initializeConnector();
        connect(clientsList.back(), &strata::strataRPC::ClientConnector::newMessageReceived, this,
                [i](const QByteArray &message) { QCOMPARE_(message, QByteArray::number(i)); });
    }

    // send Messages
    for (auto &client : clientsList) {
        client->sendMessage("testClient");
    }

    waitForZmqMessages();

    // clean-up
    for (auto client : clientsList) {
        delete client;
    }
}

void ConnectorsTest::testFloodTheServer()
{
    strata::strataRPC::ServerConnector server(address_);
    QCOMPARE_(server.initilizeConnector(), true);

    connect(&server, &strata::strataRPC::ServerConnector::newMessageReceived, this,
            [&server](const QByteArray &clientId, const QByteArray &message) {
                if (message == "Start Test") {
                    server.sendMessage(clientId, "Hello from ServerConnector!");
                }
            });

    strata::strataRPC::ClientConnector client(address_);
    QCOMPARE_(client.initializeConnector(), true);

    connect(&client, &strata::strataRPC::ClientConnector::newMessageReceived, this,
            [&client](const QByteArray &) {
                for (int i = 0; i < 1000; i++) {
                    client.sendMessage(QByteArray::number(i));
                }
            });

    client.sendMessage("Start Test");

    waitForZmqMessages();
}

void ConnectorsTest::testFloodTheClient()
{
    QTimer timer;

    strata::strataRPC::ServerConnector server(address_);
    QCOMPARE_(server.initilizeConnector(), true);

    connect(&server, &strata::strataRPC::ServerConnector::newMessageReceived, this,
            [&server, &timer](const QByteArray &clientId, const QByteArray &message) {
                if (message == "Start Test") {
                    for (int i = 0; i < 1000; i++) {
                        server.sendMessage(clientId, QByteArray::number(i));
                    }
                }
                timer.start(100);  // increase the timer to process the client messages
            });

    strata::strataRPC::ClientConnector client(address_);
    QCOMPARE_(client.initializeConnector(), true);

    connect(&client, &strata::strataRPC::ClientConnector::newMessageReceived, this,
            [](const QByteArray &) {});

    client.sendMessage("Start Test");

    // wait for the messages
    timer.setSingleShot(true);
    timer.start(100);
    do {
        QCoreApplication::processEvents(QEventLoop::WaitForMoreEvents);
    } while (timer.isActive());
}

void ConnectorsTest::testDisconnectClient()
{
    bool serverReceivedMessage = false;
    strata::strataRPC::ServerConnector server(address_);
    QCOMPARE_(server.initilizeConnector(), true);

    connect(&server, &strata::strataRPC::ServerConnector::newMessageReceived, this,
            [&serverReceivedMessage, &server](const QByteArray &clientId, const QByteArray &) {
                serverReceivedMessage = true;
                server.sendMessage(clientId, "test from the server");
            });

    bool clientReceivedMessage = false;
    strata::strataRPC::ClientConnector client(address_, "AA");

    QSignalSpy clientDisconnected(&client, &strata::strataRPC::ClientConnector::clientDisconnected);

    QCOMPARE_(client.initializeConnector(), true);
    connect(&client, &strata::strataRPC::ClientConnector::newMessageReceived, this,
            [&clientReceivedMessage](const QByteArray &) { clientReceivedMessage = true; });

    serverReceivedMessage = false;
    clientReceivedMessage = false;
    client.sendMessage("test from the client");
    waitForZmqMessages();
    QVERIFY_(true == serverReceivedMessage);
    QVERIFY_(true == clientReceivedMessage);

    QCOMPARE_(client.disconnectClient(), true);
    QCOMPARE_(clientDisconnected.count(), 1);
    clientDisconnected.clear();

    waitForZmqMessages();

    QCOMPARE_(client.connectClient(), true);

    serverReceivedMessage = false;
    clientReceivedMessage = false;
    client.sendMessage("test from the client");
    waitForZmqMessages();
    QVERIFY_(true == serverReceivedMessage);
    QVERIFY_(true == clientReceivedMessage);

    serverReceivedMessage = false;
    clientReceivedMessage = false;
    QCOMPARE_(client.disconnectClient(), true);
    QCOMPARE_(clientDisconnected.count(), 1);
    clientDisconnected.clear();

    server.sendMessage("AA", "test from the server");
    waitForZmqMessages();
    QVERIFY_(false == serverReceivedMessage);
    QVERIFY_(false == clientReceivedMessage);

    QCOMPARE_(client.disconnectClient(), false);
    QCOMPARE_(clientDisconnected.count(), 0);
    clientDisconnected.clear();

    QCOMPARE_(client.connectClient(), true);
    QCOMPARE_(client.connectClient(), false);
    QCOMPARE_(client.disconnectClient(), true);
    QCOMPARE_(clientDisconnected.count(), 1);
    clientDisconnected.clear();
}

void ConnectorsTest::testFailedToSendMessageFromClientConnector()
{
    strata::strataRPC::ClientConnector client(address_);

    QVERIFY_(false == client.sendMessage("This should fail!"));

    QVERIFY_(client.initializeConnector());
    QVERIFY_(client.sendMessage("This should pass!"));

    QVERIFY_(client.disconnectClient());
    QVERIFY_(false == client.sendMessage("This should fail!"));
}

void ConnectorsTest::testFailedToSendMessageFromServerConnector()
{
    qRegisterMetaType<strata::strataRPC::ServerConnectorError>("ServerConnectorError");
    strata::strataRPC::ServerConnector server(address_);
    QSignalSpy errorOccured(&server, &strata::strataRPC::ServerConnector::errorOccred);
    QVERIFY_(false == server.sendMessage("RANDOMID", "This should fail."));
    QCOMPARE_(errorOccured.isEmpty(), false);
    auto errorType =
        qvariant_cast<strata::strataRPC::ServerConnectorError>(errorOccured.takeFirst().at(0));
    QCOMPARE_(errorType, strata::strataRPC::ServerConnectorError::FailedToSend);

    QVERIFY_(server.initilizeConnector());
    QVERIFY_(server.sendMessage("RANDOMID", "This should pass."));
}

void ConnectorsTest::testClientConnectorErrorSignals()
{
    qRegisterMetaType<strata::strataRPC::ClientConnectorError>("ClientConnectorError");

    strata::strataRPC::ClientConnector client(address_);
    QCOMPARE_(client.isConnected(), false);
    client.initializeConnector();

    QSignalSpy errorOccurred(&client, &strata::strataRPC::ClientConnector::errorOccurred);

    {
        QCOMPARE_(client.initializeConnector(), false);
        QCOMPARE_(errorOccurred.count(), 1);
        auto errorType =
            qvariant_cast<strata::strataRPC::ClientConnectorError>(errorOccurred.takeFirst().at(0));
        QCOMPARE_(errorType, strata::strataRPC::ClientConnectorError::FailedToConnect);
        errorOccurred.clear();
    }

    {
        QCOMPARE_(client.connectClient(), false);
        QCOMPARE_(errorOccurred.count(), 1);
        auto errorType =
            qvariant_cast<strata::strataRPC::ClientConnectorError>(errorOccurred.takeFirst().at(0));
        QCOMPARE_(errorType, strata::strataRPC::ClientConnectorError::FailedToConnect);
        errorOccurred.clear();
    }

    client.disconnectClient();
    QCOMPARE_(client.isConnected(), false);

    {
        QCOMPARE_(client.disconnectClient(), false);
        QCOMPARE_(errorOccurred.count(), 1);
        auto errorType =
            qvariant_cast<strata::strataRPC::ClientConnectorError>(errorOccurred.takeFirst().at(0));
        QCOMPARE_(errorType, strata::strataRPC::ClientConnectorError::FailedToDisconnect);
        errorOccurred.clear();
    }

    {
        QCOMPARE_(client.sendMessage("test"), false);
        QCOMPARE_(errorOccurred.count(), 1);
        auto errorType =
            qvariant_cast<strata::strataRPC::ClientConnectorError>(errorOccurred.takeFirst().at(0));
        QCOMPARE_(errorType, strata::strataRPC::ClientConnectorError::FailedToSend);
        errorOccurred.clear();
    }
}
