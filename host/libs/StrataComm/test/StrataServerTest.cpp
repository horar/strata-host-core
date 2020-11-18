#include "StrataServerTest.h"
#include "../src/ClientConnector.h"

void StrataServerTest::testValidApiVer2Message() {
    StrataServer server(address_);
    bool validMessage = false;
    connect(this, &StrataServerTest::mockNewMessageRecived, &server, &StrataServer::newClientMessage);

    // Connect a handler to verify that the message got parsed and the dispatch signal got emitted. 
    connect(&server, &StrataServer::dispatchHandler, this, [&validMessage](){
        validMessage = true;
    });

    // This will register the client and sets the api as v2
    validMessage = false;
    emit mockNewMessageRecived("AAA", R"({"jsonrpc": "2.0","method":"register_client","params":{"api_version": "1.0"},"id":1})");
    QVERIFY_(validMessage);

    validMessage = false;
    emit mockNewMessageRecived("AAA", R"({"jsonrpc": "2.0","method":"register_client","params":{"api_version": "1.0"},"id":1})");
    QVERIFY_(validMessage);

    validMessage = false;
    emit mockNewMessageRecived("AAA", R"({"jsonrpc": "2.0","method":"register_client","params":{"api_version": "1.0"},"id":1})");
    QVERIFY_(validMessage);

    validMessage = false;
    emit mockNewMessageRecived("AAA", R"({"jsonrpc": "2.0","method":"register_client","params":{"api_version": "1.0"},"id":1})");
    QVERIFY_(validMessage);

    validMessage = false;
    emit mockNewMessageRecived("AAA", R"({"cmd":"load_documents","payload":{}})");
    QVERIFY_(false == validMessage);

    validMessage = false;
    emit mockNewMessageRecived("AAA", R"()");
    QVERIFY_(false == validMessage);

    validMessage = false;
    emit mockNewMessageRecived("AAA", R"(0000)");
    QVERIFY_(false == validMessage);

    validMessage = false;
    emit mockNewMessageRecived("AAA", R"(invalid message)");
    QVERIFY_(false == validMessage);

    validMessage = false;
    emit mockNewMessageRecived("AAA", R"({"jsonrpc": 2.0,"method":"register_client","params":{"api_version": "1.0"},"id":1})");
    QVERIFY_(false == validMessage);
}

void StrataServerTest::testValidApiVer1Message() {
    StrataServer server(address_);
    bool validMessage = false;
    connect(this, &StrataServerTest::mockNewMessageRecived, &server, &StrataServer::newClientMessage);
    connect(&server, &StrataServer::dispatchHandler, this, [&validMessage](){
        validMessage = true;
    });

    // This will register the client and sets the api as v1
    validMessage = false;
    emit mockNewMessageRecived("AAA", R"({"cmd":"register_client", "payload":{}})");
    QVERIFY_(validMessage);

    validMessage = false;
    emit mockNewMessageRecived("AAA", R"({"cmd":"load_documents","payload":{}})");
    QVERIFY_(validMessage);


    validMessage = false;
    emit mockNewMessageRecived("AAA", R"({"sscmd":"load_documents","payload":{}})");
    QVERIFY_(false == validMessage);

    validMessage = false;
    emit mockNewMessageRecived("AAA", R"({"cmd":0,"payload":{}})");
    QVERIFY_(false == validMessage);

    validMessage = false;
    emit mockNewMessageRecived("AAA", R"({"jsonrpc": "2.0","method":"register_client","params":{"api_version": "1.0"},"id":1})");
    QVERIFY_(false == validMessage);

    validMessage = false;
    emit mockNewMessageRecived("AAA", R"()");
    QVERIFY_(false == validMessage);

    validMessage = false;
    emit mockNewMessageRecived("AAA", R"(0000)");
    QVERIFY_(false == validMessage);

    validMessage = false;
    emit mockNewMessageRecived("AAA", R"(invalid message)");
    QVERIFY_(false == validMessage);
}

void StrataServerTest::testFloodTheServer() {
    QSKIP("too large to during development");
    StrataServer server(address_);
    int counter = 0;
    int testSize = 1000;
    connect(this, &StrataServerTest::mockNewMessageRecived, &server, &StrataServer::newClientMessage);
    connect(&server, &StrataServer::dispatchHandler, this, [&counter](){
        counter++;
    });

    for (int i=0; i < testSize; i++) {
        emit mockNewMessageRecived(QByteArray::number(i), R"({"cmd":"register_client", "payload":{}})");
    }

    QCOMPARE_(counter, testSize);
}

void StrataServerTest::testBuildNotificationApiV2() {
    StrataServer server(address_);
    server.init();

    strata::strataComm::ClientConnector client(address_, "AA");
    client.initilize();
    connect(&client, &strata::strataComm::ClientConnector::newMessageRecived, this, [](const QByteArray &message) {
        qDebug() << "******* client:" << message;
        // TODO: add validation to make this test meaningful.
    });
    client.sendMessage(R"({"jsonrpc": "2.0","method":"register_client","params": {"api_version": "1.0"},"id":1})");

    server.registerHandler("test_response", [&server](const strata::strataComm::ClientMessage &cm){
        // verify the thing here
        server.notifyClient(cm, {{"key", "value"}, {"test", "test"}}, strata::strataComm::ClientMessage::ResponseType::Response);
    });

    server.registerHandler("test_notification", [&server](const strata::strataComm::ClientMessage &cm){
        // verify the thing here
        server.notifyClient(cm, {{"key", "value"}, {"test", "test"}}, strata::strataComm::ClientMessage::ResponseType::Notification);
    });

    server.registerHandler("test_error", [&server](const strata::strataComm::ClientMessage &cm){
        // verify the thing here
        server.notifyClient(cm, {{"key", "value"}, {"test", "test"}}, strata::strataComm::ClientMessage::ResponseType::Error);
    });

    server.registerHandler("test_platformMessage", [&server](const strata::strataComm::ClientMessage &cm){
        // verify the thing here
        server.notifyClient(cm, {{"key", "value"}, {"test", "test"}}, strata::strataComm::ClientMessage::ResponseType::PlatformMessage);
    });

    client.sendMessage(R"({"jsonrpc": "2.0","method":"test_response","params":{},"id":1})");
    client.sendMessage(R"({"jsonrpc": "2.0","method":"test_notification","params":{},"id":1})");
    client.sendMessage(R"({"jsonrpc": "2.0","method":"test_error","params":{},"id":1})");
    client.sendMessage(R"({"jsonrpc": "2.0","method":"test_platformMessage","params":{},"id":1})");

    // verify that the thing is valid in the handlers.
    QTimer timer;
    // wait for the messages
    timer.setSingleShot(true);
    timer.start(100);
    do {
        QCoreApplication::processEvents(QEventLoop::WaitForMoreEvents);
    } while (timer.isActive());
}

void StrataServerTest::testServerFunctionality() {
    StrataServer server(address_);
    server.init();

    // add a handler to handler the client message.
    // add a handler to create a response
    server.registerHandler("register_client", [&server](const strata::strataComm::ClientMessage &cm) {
        server.notifyClient(cm, {{"status", "client registered."}}, strata::strataComm::ClientMessage::ResponseType::Response);
    });

    bool clientGotResponse = false;
    strata::strataComm::ClientConnector client(address_, "AA");
    connect(&client, &strata::strataComm::ClientConnector::newMessageRecived, this, [&clientGotResponse](const QByteArray &message){
        QCOMPARE_(
            message,
            "{\"id\":1,\"jsonrpc\":\"2.0\",\"method\":\"register_client\",\"result\":{\"status\":\"client registered.\"}}"
        );
        clientGotResponse = true;
    });
    client.initilize();
    client.sendMessage(R"({"jsonrpc": "2.0","method":"register_client","params": {"api_version": "1.0"},"id":1})");

    bool clientGotResponse_2 = false;
    strata::strataComm::ClientConnector client_2(address_, "BB");
    connect(&client_2, &strata::strataComm::ClientConnector::newMessageRecived, this, [&clientGotResponse_2](const QByteArray &message){
        QCOMPARE_(
            message,
            "{\"hcs::notification\":{\"status\":\"client registered.\"}}"
        );
        clientGotResponse_2 = true;
    });
    client_2.initilize();
    client_2.sendMessage(R"({"cmd":"register_client", "payload":{}})");

    QTimer timer;
    // wait for the messages
    timer.setSingleShot(true);
    timer.start(100);
    do {
        QCoreApplication::processEvents(QEventLoop::WaitForMoreEvents);
    } while (timer.isActive());

    QVERIFY_(clientGotResponse);
    QVERIFY_(clientGotResponse_2);
}

void StrataServerTest::testBuildPlatformMessageV1() {
    StrataServer server(address_);
    // WIP
}
