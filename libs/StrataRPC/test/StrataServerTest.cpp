/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "StrataServerTest.h"
#include "ClientConnector.h"

#include <QMetaObject>
#include <QSignalSpy>

QTEST_MAIN(StrataServerTest)

using strata::strataRPC::StrataServer;
using strata::strataRPC::ClientConnector;

#ifdef false
constexpr int zmqWaitTimeSuccess = 250; // newarly always skipped, will never wait this long unless CPU is stalled
constexpr int zmqWaitTime = 50;         // will always wait this long checking for failures, etc

void StrataServerTest::testValidApiVer2Message()
{
    StrataServer server(address_, false);
    bool validMessage = false;

    // Connect a handler to verify that the message got parsed and the dispatch signal got emitted.
    connect(&server, &StrataServer::MessageParsed, this,
            [&validMessage]() { validMessage = true; });

    // This will register the client and sets the api as v2
    validMessage = false;
    QMetaObject::invokeMethod(
        &server, "messageReceived", Qt::DirectConnection, Q_ARG(QByteArray, "AAA"),
        Q_ARG(
            QByteArray,
            R"({"jsonrpc": "2.0","method":"register_client","params":{"api_version": "1.0"},"id":1})"));
    QVERIFY(validMessage);

    validMessage = false;
    QMetaObject::invokeMethod(
        &server, "messageReceived", Qt::DirectConnection, Q_ARG(QByteArray, "AAA"),
        Q_ARG(
            QByteArray,
            R"({"jsonrpc": "2.0","method":"register_client","params":{"api_version": "1.0"},"id":1})"));
    QVERIFY(validMessage);

    validMessage = false;
    QMetaObject::invokeMethod(
        &server, "messageReceived", Qt::DirectConnection, Q_ARG(QByteArray, "AAA"),
        Q_ARG(
            QByteArray,
            R"({"jsonrpc": "2.0","method":"register_client","params":{"api_version": "1.0"},"id":1})"));
    QVERIFY(validMessage);

    validMessage = false;
    QMetaObject::invokeMethod(
        &server, "messageReceived", Qt::DirectConnection, Q_ARG(QByteArray, "AAA"),
        Q_ARG(
            QByteArray,
            R"({"jsonrpc": "2.0","method":"register_client","params":{"api_version": "1.0"},"id":1})"));
    QVERIFY(validMessage);

    validMessage = false;
    QMetaObject::invokeMethod(&server, "messageReceived", Qt::DirectConnection,
                              Q_ARG(QByteArray, "AAA"),
                              Q_ARG(QByteArray, R"({"cmd":"load_documents","payload":{}})"));
    QVERIFY(false == validMessage);

    validMessage = false;
    QMetaObject::invokeMethod(&server, "messageReceived", Qt::DirectConnection,
                              Q_ARG(QByteArray, "AAA"), Q_ARG(QByteArray, R"()"));
    QVERIFY(false == validMessage);

    validMessage = false;
    QMetaObject::invokeMethod(&server, "messageReceived", Qt::DirectConnection,
                              Q_ARG(QByteArray, "AAA"), Q_ARG(QByteArray, R"(0000)"));
    QVERIFY(false == validMessage);

    validMessage = false;
    QMetaObject::invokeMethod(&server, "messageReceived", Qt::DirectConnection,
                              Q_ARG(QByteArray, "AAA"), Q_ARG(QByteArray, R"(invalid message)"));
    QVERIFY(false == validMessage);

    validMessage = false;
    QMetaObject::invokeMethod(
        &server, "messageReceived", Qt::DirectConnection, Q_ARG(QByteArray, "AAA"),
        Q_ARG(
            QByteArray,
            R"({"jsonrpc": 2.0,"method":"register_client","params":{"api_version": "1.0"},"id":1})"));
    QVERIFY(false == validMessage);
}

void StrataServerTest::testValidApiVer1Message()
{
    StrataServer server(address_, false);
    bool validMessage = false;
    connect(&server, &StrataServer::MessageParsed, this,
            [&validMessage]() { validMessage = true; });

    // This will register the client and sets the api as v1
    validMessage = false;
    QMetaObject::invokeMethod(&server, "messageReceived", Qt::DirectConnection,
                              Q_ARG(QByteArray, "AAA"),
                              Q_ARG(QByteArray, R"({"cmd":"register_client", "payload":{}})"));
    QVERIFY(validMessage);

    validMessage = false;
    QMetaObject::invokeMethod(&server, "messageReceived", Qt::DirectConnection,
                              Q_ARG(QByteArray, "AAA"),
                              Q_ARG(QByteArray, R"({"cmd":"load_documents","payload":{}})"));
    QVERIFY(validMessage);

    validMessage = false;
    QMetaObject::invokeMethod(&server, "messageReceived", Qt::DirectConnection,
                              Q_ARG(QByteArray, "AAA"),
                              Q_ARG(QByteArray, R"({"sscmd":"load_documents","payload":{}})"));
    QVERIFY(false == validMessage);

    validMessage = false;
    QMetaObject::invokeMethod(&server, "messageReceived", Qt::DirectConnection,
                              Q_ARG(QByteArray, "AAA"),
                              Q_ARG(QByteArray, R"({"cmd":0,"payload":{}})"));
    QVERIFY(false == validMessage);

    validMessage = false;
    QMetaObject::invokeMethod(
        &server, "messageReceived", Qt::DirectConnection, Q_ARG(QByteArray, "AAA"),
        Q_ARG(
            QByteArray,
            R"({"jsonrpc": "2.0","method":"register_client","params":{"api_version": "1.0"},"id":1})"));
    QVERIFY(false == validMessage);

    validMessage = false;
    QMetaObject::invokeMethod(&server, "messageReceived", Qt::DirectConnection,
                              Q_ARG(QByteArray, "AAA"), Q_ARG(QByteArray, R"()"));
    QVERIFY(false == validMessage);

    validMessage = false;
    QMetaObject::invokeMethod(&server, "messageReceived", Qt::DirectConnection,
                              Q_ARG(QByteArray, "AAA"), Q_ARG(QByteArray, R"(0000)"));
    QVERIFY(false == validMessage);

    validMessage = false;
    QMetaObject::invokeMethod(&server, "messageReceived", Qt::DirectConnection,
                              Q_ARG(QByteArray, "AAA"), Q_ARG(QByteArray, R"(invalid message)"));
    QVERIFY(false == validMessage);
}

void StrataServerTest::testFloodTheServer()
{
    // QSKIP("too large to during development");
    StrataServer server(address_, false);
    int counter = 0;
    int testSize = 1000;
    connect(&server, &StrataServer::MessageParsed, this, [&counter]() { counter++; });

    for (int i = 0; i < testSize; i++) {
        QMetaObject::invokeMethod(&server, "messageReceived", Qt::DirectConnection,
                                  Q_ARG(QByteArray, QByteArray::number(i)),
                                  Q_ARG(QByteArray, R"({"cmd":"register_client", "payload":{}})"));
    }

    QCOMPARE(counter, testSize);
}

void StrataServerTest::testServerFunctionality()
{
    StrataServer server(address_, false);
    QSignalSpy serverInitialized(&server, &StrataServer::initialized);
    QVERIFY(serverInitialized.isValid());
    server.initialize();
    QVERIFY((serverInitialized.count() == 1) || (serverInitialized.wait(zmqWaitTimeSuccess) == true));

    // add a handler to handler the client message.
    // add a handler to create a response
    server.registerHandler("register_client", [&server](const strata::strataRPC::Message &message) {
        server.notifyClient(message, {{"status", "client registered"}},
                            strata::strataRPC::ResponseType::Response);
    });

    bool clientGotResponse = false;
    ClientConnector client(address_, "AA");
    connect(
        &client, &ClientConnector::messageReceived, this,
        [&clientGotResponse](const QByteArray &message) {
            QCOMPARE(
                message,
                "{\"id\":1,\"jsonrpc\":\"2.0\",\"result\":{\"status\":\"client registered\"}}");
            clientGotResponse = true;
        });

    QSignalSpy clientConnected(&client, &ClientConnector::connected);
    QVERIFY(clientConnected.isValid());
    QCOMPARE(client.initialize(), true);
    QVERIFY((clientConnected.count() == 1) || (clientConnected.wait(zmqWaitTimeSuccess) == true));

    client.sendMessage(
        R"({"jsonrpc": "2.0","method":"register_client","params": {"api_version": "1.0"},"id":1})");

    bool clientGotResponse_2 = false;
    ClientConnector client_2(address_, "BB");
    connect(&client_2, &ClientConnector::messageReceived, this,
            [&clientGotResponse_2](const QByteArray &message) {
                QCOMPARE(message,
                          "{\"hcs::notification\":{\"status\":\"client "
                          "registered\",\"type\":\"register_client\"}}");
                clientGotResponse_2 = true;
            });

    QSignalSpy clientConnected_2(&client_2, &ClientConnector::connected);
    QVERIFY(clientConnected_2.isValid());
    client_2.initialize();
    QVERIFY((clientConnected_2.count() == 1) || (clientConnected_2.wait(zmqWaitTimeSuccess) == true));

    client_2.sendMessage(R"({"cmd":"register_client", "payload":{}})");

    QTRY_VERIFY_WITH_TIMEOUT(clientGotResponse, zmqWaitTimeSuccess);
    QTRY_VERIFY_WITH_TIMEOUT(clientGotResponse_2, zmqWaitTimeSuccess);
}

void StrataServerTest::testBuildNotificationApiV2()
{
    bool testExecuted = false;
    StrataServer server(address_, false);
    QSignalSpy serverInitialized(&server, &StrataServer::initialized);
    QVERIFY(serverInitialized.isValid());
    server.initialize();
    QVERIFY((serverInitialized.count() == 1) || (serverInitialized.wait(zmqWaitTimeSuccess) == true));

    ClientConnector client(address_, "AA");
    QSignalSpy clientConnected(&client, &ClientConnector::connected);
    QVERIFY(clientConnected.isValid());
    QCOMPARE(client.initialize(), true);
    QVERIFY((clientConnected.count() == 1) || (clientConnected.wait(zmqWaitTimeSuccess) == true));

    connect(
        &client, &ClientConnector::messageReceived, this,
        [&testExecuted](const QByteArray &message) {
            // ignore the response to the unregistered handler
            if (message == R"({"error":{"message":"Handler not found."},"id":1,"jsonrpc":"2.0"})") {
                return;
            }

            QJsonParseError jsonParseError;
            QJsonDocument jsonDocument = QJsonDocument::fromJson(message, &jsonParseError);
            QVERIFY(jsonParseError.error == QJsonParseError::NoError);
            QJsonObject jsonObject = jsonDocument.object();

            QVERIFY(jsonObject.contains("jsonrpc"));
            QVERIFY(jsonObject.value("jsonrpc").isString());

            QVERIFY(jsonObject.contains("method"));
            QVERIFY(jsonObject.value("method").isString());

            QVERIFY(jsonObject.contains("params"));
            QVERIFY(jsonObject.value("params").isObject());
            testExecuted = true;
        });

    client.sendMessage(
        R"({"jsonrpc": "2.0","method":"register_client","params": {"api_version": "1.0"},"id":1})");

    server.registerHandler("test_notification",
                           [&server](const strata::strataRPC::Message &message) {
                               server.notifyClient(message, {{"key", "value"}, {"test", "test"}},
                                                   strata::strataRPC::ResponseType::Notification);
                           });

    client.sendMessage(R"({"jsonrpc": "2.0","method":"test_notification","params":{},"id":2})");
    QTRY_VERIFY_WITH_TIMEOUT(testExecuted, zmqWaitTimeSuccess);
}

void StrataServerTest::testBuildResponseApiV2()
{
    bool testExecuted = false;
    StrataServer server(address_, false);
    QSignalSpy serverInitialized(&server, &StrataServer::initialized);
    QVERIFY(serverInitialized.isValid());
    server.initialize();
    QVERIFY((serverInitialized.count() == 1) || (serverInitialized.wait(zmqWaitTimeSuccess) == true));

    ClientConnector client(address_, "AA");
    QSignalSpy clientConnected(&client, &ClientConnector::connected);
    QVERIFY(clientConnected.isValid());
    QCOMPARE(client.initialize(), true);
    QVERIFY((clientConnected.count() == 1) || (clientConnected.wait(zmqWaitTimeSuccess) == true));

    connect(
        &client, &ClientConnector::messageReceived, this,
        [&testExecuted](const QByteArray &message) {
            // ignore the response to the unregistered handler
            if (message == R"({"error":{"message":"Handler not found."},"id":1,"jsonrpc":"2.0"})") {
                return;
            }

            QJsonParseError jsonParseError;
            QJsonDocument jsonDocument = QJsonDocument::fromJson(message, &jsonParseError);
            QVERIFY(jsonParseError.error == QJsonParseError::NoError);
            QJsonObject jsonObject = jsonDocument.object();

            QVERIFY(jsonObject.contains("jsonrpc"));
            QVERIFY(jsonObject.value("jsonrpc").isString());

            QVERIFY(jsonObject.contains("id"));
            QVERIFY(jsonObject.value("id").isDouble());

            QVERIFY(jsonObject.contains("result"));
            QVERIFY(jsonObject.value("result").isObject());
            testExecuted = true;
        });

    client.sendMessage(
        R"({"jsonrpc": "2.0","method":"register_client","params": {"api_version": "1.0"},"id":1})");

    server.registerHandler("test_response", [&server](const strata::strataRPC::Message &message) {
        server.notifyClient(message, {{"key", "value"}, {"test", "test"}},
                            strata::strataRPC::ResponseType::Response);
    });

    client.sendMessage(R"({"jsonrpc": "2.0","method":"test_response","params":{},"id":1})");
    QTRY_VERIFY_WITH_TIMEOUT(testExecuted, zmqWaitTimeSuccess);
}

void StrataServerTest::testBuildErrorApiV2()
{
    bool testExecuted = false;
    StrataServer server(address_, false);
    QSignalSpy serverInitialized(&server, &StrataServer::initialized);
    QVERIFY(serverInitialized.isValid());
    server.initialize();
    QVERIFY((serverInitialized.count() == 1) || (serverInitialized.wait(zmqWaitTimeSuccess) == true));

    ClientConnector client(address_, "AA");
    QSignalSpy clientConnected(&client, &ClientConnector::connected);
    QVERIFY(clientConnected.isValid());
    QCOMPARE(client.initialize(), true);
    QVERIFY((clientConnected.count() == 1) || (clientConnected.wait(zmqWaitTimeSuccess) == true));

    connect(&client, &ClientConnector::messageReceived, this,
            [&testExecuted](const QByteArray &message) {
                QJsonParseError jsonParseError;
                QJsonDocument jsonDocument = QJsonDocument::fromJson(message, &jsonParseError);
                QVERIFY(jsonParseError.error == QJsonParseError::NoError);
                QJsonObject jsonObject = jsonDocument.object();

                QVERIFY(jsonObject.contains("jsonrpc"));
                QVERIFY(jsonObject.value("jsonrpc").isString());

                QVERIFY(jsonObject.contains("id"));
                QVERIFY(jsonObject.value("id").isDouble());

                QVERIFY(jsonObject.contains("error"));
                QVERIFY(jsonObject.value("error").isObject());
                testExecuted = true;
            });

    client.sendMessage(
        R"({"jsonrpc": "2.0","method":"register_client","params": {"api_version": "1.0"},"id":1})");

    server.registerHandler("test_error", [&server](const strata::strataRPC::Message &message) {
        server.notifyClient(message, {{"key", "value"}, {"test", "test"}},
                            strata::strataRPC::ResponseType::Error);
    });

    client.sendMessage(R"({"jsonrpc": "2.0","method":"test_error","params":{},"id":3})");
    QTRY_VERIFY_WITH_TIMEOUT(testExecuted, zmqWaitTimeSuccess);
}

void StrataServerTest::testBuildPlatformMessageApiV2()
{
    bool testExecuted = false;
    StrataServer server(address_, false);
    QSignalSpy serverInitialized(&server, &StrataServer::initialized);
    QVERIFY(serverInitialized.isValid());
    server.initialize();
    QVERIFY((serverInitialized.count() == 1) || (serverInitialized.wait(zmqWaitTimeSuccess) == true));

    ClientConnector client(address_, "AA");
    QSignalSpy clientConnected(&client, &ClientConnector::connected);
    QVERIFY(clientConnected.isValid());
    QCOMPARE(client.initialize(), true);
    QVERIFY((clientConnected.count() == 1) || (clientConnected.wait(zmqWaitTimeSuccess) == true));

    connect(
        &client, &ClientConnector::messageReceived, this,
        [&testExecuted](const QByteArray &message) {
            // ignore the response to the unregistered handler
            if (message == R"({"error":{"message":"Handler not found."},"id":1,"jsonrpc":"2.0"})") {
                return;
            }

            QJsonParseError jsonParseError;
            QJsonDocument jsonDocument = QJsonDocument::fromJson(message, &jsonParseError);
            QVERIFY(jsonParseError.error == QJsonParseError::NoError);
            QJsonObject jsonObject = jsonDocument.object();

            QVERIFY(jsonObject.contains("jsonrpc"));
            QVERIFY(jsonObject.value("jsonrpc").isString());

            QVERIFY(jsonObject.contains("method"));
            QVERIFY(jsonObject.value("method").isString());
            QVERIFY(jsonObject.value("method") == "platform_notification");

            QVERIFY(jsonObject.contains("params"));
            QVERIFY(jsonObject.value("params").isObject());
            testExecuted = true;
        });

    client.sendMessage(
        R"({"jsonrpc": "2.0","method":"register_client","params": {"api_version": "1.0"},"id":1})");

    server.registerHandler(
        "platform_notification", [&server](const strata::strataRPC::Message &message) {
            server.notifyClient(message, {{"key", "value"}, {"test", "test"}},
                                strata::strataRPC::ResponseType::PlatformMessage);
        });

    client.sendMessage(R"({"jsonrpc": "2.0","method":"platform_notification","params":{},"id":4})");
    QTRY_VERIFY_WITH_TIMEOUT(testExecuted, zmqWaitTimeSuccess);
}

void StrataServerTest::testBuildNotificationApiV1()
{
    bool testExecuted = false;
    StrataServer server(address_, false);
    QSignalSpy serverInitialized(&server, &StrataServer::initialized);
    QVERIFY(serverInitialized.isValid());
    server.initialize();
    QVERIFY((serverInitialized.count() == 1) || (serverInitialized.wait(zmqWaitTimeSuccess) == true));

    ClientConnector client(address_, "AA");
    QSignalSpy clientConnected(&client, &ClientConnector::connected);
    QVERIFY(clientConnected.isValid());
    QCOMPARE(client.initialize(), true);
    QVERIFY((clientConnected.count() == 1) || (clientConnected.wait(zmqWaitTimeSuccess) == true));

    connect(&client, &ClientConnector::messageReceived, this,
            [&testExecuted](const QByteArray &message) {
                QJsonParseError jsonParseError;
                QJsonDocument jsonDocument = QJsonDocument::fromJson(message, &jsonParseError);
                QVERIFY(jsonParseError.error == QJsonParseError::NoError);
                QJsonObject jsonObject = jsonDocument.object();

                QVERIFY(jsonObject.contains("hcs::notification"));
                QVERIFY(jsonObject.value("hcs::notification").isObject());
                QVERIFY(jsonObject.value("hcs::notification").toObject().contains("type"));
                testExecuted = true;
            });

    client.sendMessage(R"({"cmd":"register_client", "payload":{}})");

    server.registerHandler("test_notification",
                           [&server](const strata::strataRPC::Message &message) {
                               server.notifyClient(message, {{"key", "value"}, {"test", "test"}},
                                                   strata::strataRPC::ResponseType::Notification);
                           });

    client.sendMessage(R"({"hcs::cmd":"test_notification","payload":{}})");

    QTRY_VERIFY_WITH_TIMEOUT(testExecuted, zmqWaitTimeSuccess);
}

void StrataServerTest::testBuildResponseApiV1()
{
    bool testExecuted = false;
    StrataServer server(address_, false);
    QSignalSpy serverInitialized(&server, &StrataServer::initialized);
    QVERIFY(serverInitialized.isValid());
    server.initialize();
    QVERIFY((serverInitialized.count() == 1) || (serverInitialized.wait(zmqWaitTimeSuccess) == true));

    ClientConnector client(address_, "AA");
    QSignalSpy clientConnected(&client, &ClientConnector::connected);
    QVERIFY(clientConnected.isValid());
    QCOMPARE(client.initialize(), true);
    QVERIFY((clientConnected.count() == 1) || (clientConnected.wait(zmqWaitTimeSuccess) == true));

    connect(&client, &ClientConnector::messageReceived, this,
            [&testExecuted](const QByteArray &message) {
                QJsonParseError jsonParseError;
                QJsonDocument jsonDocument = QJsonDocument::fromJson(message, &jsonParseError);
                QVERIFY(jsonParseError.error == QJsonParseError::NoError);
                QJsonObject jsonObject = jsonDocument.object();

                QVERIFY(jsonObject.contains("hcs::notification"));
                QVERIFY(jsonObject.value("hcs::notification").isObject());
                QVERIFY(jsonObject.value("hcs::notification").toObject().contains("type"));
                testExecuted = true;
            });

    client.sendMessage(R"({"cmd":"register_client", "payload":{}})");

    server.registerHandler("test_response", [&server](const strata::strataRPC::Message &message) {
        server.notifyClient(message, {{"key", "value"}, {"test", "test"}},
                            strata::strataRPC::ResponseType::Response);
    });

    client.sendMessage(R"({"hcs::cmd":"test_response","payload":{}})");
    QTRY_VERIFY_WITH_TIMEOUT(testExecuted, zmqWaitTimeSuccess);
}

void StrataServerTest::testParsePlatformMessageAPIv1()
{
    StrataServer server(address_, false);
    bool handlerCalled = false;
    QString currentCommandName = "";

    server.registerHandler("platform_message", [&handlerCalled, &currentCommandName](
                                                   const strata::strataRPC::Message &message) {
        QJsonObject platformCommand =
            QJsonDocument::fromJson(message.payload.value("message").toString().toUtf8()).object();
        QCOMPARE(platformCommand.value("cmd").toString(), currentCommandName);
        handlerCalled = true;
    });

    QSignalSpy serverInitialized(&server, &StrataServer::initialized);
    QVERIFY(serverInitialized.isValid());
    server.initialize();
    QVERIFY((serverInitialized.count() == 1) || (serverInitialized.wait(zmqWaitTimeSuccess) == true));

    handlerCalled = false;
    currentCommandName = "test_1";
    QMetaObject::invokeMethod(
        &server, "messageReceived", Qt::DirectConnection, Q_ARG(QByteArray, "AA"),
        Q_ARG(QByteArray, R"({"cmd":"test_1","payload":{"enable":"off"},"device_id":"949921126"})"));
    QVERIFY(handlerCalled);

    handlerCalled = false;
    currentCommandName = "test_2";
    QMetaObject::invokeMethod(
        &server, "messageReceived", Qt::DirectConnection, Q_ARG(QByteArray, "AA"),
        Q_ARG(QByteArray, R"({"cmd":"test_2","payload":"enable","device_id":"949921126"})"));
    QVERIFY(handlerCalled);

    handlerCalled = false;
    currentCommandName = "test_3";
    QMetaObject::invokeMethod(&server, "messageReceived", Qt::DirectConnection,
                              Q_ARG(QByteArray, "AA"),
                              Q_ARG(QByteArray, R"({"cmd":"test_3","device_id":"949921126"})"));
    QVERIFY(handlerCalled);

    handlerCalled = false;
    currentCommandName = "test_4";
    QMetaObject::invokeMethod(&server, "messageReceived", Qt::DirectConnection,
                              Q_ARG(QByteArray, "AA"), Q_ARG(QByteArray, R"({"cmd":"test_4"})"));
    QVERIFY(false == handlerCalled);
}

void StrataServerTest::testBuildPlatformMessageApiV1()
{
    bool testExecuted = false;
    StrataServer server(address_, false);
    QSignalSpy serverInitialized(&server, &StrataServer::initialized);
    QVERIFY(serverInitialized.isValid());
    server.initialize();
    QVERIFY((serverInitialized.count() == 1) || (serverInitialized.wait(zmqWaitTimeSuccess) == true));

    ClientConnector client(address_, "AA");
    QSignalSpy clientConnected(&client, &ClientConnector::connected);
    QVERIFY(clientConnected.isValid());
    QCOMPARE(client.initialize(), true);
    QVERIFY((clientConnected.count() == 1) || (clientConnected.wait(zmqWaitTimeSuccess) == true));

    connect(&client, &ClientConnector::messageReceived, this,
            [&testExecuted](const QByteArray &message) {
                QJsonParseError jsonParseError;
                QJsonDocument jsonDocument = QJsonDocument::fromJson(message, &jsonParseError);
                QVERIFY(jsonParseError.error == QJsonParseError::NoError);
                QJsonObject jsonObject = jsonDocument.object();

                if (jsonObject.contains("error")) {
                    // skip error messages
                    return;
                }

                QVERIFY(jsonObject.contains("notification"));
                QVERIFY(jsonObject.value("notification").isObject());
                testExecuted = true;
            });

    client.sendMessage(R"({"cmd":"register_client", "payload":{}})");

    server.registerHandler(
        "platform_notification", [&server](const strata::strataRPC::Message &message) {
            server.notifyClient(message, {{"key", "value"}, {"test", "test"}},
                                strata::strataRPC::ResponseType::PlatformMessage);
        });

    client.sendMessage(R"({"hcs::cmd":"platform_notification","payload":{}})");
    QTRY_VERIFY_WITH_TIMEOUT(testExecuted, zmqWaitTimeSuccess);
}

void StrataServerTest::testNotifyAllClients()
{
    QTimer timer;
    StrataServer server(address_, false);
    std::vector<ClientConnector *> clientsList;
    int counter = 0;
    int clientsCount = 10;

    QSignalSpy serverInitialized(&server, &StrataServer::initialized);
    QVERIFY(serverInitialized.isValid());
    server.initialize();
    QVERIFY((serverInitialized.count() == 1) || (serverInitialized.wait(zmqWaitTimeSuccess) == true));

    // half the clients use API v2
    for (int i = 0; i < clientsCount / 2; i++) {
        ClientConnector* client_v2 =
                new ClientConnector(address_, QByteArray::number(i));
        clientsList.push_back(client_v2);

        QSignalSpy clientConnected(client_v2, &ClientConnector::connected);
        QSignalSpy messageReceived(client_v2, &ClientConnector::messageReceived);
        QVERIFY(clientConnected.isValid());
        QVERIFY(messageReceived.isValid());
        QCOMPARE(client_v2->initialize(), true);
        QVERIFY((clientConnected.count() == 1) || (clientConnected.wait(zmqWaitTimeSuccess) == true));

        connect(client_v2, &ClientConnector::messageReceived, this,
                [&counter](const QByteArray &message) {
                    // ignore the response to the unregistered handler
                    if (message ==
                        R"({"error":{"message":"Handler not found."},"id":1,"jsonrpc":"2.0"})") {
                        return;
                    }

                    // validate for API v2
                    // expected response format:
                    // {
                    //     "jsonrpc": "2.0",
                    //     "method": "test_broadcast",
                    //     "params": {
                    //         "test": "test"
                    //     }
                    // }

                    QJsonDocument jsonDocument = QJsonDocument::fromJson(message);
                    QJsonObject jsonObject = jsonDocument.object();

                    QVERIFY(jsonObject.contains("jsonrpc"));
                    QVERIFY(jsonObject.contains("method"));
                    QVERIFY(jsonObject.contains("params"));
                    QVERIFY(jsonObject.value("params").isObject());

                    QCOMPARE(jsonObject.value("jsonrpc").toString(), "2.0");
                    QCOMPARE(jsonObject.value("method").toString(), "test_broadcast");

                    QJsonObject tempExpectedPayload{{"test", "test"}};
                    QCOMPARE(jsonObject.value("params").toObject(), tempExpectedPayload);
                    counter++;
                });
        client_v2->sendMessage(
            R"({"jsonrpc": "2.0","method":"register_client","params": {"api_version": "1.0"},"id":1})");
        QVERIFY((messageReceived.count() == 1) || (messageReceived.wait(zmqWaitTimeSuccess) == true));
    }

    // other half uses API v1
    for (int i = clientsCount / 2; i < clientsCount; i++) {
        ClientConnector* client_v1 =
                new ClientConnector(address_, QByteArray::number(i));
        clientsList.push_back(client_v1);

        QSignalSpy clientConnected(client_v1, &ClientConnector::connected);
        QSignalSpy messageReceived(client_v1, &ClientConnector::messageReceived);
        QVERIFY(clientConnected.isValid());
        QVERIFY(messageReceived.isValid());
        QCOMPARE(client_v1->initialize(), true);
        QVERIFY((clientConnected.count() == 1) || (clientConnected.wait(zmqWaitTimeSuccess) == true));

        connect(client_v1, &ClientConnector::messageReceived, this,
                [&counter](const QByteArray &message) {
                    // validate for API v1
                    // expected response format:
                    // {
                    //     "hcs::notification": {
                    //         "type": "test_broadcast",
                    //         "test": "test"
                    //     }
                    // }

                    QJsonDocument jsonDocument = QJsonDocument::fromJson(message);
                    QJsonObject jsonObject = jsonDocument.object();

                    if (jsonObject.contains("error")) {
                        // skip error messages
                        return;
                    }

                    QVERIFY(jsonObject.contains("hcs::notification"));
                    QVERIFY(jsonObject.value("hcs::notification").isObject());

                    QJsonObject payloadJsonObject =
                        jsonObject.value("hcs::notification").toObject();

                    QVERIFY(payloadJsonObject.contains("type"));
                    QVERIFY(payloadJsonObject.contains("test"));

                    QCOMPARE(payloadJsonObject.value("type").toString(), "test_broadcast");
                    QCOMPARE(payloadJsonObject.value("test").toString(), "test");

                    counter++;
                });
        client_v1->sendMessage(R"({"cmd":"register_client", "payload":{}})");
        QVERIFY((messageReceived.count() == 1) || (messageReceived.wait(zmqWaitTimeSuccess) == true));
    }

    server.notifyAllClients("test_broadcast", {{"test", "test"}});

    // wait for the broadcast messages
    timer.setSingleShot(true);
    timer.start(zmqWaitTimeSuccess);
    do {
        QCoreApplication::processEvents(QEventLoop::WaitForMoreEvents);
        if (counter == clientsCount) {
            break;
        }
    } while (timer.isActive());

    for (auto client : clientsList) {
        delete client;
    }
}

void StrataServerTest::testNotifyClientByClientId()
{
    bool testExecuted = false;
    StrataServer server(address_, false);
    QSignalSpy serverInitialized(&server, &StrataServer::initialized);
    QVERIFY(serverInitialized.isValid());
    server.initialize();
    QVERIFY((serverInitialized.count() == 1) || (serverInitialized.wait(zmqWaitTimeSuccess) == true));

    ClientConnector client(address_, "AA");
    QSignalSpy clientConnected(&client, &ClientConnector::connected);
    QVERIFY(clientConnected.isValid());
    QCOMPARE(client.initialize(), true);
    QVERIFY((clientConnected.count() == 1) || (clientConnected.wait(zmqWaitTimeSuccess) == true));

    QSignalSpy messageReceived(&client, &ClientConnector::messageReceived);
    QVERIFY(messageReceived.isValid());
    client.sendMessage(
        R"({"jsonrpc": "2.0","method":"register_client","params": {"api_version": "1.0"},"id":1})");
    QVERIFY((messageReceived.count() == 1) || (messageReceived.wait(zmqWaitTimeSuccess) == true));
    messageReceived.clear();

    connect(&client, &ClientConnector::messageReceived, this,
            [&testExecuted](const QByteArray &message) {
                QJsonParseError jsonParseError;
                QJsonDocument jsonDocument = QJsonDocument::fromJson(message, &jsonParseError);

                QVERIFY(jsonParseError.error == QJsonParseError::NoError);

                QJsonObject jsonObject = jsonDocument.object();

                QVERIFY(jsonObject.contains("method"));
                QVERIFY(jsonObject.value("method").isString());
                QCOMPARE(jsonObject.value("method").toString(), "test_handler");
                testExecuted = true;
            });

    server.notifyClient("AA", "test_handler", QJsonObject({{"key", "value"}}),
                        strata::strataRPC::ResponseType::Notification);

    QVERIFY((messageReceived.count() == 1) || (messageReceived.wait(zmqWaitTimeSuccess) == true));
    QVERIFY(testExecuted);
}

void StrataServerTest::testNotifyClientToNonExistingClient()
{
    StrataServer server(address_, false);
    QSignalSpy serverInitialized(&server, &StrataServer::initialized);
    QVERIFY(serverInitialized.isValid());
    server.initialize();
    QVERIFY((serverInitialized.count() == 1) || (serverInitialized.wait(zmqWaitTimeSuccess) == true));

    ClientConnector client(address_, "AA");
    connect(
        &client, &ClientConnector::messageReceived, this,
        [](const QByteArray &) { QFAIL("Messages should not be sent to unregistered Clients."); });

    server.notifyClient("AA", "test_handler", QJsonObject({{"key", "value"}}),
                        strata::strataRPC::ResponseType::Notification);
    waitForZmqMessages(zmqWaitTime);
}

void StrataServerTest::testInitializeServerFail()
{
    StrataServer server(address_, false);
    StrataServer duplicateServer(address_);

    QSignalSpy serverInitialized(&server, &StrataServer::initialized);
    QVERIFY(serverInitialized.isValid());
    server.initialize();
    QVERIFY((serverInitialized.count() == 1) || (serverInitialized.wait(zmqWaitTimeSuccess) == true));

    QSignalSpy errorOccurred(&duplicateServer, &StrataServer::errorOccurred);
    QVERIFY(errorOccurred.isValid());
    duplicateServer.initialize();
    QVERIFY((errorOccurred.count() == 1) || (errorOccurred.wait(zmqWaitTimeSuccess) == true));
    auto errorType = qvariant_cast<StrataServer::ServerError>(errorOccurred.takeFirst().at(0));
    QCOMPARE(errorType, StrataServer::ServerError::FailedToInitializeServer);
}

void StrataServerTest::testdefaultHandlers()
{
    StrataServer server(address_, true);
    QSignalSpy serverInitialized(&server, &StrataServer::initialized);
    QVERIFY(serverInitialized.isValid());
    server.initialize();
    QVERIFY((serverInitialized.count() == 1) || (serverInitialized.wait(zmqWaitTimeSuccess) == true));

    bool testExecuted_1 = false;
    bool testExecuted_2 = false;

    ClientConnector client(address_, "AA");
    QSignalSpy clientConnected(&client, &ClientConnector::connected);
    QSignalSpy clientInitialized(&client, &ClientConnector::initialized);
    QVERIFY(clientConnected.isValid());
    QVERIFY(clientInitialized.isValid());

    QCOMPARE(client.initialize(), true);
    QVERIFY((clientConnected.count() == 1) || (clientConnected.wait(zmqWaitTimeSuccess) == true));
    QVERIFY((clientInitialized.count() == 1) || (clientInitialized.wait(zmqWaitTimeSuccess) == true));

    client.sendMessage(
        R"({"jsonrpc": "2.0","method":"register_client","params": {"api_version": "2.0"},"id":1})");
    connect(&client, &ClientConnector::messageReceived, this,
            [&testExecuted_1](const QByteArray &message) {
                QJsonParseError jsonParseError;
                QJsonDocument jsonDocument = QJsonDocument::fromJson(message, &jsonParseError);

                QVERIFY(jsonParseError.error == QJsonParseError::NoError);

                QJsonObject jsonObject = jsonDocument.object();

                QVERIFY(jsonObject.contains("result"));
                QVERIFY(jsonObject.value("result").isObject());
                QCOMPARE(jsonObject.value("result").toObject(),
                          QJsonObject({{"status", "client registered"}}));
                testExecuted_1 = true;
            });

    ClientConnector client_2(address_, "BB");
    QSignalSpy clientConnected_2(&client_2, &ClientConnector::connected);
    QSignalSpy clientInitialized_2(&client_2, &ClientConnector::initialized);
    QVERIFY(clientConnected_2.isValid());
    QVERIFY(clientInitialized_2.isValid());

    QCOMPARE(client_2.initialize(), true);
    QVERIFY((clientConnected_2.count() == 1) || (clientConnected_2.wait(zmqWaitTimeSuccess) == true));
    QVERIFY((clientInitialized_2.count() == 1) || (clientInitialized_2.wait(zmqWaitTimeSuccess) == true));

    client_2.sendMessage(
        R"({"jsonrpc": "2.0","method":"register_client","params": {"api_version": "1.0"},"id":1})");
    connect(&client_2, &ClientConnector::messageReceived, this,
            [&testExecuted_2](const QByteArray &message) {
                QJsonParseError jsonParseError;
                QJsonDocument jsonDocument = QJsonDocument::fromJson(message, &jsonParseError);

                QVERIFY(jsonParseError.error == QJsonParseError::NoError);

                QJsonObject jsonObject = jsonDocument.object();

                QVERIFY(jsonObject.contains("error"));
                QVERIFY(jsonObject.value("error").isObject());
                QCOMPARE(
                    jsonObject.value("error").toObject(),
                    QJsonObject({{"message", "Failed to register client, Unknown API Version."}}));
                testExecuted_2 = true;
            });

    QTRY_VERIFY_WITH_TIMEOUT(testExecuted_1, zmqWaitTimeSuccess);
    QTRY_VERIFY_WITH_TIMEOUT(testExecuted_2, zmqWaitTimeSuccess);
}

void StrataServerTest::testErrorOccourredSignal()
{
    qRegisterMetaType<StrataServer::ServerError>("StrataServer::ServerError");

    StrataServer server(address_, true, this);
    ClientConnector client(address_, "AA");
    StrataServer::ServerError errorType;
    QSignalSpy errorOccurred(&server, &StrataServer::errorOccurred);
    QVERIFY(errorOccurred.isValid());

    server.registerHandler("handler_1", [](const strata::strataRPC::Message &) { return; });
    server.registerHandler("handler_1", [](const strata::strataRPC::Message &) { return; });
    QVERIFY((errorOccurred.count() == 1) || (errorOccurred.wait(zmqWaitTimeSuccess) == true));
    errorType = qvariant_cast<StrataServer::ServerError>(errorOccurred.takeFirst().at(0));
    QCOMPARE(errorType, StrataServer::ServerError::FailedToRegisterHandler);
    errorOccurred.clear();

    server.unregisterHandler("handler_2");
    QVERIFY((errorOccurred.count() == 1) || (errorOccurred.wait(zmqWaitTimeSuccess) == true));
    errorType = qvariant_cast<StrataServer::ServerError>(errorOccurred.takeFirst().at(0));
    QCOMPARE(errorType, StrataServer::ServerError::FailedToUnregisterHandler);
    errorOccurred.clear();

    {
        StrataServer tempServer(address_, false);
        QSignalSpy tempServerInitialized(&tempServer, &StrataServer::initialized);
        QVERIFY(tempServerInitialized.isValid());
        tempServer.initialize();
        QVERIFY((tempServerInitialized.count() == 1) || (tempServerInitialized.wait(zmqWaitTimeSuccess) == true));

        server.initialize();
        QVERIFY((errorOccurred.count() == 1) || (errorOccurred.wait(zmqWaitTimeSuccess) == true));
        errorType = qvariant_cast<StrataServer::ServerError>(errorOccurred.takeFirst().at(0));
        QCOMPARE(errorType, StrataServer::ServerError::FailedToInitializeServer);
        errorOccurred.clear();
    }

    QSignalSpy serverInitialized(&server, &StrataServer::initialized);
    QVERIFY(serverInitialized.isValid());
    server.initialize();
    QVERIFY((serverInitialized.count() == 1) || (serverInitialized.wait(zmqWaitTimeSuccess) == true));

    server.initialize();

    QVERIFY((errorOccurred.count() == 1) || (errorOccurred.wait(zmqWaitTimeSuccess) == true));
    errorType = qvariant_cast<StrataServer::ServerError>(errorOccurred.takeFirst().at(0));
    QCOMPARE(errorType, StrataServer::ServerError::FailedToInitializeServer);
    errorOccurred.clear();

    QSignalSpy clientConnected(&client, &ClientConnector::connected);
    QVERIFY(clientConnected.isValid());
    QCOMPARE(client.initialize(), true);
    QVERIFY((clientConnected.count() == 1) || (clientConnected.wait(zmqWaitTimeSuccess) == true));

    client.sendMessage(
        R"({"jsonrpc": "2.0","method":"register_client","params": {"api_version": "10.0"},"id":1})");
    QVERIFY((errorOccurred.count() == 1) || (errorOccurred.wait(zmqWaitTimeSuccess) == true));
    errorType = qvariant_cast<StrataServer::ServerError>(errorOccurred.takeFirst().at(0));
    QCOMPARE(errorType, StrataServer::ServerError::FailedToRegisterClient);
    errorOccurred.clear();

    client.sendMessage(R"(not a Json Message)");
    client.sendMessage(R"({"cmd":"this-is-invalid-api})");
    client.sendMessage(R"({"jsonrpc": "5.0","method":"test_method","params": {},"id":1})");
    QVERIFY((errorOccurred.count() >= 1) || (errorOccurred.wait(zmqWaitTimeSuccess) == true));
    QVERIFY((errorOccurred.count() >= 2) || (errorOccurred.wait(zmqWaitTimeSuccess) == true));
    QVERIFY((errorOccurred.count() == 3) || (errorOccurred.wait(zmqWaitTimeSuccess) == true));
    for (const auto &error : errorOccurred) {
        errorType = qvariant_cast<StrataServer::ServerError>(error.at(0));
        QCOMPARE(errorType, StrataServer::ServerError::FailedToBuildClientMessage);
    }
    errorOccurred.clear();

    client.sendMessage(R"({"jsonrpc": "2.0","method":"non_existing_handler","params": {},"id":1})");
    QVERIFY((errorOccurred.count() == 1) || (errorOccurred.wait(zmqWaitTimeSuccess) == true));
    errorType = qvariant_cast<StrataServer::ServerError>(errorOccurred.takeFirst().at(0));
    QCOMPARE(errorType, StrataServer::ServerError::HandlerNotFound);
    errorOccurred.clear();
}
#endif

void StrataServerTest::waitForZmqMessages(int delay)
{
    QTimer timer;
    timer.setSingleShot(true);
    timer.start(delay);
    do {
        QCoreApplication::processEvents(QEventLoop::WaitForMoreEvents);
    } while (timer.isActive());
}
