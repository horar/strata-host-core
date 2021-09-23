/*
 * Copyright (c) 2018-2021 onsemi.
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
    QVERIFY_(validMessage);

    validMessage = false;
    QMetaObject::invokeMethod(
        &server, "messageReceived", Qt::DirectConnection, Q_ARG(QByteArray, "AAA"),
        Q_ARG(
            QByteArray,
            R"({"jsonrpc": "2.0","method":"register_client","params":{"api_version": "1.0"},"id":1})"));
    QVERIFY_(validMessage);

    validMessage = false;
    QMetaObject::invokeMethod(
        &server, "messageReceived", Qt::DirectConnection, Q_ARG(QByteArray, "AAA"),
        Q_ARG(
            QByteArray,
            R"({"jsonrpc": "2.0","method":"register_client","params":{"api_version": "1.0"},"id":1})"));
    QVERIFY_(validMessage);

    validMessage = false;
    QMetaObject::invokeMethod(
        &server, "messageReceived", Qt::DirectConnection, Q_ARG(QByteArray, "AAA"),
        Q_ARG(
            QByteArray,
            R"({"jsonrpc": "2.0","method":"register_client","params":{"api_version": "1.0"},"id":1})"));
    QVERIFY_(validMessage);

    validMessage = false;
    QMetaObject::invokeMethod(&server, "messageReceived", Qt::DirectConnection,
                              Q_ARG(QByteArray, "AAA"),
                              Q_ARG(QByteArray, R"({"cmd":"load_documents","payload":{}})"));
    QVERIFY_(false == validMessage);

    validMessage = false;
    QMetaObject::invokeMethod(&server, "messageReceived", Qt::DirectConnection,
                              Q_ARG(QByteArray, "AAA"), Q_ARG(QByteArray, R"()"));
    QVERIFY_(false == validMessage);

    validMessage = false;
    QMetaObject::invokeMethod(&server, "messageReceived", Qt::DirectConnection,
                              Q_ARG(QByteArray, "AAA"), Q_ARG(QByteArray, R"(0000)"));
    QVERIFY_(false == validMessage);

    validMessage = false;
    QMetaObject::invokeMethod(&server, "messageReceived", Qt::DirectConnection,
                              Q_ARG(QByteArray, "AAA"), Q_ARG(QByteArray, R"(invalid message)"));
    QVERIFY_(false == validMessage);

    validMessage = false;
    QMetaObject::invokeMethod(
        &server, "messageReceived", Qt::DirectConnection, Q_ARG(QByteArray, "AAA"),
        Q_ARG(
            QByteArray,
            R"({"jsonrpc": 2.0,"method":"register_client","params":{"api_version": "1.0"},"id":1})"));
    QVERIFY_(false == validMessage);
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
    QVERIFY_(validMessage);

    validMessage = false;
    QMetaObject::invokeMethod(&server, "messageReceived", Qt::DirectConnection,
                              Q_ARG(QByteArray, "AAA"),
                              Q_ARG(QByteArray, R"({"cmd":"load_documents","payload":{}})"));
    QVERIFY_(validMessage);

    validMessage = false;
    QMetaObject::invokeMethod(&server, "messageReceived", Qt::DirectConnection,
                              Q_ARG(QByteArray, "AAA"),
                              Q_ARG(QByteArray, R"({"sscmd":"load_documents","payload":{}})"));
    QVERIFY_(false == validMessage);

    validMessage = false;
    QMetaObject::invokeMethod(&server, "messageReceived", Qt::DirectConnection,
                              Q_ARG(QByteArray, "AAA"),
                              Q_ARG(QByteArray, R"({"cmd":0,"payload":{}})"));
    QVERIFY_(false == validMessage);

    validMessage = false;
    QMetaObject::invokeMethod(
        &server, "messageReceived", Qt::DirectConnection, Q_ARG(QByteArray, "AAA"),
        Q_ARG(
            QByteArray,
            R"({"jsonrpc": "2.0","method":"register_client","params":{"api_version": "1.0"},"id":1})"));
    QVERIFY_(false == validMessage);

    validMessage = false;
    QMetaObject::invokeMethod(&server, "messageReceived", Qt::DirectConnection,
                              Q_ARG(QByteArray, "AAA"), Q_ARG(QByteArray, R"()"));
    QVERIFY_(false == validMessage);

    validMessage = false;
    QMetaObject::invokeMethod(&server, "messageReceived", Qt::DirectConnection,
                              Q_ARG(QByteArray, "AAA"), Q_ARG(QByteArray, R"(0000)"));
    QVERIFY_(false == validMessage);

    validMessage = false;
    QMetaObject::invokeMethod(&server, "messageReceived", Qt::DirectConnection,
                              Q_ARG(QByteArray, "AAA"), Q_ARG(QByteArray, R"(invalid message)"));
    QVERIFY_(false == validMessage);
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

    QCOMPARE_(counter, testSize);
}

void StrataServerTest::testServerFunctionality()
{
    StrataServer server(address_, false);
    server.initialize();
    waitForZmqMessages(50);

    // add a handler to handler the client message.
    // add a handler to create a response
    server.registerHandler("register_client", [&server](const strata::strataRPC::Message &message) {
        server.notifyClient(message, {{"status", "client registered."}},
                            strata::strataRPC::ResponseType::Response);
    });

    bool clientGotResponse = false;
    strata::strataRPC::ClientConnector client(address_, "AA");
    connect(
        &client, &strata::strataRPC::ClientConnector::messageReceived, this,
        [&clientGotResponse](const QByteArray &message) {
            QCOMPARE_(
                message,
                "{\"id\":1,\"jsonrpc\":\"2.0\",\"result\":{\"status\":\"client registered.\"}}");
            clientGotResponse = true;
        });
    client.initialize();
    client.sendMessage(
        R"({"jsonrpc": "2.0","method":"register_client","params": {"api_version": "1.0"},"id":1})");

    bool clientGotResponse_2 = false;
    strata::strataRPC::ClientConnector client_2(address_, "BB");
    connect(&client_2, &strata::strataRPC::ClientConnector::messageReceived, this,
            [&clientGotResponse_2](const QByteArray &message) {
                QCOMPARE_(message,
                          "{\"hcs::notification\":{\"status\":\"client "
                          "registered.\",\"type\":\"register_client\"}}");
                clientGotResponse_2 = true;
            });
    client_2.initialize();
    waitForZmqMessages(50);
    client_2.sendMessage(R"({"cmd":"register_client", "payload":{}})");

    QTRY_VERIFY_WITH_TIMEOUT(clientGotResponse, 100);
    QTRY_VERIFY_WITH_TIMEOUT(clientGotResponse_2, 100);
}

void StrataServerTest::testBuildNotificationApiV2()
{
    bool testExecuted = false;
    StrataServer server(address_, false);
    server.initialize();
    waitForZmqMessages(50);

    strata::strataRPC::ClientConnector client(address_, "AA");
    client.initialize();
    connect(
        &client, &strata::strataRPC::ClientConnector::messageReceived, this,
        [&testExecuted](const QByteArray &message) {
            // ignore the response to the unregistered handler
            if (message == R"({"error":{"message":"Handler not found."},"id":1,"jsonrpc":"2.0"})") {
                return;
            }

            QJsonParseError jsonParseError;
            QJsonDocument jsonDocument = QJsonDocument::fromJson(message, &jsonParseError);
            QVERIFY_(jsonParseError.error == QJsonParseError::NoError);
            QJsonObject jsonObject = jsonDocument.object();

            QVERIFY_(jsonObject.contains("jsonrpc"));
            QVERIFY_(jsonObject.value("jsonrpc").isString());

            QVERIFY_(jsonObject.contains("method"));
            QVERIFY_(jsonObject.value("method").isString());

            QVERIFY_(jsonObject.contains("params"));
            QVERIFY_(jsonObject.value("params").isObject());
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
    QTRY_VERIFY_WITH_TIMEOUT(testExecuted, 100);
}

void StrataServerTest::testBuildResponseApiV2()
{
    bool testExecuted = false;
    StrataServer server(address_, false);
    server.initialize();
    waitForZmqMessages(50);

    strata::strataRPC::ClientConnector client(address_, "AA");
    client.initialize();
    waitForZmqMessages(50);

    connect(
        &client, &strata::strataRPC::ClientConnector::messageReceived, this,
        [&testExecuted](const QByteArray &message) {
            // ignore the response to the unregistered handler
            if (message == R"({"error":{"message":"Handler not found."},"id":1,"jsonrpc":"2.0"})") {
                return;
            }

            QJsonParseError jsonParseError;
            QJsonDocument jsonDocument = QJsonDocument::fromJson(message, &jsonParseError);
            QVERIFY_(jsonParseError.error == QJsonParseError::NoError);
            QJsonObject jsonObject = jsonDocument.object();

            QVERIFY_(jsonObject.contains("jsonrpc"));
            QVERIFY_(jsonObject.value("jsonrpc").isString());

            QVERIFY_(jsonObject.contains("id"));
            QVERIFY_(jsonObject.value("id").isDouble());

            QVERIFY_(jsonObject.contains("result"));
            QVERIFY_(jsonObject.value("result").isObject());
            testExecuted = true;
        });

    client.sendMessage(
        R"({"jsonrpc": "2.0","method":"register_client","params": {"api_version": "1.0"},"id":1})");

    server.registerHandler("test_response", [&server](const strata::strataRPC::Message &message) {
        server.notifyClient(message, {{"key", "value"}, {"test", "test"}},
                            strata::strataRPC::ResponseType::Response);
    });

    client.sendMessage(R"({"jsonrpc": "2.0","method":"test_response","params":{},"id":1})");
    QTRY_VERIFY_WITH_TIMEOUT(testExecuted, 100);
}

void StrataServerTest::testBuildErrorApiV2()
{
    bool testExecuted = false;
    StrataServer server(address_, false);
    server.initialize();
    waitForZmqMessages(50);

    strata::strataRPC::ClientConnector client(address_, "AA");
    client.initialize();
    waitForZmqMessages(50);

    connect(&client, &strata::strataRPC::ClientConnector::messageReceived, this,
            [&testExecuted](const QByteArray &message) {
                QJsonParseError jsonParseError;
                QJsonDocument jsonDocument = QJsonDocument::fromJson(message, &jsonParseError);
                QVERIFY_(jsonParseError.error == QJsonParseError::NoError);
                QJsonObject jsonObject = jsonDocument.object();

                QVERIFY_(jsonObject.contains("jsonrpc"));
                QVERIFY_(jsonObject.value("jsonrpc").isString());

                QVERIFY_(jsonObject.contains("id"));
                QVERIFY_(jsonObject.value("id").isDouble());

                QVERIFY_(jsonObject.contains("error"));
                QVERIFY_(jsonObject.value("error").isObject());
                testExecuted = true;
            });

    client.sendMessage(
        R"({"jsonrpc": "2.0","method":"register_client","params": {"api_version": "1.0"},"id":1})");

    server.registerHandler("test_error", [&server](const strata::strataRPC::Message &message) {
        server.notifyClient(message, {{"key", "value"}, {"test", "test"}},
                            strata::strataRPC::ResponseType::Error);
    });

    client.sendMessage(R"({"jsonrpc": "2.0","method":"test_error","params":{},"id":3})");
    QTRY_VERIFY_WITH_TIMEOUT(testExecuted, 1000);
}

void StrataServerTest::testBuildPlatformMessageApiV2()
{
    bool testExecuted = false;
    StrataServer server(address_, false);
    server.initialize();
    waitForZmqMessages(50);

    strata::strataRPC::ClientConnector client(address_, "AA");
    client.initialize();
    waitForZmqMessages(50);

    connect(
        &client, &strata::strataRPC::ClientConnector::messageReceived, this,
        [&testExecuted](const QByteArray &message) {
            // ignore the response to the unregistered handler
            if (message == R"({"error":{"message":"Handler not found."},"id":1,"jsonrpc":"2.0"})") {
                return;
            }

            QJsonParseError jsonParseError;
            QJsonDocument jsonDocument = QJsonDocument::fromJson(message, &jsonParseError);
            QVERIFY_(jsonParseError.error == QJsonParseError::NoError);
            QJsonObject jsonObject = jsonDocument.object();

            QVERIFY_(jsonObject.contains("jsonrpc"));
            QVERIFY_(jsonObject.value("jsonrpc").isString());

            QVERIFY_(jsonObject.contains("method"));
            QVERIFY_(jsonObject.value("method").isString());
            QVERIFY_(jsonObject.value("method") == "platform_notification");

            QVERIFY_(jsonObject.contains("params"));
            QVERIFY_(jsonObject.value("params").isObject());
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
    QTRY_VERIFY_WITH_TIMEOUT(testExecuted, 100);
}

void StrataServerTest::testBuildNotificationApiV1()
{
    bool testExecuted = false;
    StrataServer server(address_, false);
    server.initialize();
    waitForZmqMessages(50);

    strata::strataRPC::ClientConnector client(address_, "AA");
    client.initialize();
    waitForZmqMessages(50);

    connect(&client, &strata::strataRPC::ClientConnector::messageReceived, this,
            [&testExecuted](const QByteArray &message) {
                QJsonParseError jsonParseError;
                QJsonDocument jsonDocument = QJsonDocument::fromJson(message, &jsonParseError);
                QVERIFY_(jsonParseError.error == QJsonParseError::NoError);
                QJsonObject jsonObject = jsonDocument.object();

                QVERIFY_(jsonObject.contains("hcs::notification"));
                QVERIFY_(jsonObject.value("hcs::notification").isObject());
                QVERIFY_(jsonObject.value("hcs::notification").toObject().contains("type"));
                testExecuted = true;
            });

    client.sendMessage(R"({"cmd":"register_client", "payload":{}})");

    server.registerHandler("test_notification",
                           [&server](const strata::strataRPC::Message &message) {
                               server.notifyClient(message, {{"key", "value"}, {"test", "test"}},
                                                   strata::strataRPC::ResponseType::Notification);
                           });

    client.sendMessage(R"({"hcs::cmd":"test_notification","payload":{}})");

    QTRY_VERIFY_WITH_TIMEOUT(testExecuted, 100);
}

void StrataServerTest::testBuildResponseApiV1()
{
    bool testExecuted = false;
    StrataServer server(address_, false);
    server.initialize();
    waitForZmqMessages(50);

    strata::strataRPC::ClientConnector client(address_, "AA");
    client.initialize();
    connect(&client, &strata::strataRPC::ClientConnector::messageReceived, this,
            [&testExecuted](const QByteArray &message) {
                QJsonParseError jsonParseError;
                QJsonDocument jsonDocument = QJsonDocument::fromJson(message, &jsonParseError);
                QVERIFY_(jsonParseError.error == QJsonParseError::NoError);
                QJsonObject jsonObject = jsonDocument.object();

                QVERIFY_(jsonObject.contains("hcs::notification"));
                QVERIFY_(jsonObject.value("hcs::notification").isObject());
                QVERIFY_(jsonObject.value("hcs::notification").toObject().contains("type"));
                testExecuted = true;
            });

    client.sendMessage(R"({"cmd":"register_client", "payload":{}})");

    server.registerHandler("test_response", [&server](const strata::strataRPC::Message &message) {
        server.notifyClient(message, {{"key", "value"}, {"test", "test"}},
                            strata::strataRPC::ResponseType::Response);
    });

    client.sendMessage(R"({"hcs::cmd":"test_response","payload":{}})");
    QTRY_VERIFY_WITH_TIMEOUT(testExecuted, 100);
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
        QCOMPARE_(platformCommand.value("cmd").toString(), currentCommandName);
        handlerCalled = true;
    });

    server.initialize();
    waitForZmqMessages(50);

    handlerCalled = false;
    currentCommandName = "test_1";
    QMetaObject::invokeMethod(
        &server, "messageReceived", Qt::DirectConnection, Q_ARG(QByteArray, "AA"),
        Q_ARG(QByteArray, R"({"cmd":"test_1","payload":{"enable":"off"},"device_id":"949921126"})"));
    QVERIFY_(handlerCalled);

    handlerCalled = false;
    currentCommandName = "test_2";
    QMetaObject::invokeMethod(
        &server, "messageReceived", Qt::DirectConnection, Q_ARG(QByteArray, "AA"),
        Q_ARG(QByteArray, R"({"cmd":"test_2","payload":"enable","device_id":"949921126"})"));
    QVERIFY_(handlerCalled);

    handlerCalled = false;
    currentCommandName = "test_3";
    QMetaObject::invokeMethod(&server, "messageReceived", Qt::DirectConnection,
                              Q_ARG(QByteArray, "AA"),
                              Q_ARG(QByteArray, R"({"cmd":"test_3","device_id":"949921126"})"));
    QVERIFY_(handlerCalled);

    handlerCalled = false;
    currentCommandName = "test_4";
    QMetaObject::invokeMethod(&server, "messageReceived", Qt::DirectConnection,
                              Q_ARG(QByteArray, "AA"), Q_ARG(QByteArray, R"({"cmd":"test_4"})"));
    QVERIFY_(false == handlerCalled);
}

void StrataServerTest::testBuildPlatformMessageApiV1()
{
    bool testExecuted = false;
    StrataServer server(address_, false);
    server.initialize();
    waitForZmqMessages(50);

    strata::strataRPC::ClientConnector client(address_, "AA");
    client.initialize();
    waitForZmqMessages(50);

    connect(&client, &strata::strataRPC::ClientConnector::messageReceived, this,
            [&testExecuted](const QByteArray &message) {
                QJsonParseError jsonParseError;
                QJsonDocument jsonDocument = QJsonDocument::fromJson(message, &jsonParseError);
                QVERIFY_(jsonParseError.error == QJsonParseError::NoError);
                QJsonObject jsonObject = jsonDocument.object();

                if (jsonObject.contains("error")) {
                    // skip error messages
                    return;
                }

                QVERIFY_(jsonObject.contains("notification"));
                QVERIFY_(jsonObject.value("notification").isObject());
                testExecuted = true;
            });

    client.sendMessage(R"({"cmd":"register_client", "payload":{}})");

    server.registerHandler(
        "platform_notification", [&server](const strata::strataRPC::Message &message) {
            server.notifyClient(message, {{"key", "value"}, {"test", "test"}},
                                strata::strataRPC::ResponseType::PlatformMessage);
        });

    client.sendMessage(R"({"hcs::cmd":"platform_notification","payload":{}})");
    QTRY_VERIFY_WITH_TIMEOUT(testExecuted, 100);
}

void StrataServerTest::testNotifyAllClients()
{
    QTimer timer;
    StrataServer server(address_, false);
    std::vector<strata::strataRPC::ClientConnector *> clientsList;
    int counter = 0;
    int clientsCount = 10;

    server.initialize();
    waitForZmqMessages(50);

    // half the clients use API v2
    for (int i = 0; i < clientsCount / 2; i++) {
        clientsList.push_back(
            new strata::strataRPC::ClientConnector(address_, QByteArray::number(i)));
        clientsList.back()->initialize();
        connect(clientsList.back(), &strata::strataRPC::ClientConnector::messageReceived, this,
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

                    QVERIFY_(jsonObject.contains("jsonrpc"));
                    QVERIFY_(jsonObject.contains("method"));
                    QVERIFY_(jsonObject.contains("params"));
                    QVERIFY_(jsonObject.value("params").isObject());

                    QCOMPARE_(jsonObject.value("jsonrpc").toString(), "2.0");
                    QCOMPARE_(jsonObject.value("method").toString(), "test_broadcast");

                    QJsonObject tempExpectedPayload{{"test", "test"}};
                    QCOMPARE_(jsonObject.value("params").toObject(), tempExpectedPayload);
                    counter++;
                });
        clientsList[i]->sendMessage(
            R"({"jsonrpc": "2.0","method":"register_client","params": {"api_version": "1.0"},"id":1})");
    }

    // other half uses API v1
    for (int i = clientsCount / 2; i < clientsCount; i++) {
        clientsList.push_back(
            new strata::strataRPC::ClientConnector(address_, QByteArray::number(i)));
        clientsList.back()->initialize();
        connect(clientsList.back(), &strata::strataRPC::ClientConnector::messageReceived, this,
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

                    QVERIFY_(jsonObject.contains("hcs::notification"));
                    QVERIFY_(jsonObject.value("hcs::notification").isObject());

                    QJsonObject payloadJsonObject =
                        jsonObject.value("hcs::notification").toObject();

                    QVERIFY_(payloadJsonObject.contains("type"));
                    QVERIFY_(payloadJsonObject.contains("test"));

                    QCOMPARE_(payloadJsonObject.value("type").toString(), "test_broadcast");
                    QCOMPARE_(payloadJsonObject.value("test").toString(), "test");

                    counter++;
                });
        clientsList[i]->sendMessage(R"({"cmd":"register_client", "payload":{}})");
    }

    waitForZmqMessages();

    server.notifyAllClients("test_broadcast", {{"test", "test"}});

    // wait for the messages
    timer.setSingleShot(true);
    timer.start(200);
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
    server.initialize();
    waitForZmqMessages(50);

    strata::strataRPC::ClientConnector client(address_, "AA");
    client.initialize();
    waitForZmqMessages(50);

    client.sendMessage(
        R"({"jsonrpc": "2.0","method":"register_client","params": {"api_version": "1.0"},"id":1})");
    waitForZmqMessages(50);

    connect(&client, &strata::strataRPC::ClientConnector::messageReceived, this,
            [&testExecuted](const QByteArray &message) {
                QJsonParseError jsonParseError;
                QJsonDocument jsonDocument = QJsonDocument::fromJson(message, &jsonParseError);

                QVERIFY_(jsonParseError.error == QJsonParseError::NoError);

                QJsonObject jsonObject = jsonDocument.object();

                QVERIFY_(jsonObject.contains("method"));
                QVERIFY_(jsonObject.value("method").isString());
                QCOMPARE_(jsonObject.value("method").toString(), "test_handler");
                testExecuted = true;
            });

    server.notifyClient("AA", "test_handler", QJsonObject({{"key", "value"}}),
                        strata::strataRPC::ResponseType::Notification);

    QTRY_VERIFY_WITH_TIMEOUT(testExecuted, 100);
}

void StrataServerTest::testNotifyClientToNonExistingClient()
{
    StrataServer server(address_, false);
    server.initialize();
    waitForZmqMessages(50);

    strata::strataRPC::ClientConnector client(address_, "AA");
    connect(
        &client, &strata::strataRPC::ClientConnector::messageReceived, this,
        [](const QByteArray &) { QFAIL_("Messages should not be sent to unregistered Clients."); });

    server.notifyClient("AA", "test_handler", QJsonObject({{"key", "value"}}),
                        strata::strataRPC::ResponseType::Notification);
    waitForZmqMessages();
}

void StrataServerTest::testInitializeServerFail()
{
    StrataServer server(address_, false);
    StrataServer duplicateServer(address_);

    server.initialize();
    waitForZmqMessages(50);

    QSignalSpy errorOccurred(&duplicateServer, &StrataServer::errorOccurred);
    duplicateServer.initialize();
    QTRY_COMPARE_WITH_TIMEOUT(errorOccurred.count(), 1, 100);
    auto errorType = qvariant_cast<StrataServer::ServerError>(errorOccurred.takeFirst().at(0));
    QCOMPARE_(errorType, StrataServer::ServerError::FailedToInitializeServer);
}

void StrataServerTest::testdefaultHandlers()
{
    StrataServer server(address_, true);
    server.initialize();

    waitForZmqMessages(50);

    bool testExecuted_1 = false;
    bool testExecuted_2 = false;

    strata::strataRPC::ClientConnector client(address_, "AA");
    client.initialize();
    client.connect();
    client.sendMessage(
        R"({"jsonrpc": "2.0","method":"register_client","params": {"api_version": "2.0"},"id":1})");
    connect(&client, &strata::strataRPC::ClientConnector::messageReceived, this,
            [&testExecuted_1](const QByteArray &message) {
                QJsonParseError jsonParseError;
                QJsonDocument jsonDocument = QJsonDocument::fromJson(message, &jsonParseError);

                QVERIFY_(jsonParseError.error == QJsonParseError::NoError);

                QJsonObject jsonObject = jsonDocument.object();

                QVERIFY_(jsonObject.contains("result"));
                QVERIFY_(jsonObject.value("result").isObject());
                QCOMPARE_(jsonObject.value("result").toObject(),
                          QJsonObject({{"status", "client registered."}}));
                testExecuted_1 = true;
            });

    waitForZmqMessages();

    strata::strataRPC::ClientConnector client_2(address_, "BB");
    client_2.initialize();
    client_2.connect();
    client_2.sendMessage(
        R"({"jsonrpc": "2.0","method":"register_client","params": {"api_version": "1.0"},"id":1})");
    connect(&client_2, &strata::strataRPC::ClientConnector::messageReceived, this,
            [&testExecuted_2](const QByteArray &message) {
                QJsonParseError jsonParseError;
                QJsonDocument jsonDocument = QJsonDocument::fromJson(message, &jsonParseError);

                QVERIFY_(jsonParseError.error == QJsonParseError::NoError);

                QJsonObject jsonObject = jsonDocument.object();

                QVERIFY_(jsonObject.contains("error"));
                QVERIFY_(jsonObject.value("error").isObject());
                QCOMPARE_(
                    jsonObject.value("error").toObject(),
                    QJsonObject({{"message", "Failed to register client, Unknown API Version."}}));
                testExecuted_2 = true;
            });

    QTRY_VERIFY_WITH_TIMEOUT(testExecuted_1, 100);
    QTRY_VERIFY_WITH_TIMEOUT(testExecuted_2, 100);
}

void StrataServerTest::testErrorOccourredSignal()
{
    qRegisterMetaType<StrataServer::ServerError>("StrataServer::ServerError");

    StrataServer server(address_, true, this);
    strata::strataRPC::ClientConnector client(address_, "AA");
    StrataServer::ServerError errorType;
    QSignalSpy errorOccurred(&server, &StrataServer::errorOccurred);

    server.registerHandler("handler_1", [](const strata::strataRPC::Message &) { return; });
    server.registerHandler("handler_1", [](const strata::strataRPC::Message &) { return; });
    QCOMPARE_(errorOccurred.count(), 1);
    errorType = qvariant_cast<StrataServer::ServerError>(errorOccurred.takeFirst().at(0));
    QCOMPARE_(errorType, StrataServer::ServerError::FailedToRegisterHandler);
    errorOccurred.clear();

    server.unregisterHandler("handler_2");
    QCOMPARE_(errorOccurred.count(), 1);
    errorType = qvariant_cast<StrataServer::ServerError>(errorOccurred.takeFirst().at(0));
    QCOMPARE_(errorType, StrataServer::ServerError::FailedToUnregisterHandler);
    errorOccurred.clear();

    {
        StrataServer tempServer(address_, false);
        tempServer.initialize();
        waitForZmqMessages(50);

        server.initialize();
        QTRY_COMPARE_WITH_TIMEOUT(errorOccurred.count(), 1, 100);
        errorType = qvariant_cast<StrataServer::ServerError>(errorOccurred.takeFirst().at(0));
        QCOMPARE_(errorType, StrataServer::ServerError::FailedToInitializeServer);
        errorOccurred.clear();
    }

    server.initialize();
    waitForZmqMessages(50);
    server.initialize();

    QTRY_COMPARE_WITH_TIMEOUT(errorOccurred.count(), 1, 100);
    errorType = qvariant_cast<StrataServer::ServerError>(errorOccurred.takeFirst().at(0));
    QCOMPARE_(errorType, StrataServer::ServerError::FailedToInitializeServer);
    errorOccurred.clear();

    client.initialize();
    client.sendMessage(
        R"({"jsonrpc": "2.0","method":"register_client","params": {"api_version": "10.0"},"id":1})");
    QTRY_COMPARE_WITH_TIMEOUT(errorOccurred.count(), 1, 100);
    errorType = qvariant_cast<StrataServer::ServerError>(errorOccurred.takeFirst().at(0));
    QCOMPARE_(errorType, StrataServer::ServerError::FailedToRegisterClient);
    errorOccurred.clear();

    client.sendMessage(R"(not a Json Message)");
    client.sendMessage(R"({"cmd":"this-is-invalid-api})");
    client.sendMessage(R"({"jsonrpc": "5.0","method":"test_method","params": {},"id":1})");
    QTRY_COMPARE_WITH_TIMEOUT(errorOccurred.count(), 3, 100);
    for (const auto &error : errorOccurred) {
        errorType = qvariant_cast<StrataServer::ServerError>(error.at(0));
        QCOMPARE_(errorType, StrataServer::ServerError::FailedToBuildClientMessage);
    }
    errorOccurred.clear();

    client.sendMessage(R"({"jsonrpc": "2.0","method":"non_existing_handler","params": {},"id":1})");
    waitForZmqMessages();
    QTRY_COMPARE_WITH_TIMEOUT(errorOccurred.count(), 1, 100);
    errorType = qvariant_cast<StrataServer::ServerError>(errorOccurred.takeFirst().at(0));
    QCOMPARE_(errorType, StrataServer::ServerError::HandlerNotFound);
    errorOccurred.clear();
}

void StrataServerTest::waitForZmqMessages(int delay)
{
    QTimer timer;
    timer.setSingleShot(true);
    timer.start(delay);
    do {
        QCoreApplication::processEvents(QEventLoop::WaitForMoreEvents);
    } while (timer.isActive());
}
