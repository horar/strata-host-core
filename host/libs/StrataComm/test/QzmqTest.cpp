#include "QzmqTest.h"

#include <QVector>

void ServerConnectorTest::waitForZmqMessages(int delay) 
{
    QTimer timer;

    // wait for the messages
    timer.setSingleShot(true);
    timer.start(delay);
    do {
        QCoreApplication::processEvents(QEventLoop::WaitForMoreEvents);
    } while (timer.isActive());
}

void ServerConnectorTest::testOpenServerConnectorFaild() {
    strata::strataComm::ServerConnector connector(address_);
    QCOMPARE(connector.initilize(), true);

    strata::strataComm::ServerConnector connectorDublicate(address_);
    QCOMPARE(connectorDublicate.initilize(), false);
}

void ServerConnectorTest::testServerAndClient() {
    QTimer timer;
    bool testPassed = false;
    strata::strataComm::ServerConnector server(address_);
    QCOMPARE_(server.initilize(), true);

    QByteArray client_id = "client_1";
    strata::strataComm::ClientConnector client(address_, client_id);
    QCOMPARE_(client.initilize(), true);

    connect(&server, &strata::strataComm::ServerConnector::newMessageRecived, this, [&server](const QByteArray &clientId, const QByteArray &message) {
        QCOMPARE_(clientId, "client_1");
        if (message == "Start Test") {
            server.sendMessage(clientId, "Hello from ServerConnector!");
        }
    });

    connect(&client, &strata::strataComm::ClientConnector::newMessageRecived, this, [&client, &timer, &testPassed]() {
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

void ServerConnectorTest::testMultipleClients() {
    strata::strataComm::ServerConnector server(address_);
    QCOMPARE_(server.initilize(), true);

    connect(&server, &strata::strataComm::ServerConnector::newMessageRecived, this, [&server](const QByteArray &clientId, const QString &) {
        server.sendMessage(clientId, clientId);
    });

    std::vector<strata::strataComm::ClientConnector *> clientsList;
    for (int i=0; i<15; i++) {
        clientsList.push_back(new strata::strataComm::ClientConnector(address_, QByteArray::number(i)));
        clientsList.back()->initilize();
        connect(clientsList.back(), &strata::strataComm::ClientConnector::newMessageRecived, this, [i](const QByteArray &message) {
            QCOMPARE_(message, QByteArray::number(i));
        });
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

void ServerConnectorTest::testFloodTheServer() {
    strata::strataComm::ServerConnector server(address_);
    QCOMPARE_(server.initilize(), true);

    connect(&server, &strata::strataComm::ServerConnector::newMessageRecived, this, [&server](const QByteArray &clientId, const QByteArray &message) {
        if (message == "Start Test") {
            server.sendMessage(clientId, "Hello from ServerConnector!");
        } else {
            qDebug() << message;
        }
    });

    strata::strataComm::ClientConnector client(address_);
    QCOMPARE_(client.initilize(), true);

    connect(&client, &strata::strataComm::ClientConnector::newMessageRecived, this, [&client](const QByteArray &) {
        for (int i=0; i < 10000; i++) {
            client.sendMessage(QByteArray::number(i));
        }
    });

    client.sendMessage("Start Test");

    waitForZmqMessages();
}

void ServerConnectorTest::testFloodTheClient() {
    QTimer timer;

    strata::strataComm::ServerConnector server(address_);
    QCOMPARE_(server.initilize(), true);

    connect(&server, &strata::strataComm::ServerConnector::newMessageRecived, this, [&server, &timer](const QByteArray &clientId, const QByteArray &message) {
        if (message == "Start Test") {
            for (int i=0; i < 10000; i++) {
                server.sendMessage(clientId, QByteArray::number(i));
            }
        }
        timer.start(100);   // increase the timer to process the client messages
    });

    strata::strataComm::ClientConnector client(address_);
    QCOMPARE_(client.initilize(), true);

    connect(&client, &strata::strataComm::ClientConnector::newMessageRecived, this, [](const QByteArray &message) {
        qDebug() << message;
    });

    client.sendMessage("Start Test");

    // wait for the messages
    timer.setSingleShot(true);
    timer.start(100);
    do {
        QCoreApplication::processEvents(QEventLoop::WaitForMoreEvents);
    } while (timer.isActive());
}

void ServerConnectorTest::testDisconnectClient() 
{
    bool serverRecivedMessage = false;
    strata::strataComm::ServerConnector server(address_);
    QCOMPARE_(server.initilize(), true);

    connect(&server, &strata::strataComm::ServerConnector::newMessageRecived, this, [&serverRecivedMessage, &server](const QByteArray &clientId, const QByteArray &messgae) {
        serverRecivedMessage = true;
        server.sendMessage("AA", "test from the server");
    });

    bool clientRecivedMessage = false;
    strata::strataComm::ClientConnector client(address_, "AA");
    QCOMPARE_(client.initilize(), true);
    connect(&client, &strata::strataComm::ClientConnector::newMessageRecived, this, [&clientRecivedMessage](const QByteArray &message) {
        clientRecivedMessage = true;
    });

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
