#include "StrataClientTest.h"

#include "../src/ServerConnector.h"

void StrataClientTest::testRegisterAndUnregisterHandlers() 
{
    StrataClient client(address_);
    
    // register new handler
    QVERIFY_(client.registerHandler("handler_1", [](const strata::strataComm::ClientMessage &cm){return;}));
    QVERIFY_(client.registerHandler("handler_2", [](const strata::strataComm::ClientMessage &cm){return;}));
    QVERIFY_(false == client.registerHandler("handler_2", [](const strata::strataComm::ClientMessage &cm){return;}));

    QVERIFY_(client.unregisterHandler("handler_1"));
    QVERIFY_(client.unregisterHandler("handler_2"));
    QVERIFY_(client.unregisterHandler("handler_2"));
    QVERIFY_(client.unregisterHandler("not_registered_handler"));
}

void StrataClientTest::testConnectDisconnectToTheServer() 
{
    QTimer timer;
    // create a serverConnector
    // init the serverConnector
    strata::strataComm::ServerConnector server(address_);
    server.initilize();

    // create a handler for the server
    connect(&server, &strata::strataComm::ServerConnector::newMessageRecived, this, [&server](const QByteArray &clientId, const QByteArray &message) {
        qDebug() << "ServerConnector new message handler. client id:" << clientId << "message" << message;
        server.sendMessage(clientId, message);
    });

    // create a StrataClient
    // connect to the server
    StrataClient client(address_);
    QVERIFY_(client.connectServer());

    // verify that the server got the message
    // send a message to the client
    // wait for the messages
    timer.setSingleShot(true);
    timer.start(100);
    do {
        QCoreApplication::processEvents(QEventLoop::WaitForMoreEvents);
    } while (timer.isActive());

    // disconnect the client from the server
    // verify that the server got the message
    // not functional
    client.disconnectServer();

    // wait for the messages
    timer.setSingleShot(true);
    timer.start(100);
    do {
        QCoreApplication::processEvents(QEventLoop::WaitForMoreEvents);
    } while (timer.isActive());
}
