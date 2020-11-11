#include "QzmqTest.h"

// temp test, needs to be improved.
void ServerConnectorTest::testServerConnector()
{
    QSKIP("disabled for now...");
    strata::strataComm::ServerConnector connector(address_);
    QCOMPARE(connector.initilize(), true);

    QTest::qWait(100);
    QCoreApplication::processEvents(QEventLoop::WaitForMoreEvents);

    connector.sendMessage(QByteArray::fromHex("414141"), "this message is meant to be to 414141");
    connector.sendMessage(QByteArray::fromHex("424242"), "this message is meant to be to 424242");

    QTest::qWait(100);
    QCoreApplication::processEvents(QEventLoop::WaitForMoreEvents);
}

void ServerConnectorTest::testOpenServerConnectorFaild()
{
    QSKIP("disabled for now...");
    strata::strataComm::ServerConnector connector("tcp://127.0.0.1:5564");
    QCOMPARE(connector.initilize(), true);

    strata::strataComm::ServerConnector connectorDublicate("tcp://127.0.0.1:5564");
    QCOMPARE(connectorDublicate.initilize(), false);
}

void ServerConnectorTest::testClientConnector() {
    QSKIP("disabled for now...");
    strata::strataComm::ClientConnector clientConnector(address_);
    QCOMPARE_(clientConnector.initilize(), true);

    strata::strataComm::ClientConnector clientConnectorDublicate(address_);
    QCOMPARE_(clientConnectorDublicate.initilize(), false);
}

void ServerConnectorTest::testOpenClientConnectorFaild() {
    QSKIP("disabled for now...");
    strata::strataComm::ClientConnector clientConnector(address_);
    QCOMPARE_(clientConnector.initilize(), true);
    //clientConnector.readMessages();

    clientConnector.sendMessage(R"({"hcs::cmd":"dynamic_platform_list","payload":{}})");

//    QTest::qWait(100);
//    clientConnector.readMessages();
   QCoreApplication::processEvents(QEventLoop::WaitForMoreEvents);
}

void ServerConnectorTest::testServerAndClient() {
    // Create server
    strata::strataComm::ServerConnector server(address_);
    QCOMPARE_(server.initilize(), true);

    // Create Client
    std::string client_id = "client_1";
    strata::strataComm::ClientConnector client(address_, client_id);
    QCOMPARE_(client.initilize(), true);

    // Do Communication...
    server.sendMessage(QByteArray::fromStdString(client_id), "message From the server!");

    QCoreApplication::processEvents(QEventLoop::WaitForMoreEvents);

    client.sendMessage("message from the client!!");

    QTest::qWait(100);
    QCoreApplication::processEvents(QEventLoop::WaitForMoreEvents);
}

