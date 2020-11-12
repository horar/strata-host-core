#include "QzmqTest.h"

#include <QVector>

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

    std::string client_id = "client_1";
    strata::strataComm::ClientConnector client(address_, client_id);
    QCOMPARE_(client.initilize(), true);

    connect(&server, &strata::strataComm::ServerConnector::newMessageRecived, this, [&server](const QByteArray &clientId, const QString &message) {
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
    QTimer timer;

    strata::strataComm::ServerConnector server(address_);
    QCOMPARE_(server.initilize(), true);

    connect(&server, &strata::strataComm::ServerConnector::newMessageRecived, this, [&server](const QByteArray &clientId, const QString &) {
        server.sendMessage(clientId, clientId);
    });

    std::vector<strata::strataComm::ClientConnector *> clientsList;
    for (int i=0; i<15; i++) {
        clientsList.push_back(new strata::strataComm::ClientConnector(address_, std::to_string(i)));
        clientsList.back()->initilize();
        connect(clientsList.back(), &strata::strataComm::ClientConnector::newMessageRecived, this, [i](const QString &message) {
            QCOMPARE_(message, QString::number(i));
        });
    }

    // send Messages
    for (auto &client : clientsList) {
        client->sendMessage("testClient");
    }

    // wait for the messages
    timer.setSingleShot(true);
    timer.start(100);
    do {
        QCoreApplication::processEvents(QEventLoop::WaitForMoreEvents);
    } while (timer.isActive());

    // clean-up
    for (auto client : clientsList) {
        delete client;
    }
}

void ServerConnectorTest::testFloodTheServer() {
    QTimer timer;

    strata::strataComm::ServerConnector server(address_);
    QCOMPARE_(server.initilize(), true);

    connect(&server, &strata::strataComm::ServerConnector::newMessageRecived, this, [&server](const QByteArray &clientId, const QString &message) {
        if (message == "Start Test") {
            server.sendMessage(clientId, "Hello from ServerConnector!");
        } else {
            qDebug() << message;
        }
    });

    strata::strataComm::ClientConnector client(address_);
    QCOMPARE_(client.initilize(), true);

    connect(&client, &strata::strataComm::ClientConnector::newMessageRecived, this, [&client](const QString &) {
        for (int i=0; i < 10000; i++) {
            client.sendMessage(QString::number(i));
        }
    });

    client.sendMessage("Start Test");

    // wait for the messages
    timer.setSingleShot(true);
    timer.start(100);
    do {
        QCoreApplication::processEvents(QEventLoop::WaitForMoreEvents);
    } while (timer.isActive());
}

void ServerConnectorTest::testFloodTheClient() {
    QTimer timer;

    strata::strataComm::ServerConnector server(address_);
    QCOMPARE_(server.initilize(), true);

    connect(&server, &strata::strataComm::ServerConnector::newMessageRecived, this, [&server, &timer](const QByteArray &clientId, const QString &message) {
        if (message == "Start Test") {
            for (int i=0; i < 10000; i++) {
                server.sendMessage(clientId, QString::number(i));
            }
        }
        timer.start(100);   // increase the timer to process the client messages
    });

    strata::strataComm::ClientConnector client(address_);
    QCOMPARE_(client.initilize(), true);

    connect(&client, &strata::strataComm::ClientConnector::newMessageRecived, this, [](const QString &message) {
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
