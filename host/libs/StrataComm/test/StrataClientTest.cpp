#include "StrataClientTest.h"

#include "../src/ServerConnector.h"

void StrataClientTest::waitForZmqMessages(int delay)
{
    QTimer timer;
    timer.setSingleShot(true);
    timer.start(delay);
    do {
        QCoreApplication::processEvents(QEventLoop::WaitForMoreEvents);
    } while (timer.isActive());
}

void StrataClientTest::testRegisterAndUnregisterHandlers()
{
    StrataClient client(address_);

    // register new handler
    QVERIFY_(client.registerHandler("handler_1",
                                    [](const strata::strataComm::ClientMessage &cm) { return; }));
    QVERIFY_(client.registerHandler("handler_2",
                                    [](const strata::strataComm::ClientMessage &cm) { return; }));
    QVERIFY_(false ==
             client.registerHandler("handler_2",
                                    [](const strata::strataComm::ClientMessage &cm) { return; }));

    QVERIFY_(client.unregisterHandler("handler_1"));
    QVERIFY_(client.unregisterHandler("handler_2"));
    QVERIFY_(client.unregisterHandler("handler_2"));
    QVERIFY_(client.unregisterHandler("not_registered_handler"));
}

void StrataClientTest::testConnectDisconnectToTheServer()
{
    // serverConnector set up
    strata::strataComm::ServerConnector server(address_);
    server.initilize();
    bool serverRevicedMessage = false;
    connect(
        &server, &strata::strataComm::ServerConnector::newMessageRecived, this,
        [&server, &serverRevicedMessage](const QByteArray &clientId, const QByteArray &message) {
            qDebug() << "ServerConnector new message handler. client id:" << clientId << "message"
                     << message;
            serverRevicedMessage = true;
            server.sendMessage(clientId, message);
        });

    // StrataClient set up
    StrataClient client(address_);

    bool clientRecivedMessage = false;
    connect(&client, &StrataClient::dispatchHandler, this,
            [&clientRecivedMessage] { clientRecivedMessage = true; });

    serverRevicedMessage = false;
    clientRecivedMessage = false;
    QVERIFY_(client.connectServer());
    waitForZmqMessages();
    QVERIFY_(serverRevicedMessage);
    QVERIFY_(clientRecivedMessage);

    serverRevicedMessage = false;
    clientRecivedMessage = false;
    QVERIFY_(client.disconnectServer());
    waitForZmqMessages();
    QVERIFY_(serverRevicedMessage);
    QVERIFY_(false == clientRecivedMessage);

    serverRevicedMessage = false;
    clientRecivedMessage = false;
    server.sendMessage("StrataClient", "test message");
    waitForZmqMessages();
    QVERIFY_(false == serverRevicedMessage);
    QVERIFY_(false == clientRecivedMessage);

    serverRevicedMessage = false;
    clientRecivedMessage = false;
    QVERIFY_(client.connectServer());
    waitForZmqMessages();
    QVERIFY_(serverRevicedMessage);
    QVERIFY_(clientRecivedMessage);

}
