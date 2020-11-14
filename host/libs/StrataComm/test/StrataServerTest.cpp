#include "StrataServerTest.h"
#include "../src/ClientMessage.h"

void StrataServerTest::testParseClientMessage() {
    StrataServer server(address_);
    connect(this, &StrataServerTest::mockNewMessageRecived, &server, &StrataServer::newClientMessage);

    emit mockNewMessageRecived("AAA", "clearly not a json message");
    qDebug() << "************************************************************";
    emit mockNewMessageRecived("BBB", R"({"jsonrpc": "2.0","method":"register_client","params":{"api_version": "1.0"},"id":1})");
    qDebug() << "************************************************************";
    emit mockNewMessageRecived("CCC", R"({"jsonrpc": 1,"method":"register_client","params":{"api_version": "1.0"},"id":1})");
    qDebug() << "************************************************************";
    emit mockNewMessageRecived("DDD", R"({"jsonrpc": "2.0","method":"register_client","params":{"api_version": "1.0"},"id":"1"})");
    qDebug() << "************************************************************";
    emit mockNewMessageRecived("EEE", R"({"cmd":"load_documents","payload":{"class_id":"<class_id>"}})");
    qDebug() << "************************************************************";
    emit mockNewMessageRecived("FFF", R"({"cmd":"load_documents","payload":{}})");
    qDebug() << "************************************************************";
    emit mockNewMessageRecived("GGG", R"({"cmd":"load_documents"})");
    qDebug() << "************************************************************";
}

void StrataServerTest::testValidApiVer2Message() {
    StrataServer server(address_);
    bool validMessage = false;
    connect(this, &StrataServerTest::mockNewMessageRecived, &server, &StrataServer::newClientMessage);
    connect(&server, &StrataServer::dispatchHandler, this, [&validMessage](){
        validMessage = true;
    });

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
}

void StrataServerTest::testValidApiVer1Message() {
    StrataServer server(address_);
    bool validMessage = false;
    connect(this, &StrataServerTest::mockNewMessageRecived, &server, &StrataServer::newClientMessage);
    connect(&server, &StrataServer::dispatchHandler, this, [&validMessage](){
        validMessage = true;
    });

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
}

void StrataServerTest::testFloodTheServer() {
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

    qDebug() << "tests" << counter;
}

void StrataServerTest::testBuildNotificationApiV2() {
    StrataServer server(address_);
    strata::strataComm::ClientMessage cm;

    cm.messageID = 0;
    cm.handlerName = "Magic_";
    server.buildNotificationApiv2(cm, {{"This", "That"},{"name", "Mohammed"}});
}



