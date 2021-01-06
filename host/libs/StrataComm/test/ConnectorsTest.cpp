#include "ConnectorsTest.h"

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
    strata::strataComm::ServerConnector connector(address_);
    QCOMPARE(connector.initilizeConnector(), true);

    strata::strataComm::ServerConnector connectorDublicate(address_);
    QCOMPARE(connectorDublicate.initilizeConnector(), false);
}

void ConnectorsTest::testServerAndClient()
{
    QTimer timer;
    bool testPassed = false;
    strata::strataComm::ServerConnector server(address_);
    QCOMPARE_(server.initilizeConnector(), true);

    QByteArray client_id = "client_1";
    strata::strataComm::ClientConnector client(address_, client_id);
    QCOMPARE_(client.initializeConnector(), true);

    connect(&server, &strata::strataComm::ServerConnector::newMessageRecived, this,
            [&server](const QByteArray &clientId, const QByteArray &message) {
                QCOMPARE_(clientId, "client_1");
                if (message == "Start Test") {
                    server.sendMessage(clientId, "Hello from ServerConnector!");
                }
            });

    connect(&client, &strata::strataComm::ClientConnector::newMessageRecived, this,
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
    strata::strataComm::ServerConnector server(address_);
    QCOMPARE_(server.initilizeConnector(), true);

    connect(&server, &strata::strataComm::ServerConnector::newMessageRecived, this,
            [&server](const QByteArray &clientId, const QString &) {
                server.sendMessage(clientId, clientId);
            });

    std::vector<strata::strataComm::ClientConnector *> clientsList;
    for (int i = 0; i < 15; i++) {
        clientsList.push_back(
            new strata::strataComm::ClientConnector(address_, QByteArray::number(i)));
        clientsList.back()->initializeConnector();
        connect(clientsList.back(), &strata::strataComm::ClientConnector::newMessageRecived, this,
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
    strata::strataComm::ServerConnector server(address_);
    QCOMPARE_(server.initilizeConnector(), true);

    connect(&server, &strata::strataComm::ServerConnector::newMessageRecived, this,
            [&server](const QByteArray &clientId, const QByteArray &message) {
                if (message == "Start Test") {
                    server.sendMessage(clientId, "Hello from ServerConnector!");
                } else {
                    // qDebug() << message;
                }
            });

    strata::strataComm::ClientConnector client(address_);
    QCOMPARE_(client.initializeConnector(), true);

    connect(&client, &strata::strataComm::ClientConnector::newMessageRecived, this,
            [&client](const QByteArray &) {
                for (int i = 0; i < 10000; i++) {
                    client.sendMessage(QByteArray::number(i));
                }
            });

    client.sendMessage("Start Test");

    waitForZmqMessages();
}

void ConnectorsTest::testFloodTheClient()
{
    QTimer timer;

    strata::strataComm::ServerConnector server(address_);
    QCOMPARE_(server.initilizeConnector(), true);

    connect(&server, &strata::strataComm::ServerConnector::newMessageRecived, this,
            [&server, &timer](const QByteArray &clientId, const QByteArray &message) {
                if (message == "Start Test") {
                    for (int i = 0; i < 10000; i++) {
                        server.sendMessage(clientId, QByteArray::number(i));
                    }
                }
                timer.start(100);  // increase the timer to process the client messages
            });

    strata::strataComm::ClientConnector client(address_);
    QCOMPARE_(client.initializeConnector(), true);

    connect(&client, &strata::strataComm::ClientConnector::newMessageRecived, this,
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
    bool serverRecivedMessage = false;
    strata::strataComm::ServerConnector server(address_);
    QCOMPARE_(server.initilizeConnector(), true);

    connect(&server, &strata::strataComm::ServerConnector::newMessageRecived, this,
            [&serverRecivedMessage, &server](const QByteArray &clientId, const QByteArray &) {
                serverRecivedMessage = true;
                server.sendMessage(clientId, "test from the server");
            });

    bool clientRecivedMessage = false;
    strata::strataComm::ClientConnector client(address_, "AA");
    QCOMPARE_(client.initializeConnector(), true);
    connect(&client, &strata::strataComm::ClientConnector::newMessageRecived, this,
            [&clientRecivedMessage](const QByteArray &) { clientRecivedMessage = true; });

    serverRecivedMessage = false;
    clientRecivedMessage = false;
    client.sendMessage("test from the client");
    waitForZmqMessages();
    QVERIFY_(true == serverRecivedMessage);
    QVERIFY_(true == clientRecivedMessage);

    QCOMPARE_(client.disconnectClient(), true);
    waitForZmqMessages();

    QCOMPARE_(client.connectClient(), true);

    serverRecivedMessage = false;
    clientRecivedMessage = false;
    client.sendMessage("test from the client");
    waitForZmqMessages();
    QVERIFY_(true == serverRecivedMessage);
    QVERIFY_(true == clientRecivedMessage);

    serverRecivedMessage = false;
    clientRecivedMessage = false;
    QCOMPARE_(client.disconnectClient(), true);
    server.sendMessage("AA", "test from the server");
    waitForZmqMessages();
    QVERIFY_(false == serverRecivedMessage);
    QVERIFY_(false == clientRecivedMessage);

    QCOMPARE_(client.disconnectClient(), false);
    QCOMPARE_(client.connectClient(), true);
    QCOMPARE_(client.connectClient(), false);
    QCOMPARE_(client.disconnectClient(), true);
}

void ConnectorsTest::testFailedToSendMessageFromClientConnector()
{
    strata::strataComm::ClientConnector client(address_);

    QVERIFY_(false == client.sendMessage("This should fail!"));

    QVERIFY_(client.initializeConnector());
    QVERIFY_(client.sendMessage("This should pass!"));

    QVERIFY_(client.disconnectClient());
    QVERIFY_(false == client.sendMessage("This should fail!"));
}

void ConnectorsTest::testFailedToSendMessageFromServerConnector()
{
    strata::strataComm::ServerConnector server(address_);

    QVERIFY_(false == server.sendMessage("RANDOMID", "This should fail."));

    QVERIFY_(server.initilizeConnector());
    QVERIFY_(server.sendMessage("RANDOMID", "This should pass."));
}
