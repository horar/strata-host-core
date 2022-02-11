/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "StrataClientTest.h"
#include "ServerConnector.h"

#include <QSignalSpy>

QTEST_MAIN(StrataClientTest)

using strata::strataRPC::ServerConnector;

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
    QVERIFY(client.registerHandler("handler_1", [](const QJsonObject &) { return; }));
    QVERIFY(client.registerHandler("handler_2", [](const QJsonObject &) { return; }));
    QVERIFY(false == client.registerHandler("handler_2", [](const QJsonObject &) { return; }));

    QVERIFY(client.unregisterHandler("handler_1"));
    QVERIFY(client.unregisterHandler("handler_2"));
    QVERIFY(false == client.unregisterHandler("handler_2"));
    QVERIFY(false == client.unregisterHandler("not_registered_handler"));
}

void StrataClientTest::testConnectDisconnectToTheServer()
{
    // serverConnector set up
    ServerConnector server(address_);
    QSignalSpy serverMessageReceived(&server, &ServerConnector::messageReceived);
    QVERIFY(serverMessageReceived.isValid());
    connect(
        &server, &ServerConnector::messageReceived, this,
        [&server](const QByteArray &clientId, const QByteArray &message) {
            qDebug() << "ServerConnector new message handler. client id:" << clientId << "message"
                     << message;
            server.sendMessage(clientId, message);
        });
    server.initialize();

    // StrataClient set up
    StrataClient client(address_);
    QSignalSpy clientMessageParsed(&client, &StrataClient::messageParsed);
    QSignalSpy clientConnected(&client, &StrataClient::connected);
    QVERIFY(serverMessageReceived.isValid());
    QVERIFY(clientConnected.isValid());

    client.connect();
    QVERIFY((serverMessageReceived.count() == 1) || (serverMessageReceived.wait(250) == true));
    QVERIFY((clientConnected.count() == 1) || (clientConnected.wait(250) == true));
    clientConnected.clear();

    serverMessageReceived.clear();
    clientMessageParsed.clear();
    client.disconnect();
    QVERIFY((serverMessageReceived.count() == 1) || (serverMessageReceived.wait(250) == true));
    QVERIFY((clientMessageParsed.count() == 0) && (serverMessageReceived.wait(100) == false));

    serverMessageReceived.clear();
    clientMessageParsed.clear();
    server.sendMessage("StrataClient", "test message");
    QVERIFY((serverMessageReceived.count() == 0) && (serverMessageReceived.wait(100) == false));
    QVERIFY((clientMessageParsed.count() == 0) && (serverMessageReceived.wait(100) == false));

    serverMessageReceived.clear();
    clientConnected.clear();
    client.connect();
    QVERIFY((serverMessageReceived.count() == 1) || (serverMessageReceived.wait(250) == true));
    QVERIFY((clientConnected.count() == 1) || (clientConnected.wait(250) == true));
}

void StrataClientTest::testBuildRequest()
{
    // some variables used for validation.
    bool serverRevicedMessage = false;
    QString expectedMethod = "";
    int expectedId = 0;

    ServerConnector server(address_);
    QSignalSpy messageReceived(&server, &ServerConnector::messageReceived);
    QVERIFY(messageReceived.isValid());
    connect(&server, &ServerConnector::messageReceived, this,
            [&expectedId, &expectedMethod, &serverRevicedMessage](const QByteArray &,
                                                                  const QByteArray &message) {
                QJsonObject jsonObject(QJsonDocument::fromJson(message).object());

                QVERIFY(jsonObject.contains("jsonrpc"));
                QVERIFY(jsonObject.value("jsonrpc").isString());

                QVERIFY(jsonObject.contains("id"));
                QVERIFY(jsonObject.value("id").isDouble());
                QCOMPARE(jsonObject.value("id").toDouble(), expectedId);

                QVERIFY(jsonObject.contains("method"));
                QVERIFY(jsonObject.value("method").isString());
                QCOMPARE(jsonObject.value("method").toString(), expectedMethod);

                QVERIFY(jsonObject.contains("params"));
                QVERIFY(jsonObject.value("params").isObject());

                serverRevicedMessage = true;
            });
    server.initialize();

    StrataClient client(address_);

    expectedMethod = "register_client";
    expectedId = 1;
    serverRevicedMessage = false;
    client.connect();
    QVERIFY((messageReceived.count() == 1) || (messageReceived.wait(250) == true));
    QVERIFY(serverRevicedMessage);

    expectedMethod = "method_1";
    expectedId = 2;
    serverRevicedMessage = false;
    {
        messageReceived.clear();
        auto deferredRequest = client.sendRequest("method_1", {{"param_1", 0}});
        QVERIFY(deferredRequest != nullptr);
        QVERIFY((messageReceived.count() == 1) || (messageReceived.wait(250) == true));
        QVERIFY(serverRevicedMessage);
    }

    expectedMethod = "method_2";
    expectedId = 3;
    serverRevicedMessage = false;
    {
        messageReceived.clear();
        auto deferredRequest = client.sendRequest("method_2", {});
        QVERIFY(deferredRequest != nullptr);
        QVERIFY((messageReceived.count() == 1) || (messageReceived.wait(250) == true));
        QVERIFY(serverRevicedMessage);
    }
}

void StrataClientTest::testNonDefaultDealerId()
{
    bool defaultIdRecieved = false;
    bool customIdRecieved = false;

    ServerConnector server(address_);
    QSignalSpy messageReceived(&server, &ServerConnector::messageReceived);
    QVERIFY(messageReceived.isValid());
    connect(
        &server, &ServerConnector::messageReceived, this,
        [&defaultIdRecieved, &customIdRecieved](const QByteArray &clientId, const QByteArray &) {
            if (clientId == "customId") {
                customIdRecieved = true;
            } else if (clientId == "StrataClient") {
                defaultIdRecieved = true;
            }
        });

    server.initialize();

    StrataClient client_1(address_);
    client_1.connect();

    StrataClient client_2(address_, "customId");
    client_2.connect();

    QVERIFY((messageReceived.count() >= 1) || (messageReceived.wait(250) == true));
    QVERIFY((messageReceived.count() >= 2) || (messageReceived.wait(250) == true));

    QVERIFY(defaultIdRecieved);
    QVERIFY(customIdRecieved);
}

void StrataClientTest::testWithNoCallbacks()
{
    int zmqWaitTime = 100;
    bool noCallbackHandler = false;

    ServerConnector server(address_);
    server.initialize();

    connect(
        &server, &ServerConnector::messageReceived, this,
        [&server](const QByteArray &clientId, const QByteArray &jsonMessage) {
            QJsonObject jsonObject(QJsonDocument::fromJson(jsonMessage).object());
            QString handlerName = jsonObject.value("method").toString();
            double id = jsonObject.value("id").toDouble();
            QByteArray response = "";
            QString responseType =
                jsonObject.value("params").toObject().value("response_type").toString();

            if (responseType == "notification") {
                response =
                    QJsonDocument(
                        QJsonObject({{"jsonrpc", "2.0"}, {"method", handlerName}, {"params", {}}}))
                        .toJson(QJsonDocument::JsonFormat::Compact);
            } else if (responseType == "error") {
                response = QJsonDocument(QJsonObject({{"jsonrpc", "2.0"},
                                                      {"method", handlerName},
                                                      {"error", QJsonObject()},
                                                      {"id", id}}))
                               .toJson(QJsonDocument::JsonFormat::Compact);
            } else if (responseType == "result") {
                response = QJsonDocument(QJsonObject({{"jsonrpc", "2.0"},
                                                      {"method", handlerName},
                                                      {"result", QJsonObject()},
                                                      {"id", id}}))
                               .toJson(QJsonDocument::JsonFormat::Compact);
            } else {
                return;
            }

            server.sendMessage(clientId, response);
        });

    StrataClient client(address_);

    client.registerHandler("test_no_callbacks",
                           [&noCallbackHandler](const QJsonObject &) { noCallbackHandler = true; });

    client.connect();
    waitForZmqMessages(zmqWaitTime);

    noCallbackHandler = false;
    client.sendRequest("test_no_callbacks", QJsonObject({{"response_type", "notification"}}));
    QTRY_VERIFY_WITH_TIMEOUT(noCallbackHandler, zmqWaitTime);

    noCallbackHandler = false;
    client.sendRequest("test_no_callbacks", QJsonObject({{"response_type", "error"}}));
    waitForZmqMessages(zmqWaitTime);
    QVERIFY(false == noCallbackHandler);

    noCallbackHandler = false;
    client.sendRequest("test_no_callbacks", QJsonObject({{"response_type", "result"}}));
    waitForZmqMessages(zmqWaitTime);
    QVERIFY(false == noCallbackHandler);
}

void StrataClientTest::testWithAllCallbacks()
{
    using DeferredRequest = strata::strataRPC::DeferredRequest;

    int zmqWaitTime = 100;
    bool allCallbacksHandler = false;

    ServerConnector server(address_);
    server.initialize();

    connect(
        &server, &ServerConnector::messageReceived, this,
        [&server](const QByteArray &clientId, const QByteArray &jsonMessage) {
            QJsonObject jsonObject(QJsonDocument::fromJson(jsonMessage).object());
            QString handlerName = jsonObject.value("method").toString();
            double id = jsonObject.value("id").toDouble();
            QByteArray response = "";
            QString responseType =
                jsonObject.value("params").toObject().value("response_type").toString();

            if (responseType == "notification") {
                response =
                    QJsonDocument(
                        QJsonObject({{"jsonrpc", "2.0"}, {"method", handlerName}, {"params", {}}}))
                        .toJson(QJsonDocument::JsonFormat::Compact);
            } else if (responseType == "error") {
                response = QJsonDocument(QJsonObject({{"jsonrpc", "2.0"},
                                                      {"method", handlerName},
                                                      {"error", QJsonObject()},
                                                      {"id", id}}))
                               .toJson(QJsonDocument::JsonFormat::Compact);
            } else if (responseType == "result") {
                response = QJsonDocument(QJsonObject({{"jsonrpc", "2.0"},
                                                      {"method", handlerName},
                                                      {"result", QJsonObject()},
                                                      {"id", id}}))
                               .toJson(QJsonDocument::JsonFormat::Compact);
            } else {
                return;
            }

            server.sendMessage(clientId, response);
        });

    StrataClient client(address_);

    connect(&client, &StrataClient::errorOccurred, this,
            [](const StrataClient::ClientError &errorType, const QString &) {
                if (StrataClient::ClientError::RequestTimeout == errorType) {
                    QFAIL_("Request timed out.");
                }
            });

    client.registerHandler("test_all_callbacks", [&allCallbacksHandler](const QJsonObject &) {
        allCallbacksHandler = true;
    });

    client.connect();
    waitForZmqMessages(zmqWaitTime);

    {
        allCallbacksHandler = false;
        auto deferredRequest =
            client.sendRequest("test_all_callbacks", QJsonObject({{"response_type", "error"}}));

        QVERIFY(deferredRequest != nullptr);
        QSignalSpy finishedSuccessfully(deferredRequest, &DeferredRequest::finishedSuccessfully);
        QSignalSpy finishedWithError(deferredRequest, &DeferredRequest::finishedWithError);
        QVERIFY(finishedSuccessfully.isValid());
        QVERIFY(finishedWithError.isValid());

        QVERIFY((finishedWithError.count() == 1) || (finishedWithError.wait(250) == true));
        QVERIFY((finishedSuccessfully.count() == 0) && (finishedSuccessfully.wait(100) == false));
        QVERIFY(false == allCallbacksHandler);
    }

    {
        allCallbacksHandler = false;
        auto deferredRequest =
            client.sendRequest("test_all_callbacks", QJsonObject({{"response_type", "result"}}));

        QVERIFY(deferredRequest != nullptr);
        QSignalSpy finishedSuccessfully(deferredRequest, &DeferredRequest::finishedSuccessfully);
        QSignalSpy finishedWithError(deferredRequest, &DeferredRequest::finishedWithError);
        QVERIFY(finishedSuccessfully.isValid());
        QVERIFY(finishedWithError.isValid());

        QVERIFY((finishedSuccessfully.count() == 1) || (finishedSuccessfully.wait(250) == true));
        QVERIFY((finishedWithError.count() == 0) && (finishedWithError.wait(100) == false));
        QVERIFY(false == allCallbacksHandler);
    }

    {
        allCallbacksHandler = false;

        auto deferredRequest = client.sendRequest("test_all_callbacks",
                                                  QJsonObject({{"response_type", "notification"}}));

        QVERIFY(deferredRequest != nullptr);
        QSignalSpy finishedSuccessfully(deferredRequest, &DeferredRequest::finishedSuccessfully);
        QSignalSpy finishedWithError(deferredRequest, &DeferredRequest::finishedWithError);
        QVERIFY(finishedSuccessfully.isValid());
        QVERIFY(finishedWithError.isValid());

        QVERIFY((finishedSuccessfully.count() == 0) && (finishedSuccessfully.wait(100) == false));
        QVERIFY((finishedWithError.count() == 0) && (finishedWithError.wait(100) == false));
        QTRY_VERIFY_WITH_TIMEOUT(allCallbacksHandler, zmqWaitTime);
    }
}

void StrataClientTest::testWithOnlyResultCallbacks()
{
    using DeferredRequest = strata::strataRPC::DeferredRequest;

    int zmqWaitTime = 100;
    bool resCallbackHandler = false;

    ServerConnector server(address_);
    server.initialize();

    connect(
        &server, &ServerConnector::messageReceived, this,
        [&server](const QByteArray &clientId, const QByteArray &jsonMessage) {
            QJsonObject jsonObject(QJsonDocument::fromJson(jsonMessage).object());
            QString handlerName = jsonObject.value("method").toString();
            double id = jsonObject.value("id").toDouble();
            QByteArray response = "";
            QString responseType =
                jsonObject.value("params").toObject().value("response_type").toString();

            if (responseType == "notification") {
                response =
                    QJsonDocument(
                        QJsonObject({{"jsonrpc", "2.0"}, {"method", handlerName}, {"params", {}}}))
                        .toJson(QJsonDocument::JsonFormat::Compact);
            } else if (responseType == "error") {
                response = QJsonDocument(QJsonObject({{"jsonrpc", "2.0"},
                                                      {"method", handlerName},
                                                      {"error", QJsonObject()},
                                                      {"id", id}}))
                               .toJson(QJsonDocument::JsonFormat::Compact);
            } else if (responseType == "result") {
                response = QJsonDocument(QJsonObject({{"jsonrpc", "2.0"},
                                                      {"method", handlerName},
                                                      {"result", QJsonObject()},
                                                      {"id", id}}))
                               .toJson(QJsonDocument::JsonFormat::Compact);
            } else {
                return;
            }

            server.sendMessage(clientId, response);
        });

    StrataClient client(address_);

    connect(&client, &StrataClient::errorOccurred, this,
            [](const StrataClient::ClientError &errorType, const QString &) {
                if (StrataClient::ClientError::RequestTimeout == errorType) {
                    QFAIL_("Request timed out.");
                }
            });

    client.registerHandler("test_res_callback", [&resCallbackHandler](const QJsonObject &) {
        resCallbackHandler = true;
    });

    client.connect();
    waitForZmqMessages(zmqWaitTime);

    {
        resCallbackHandler = false;
        auto deferredRequest =
            client.sendRequest("test_res_callback", QJsonObject({{"response_type", "result"}}));

        QVERIFY(deferredRequest != nullptr);
        QSignalSpy finishedSuccessfully(deferredRequest, &DeferredRequest::finishedSuccessfully);
        QVERIFY(finishedSuccessfully.isValid());

        QVERIFY((finishedSuccessfully.count() == 1) || (finishedSuccessfully.wait(250) == true));
        QVERIFY(false == resCallbackHandler);
    }

    {
        resCallbackHandler = false;
        auto deferredRequest =
            client.sendRequest("test_res_callback", QJsonObject({{"response_type", "error"}}));

        QVERIFY(deferredRequest != nullptr);
        QSignalSpy finishedSuccessfully(deferredRequest, &DeferredRequest::finishedSuccessfully);
        QVERIFY(finishedSuccessfully.isValid());

        QVERIFY((finishedSuccessfully.count() == 0) && (finishedSuccessfully.wait(100) == false));
        QTRY_VERIFY_WITH_TIMEOUT(false == resCallbackHandler, zmqWaitTime);
    }

    {
        resCallbackHandler = false;
        auto deferredRequest = client.sendRequest("test_res_callback",
                                                  QJsonObject({{"response_type", "notification"}}));

        QVERIFY(deferredRequest != nullptr);
        QSignalSpy finishedSuccessfully(deferredRequest, &DeferredRequest::finishedSuccessfully);
        QVERIFY(finishedSuccessfully.isValid());

        QVERIFY((finishedSuccessfully.count() == 0) && (finishedSuccessfully.wait(100) == false));
        QTRY_VERIFY_WITH_TIMEOUT(resCallbackHandler, zmqWaitTime);
    }
}

void StrataClientTest::testWithOnlyErrorCallbacks()
{
    using DeferredRequest = strata::strataRPC::DeferredRequest;

    int zmqWaitTime = 100;
    bool errorCallbackHander = false;

    ServerConnector server(address_);
    server.initialize();

    connect(
        &server, &ServerConnector::messageReceived, this,
        [&server](const QByteArray &clientId, const QByteArray &jsonMessage) {
            QJsonObject jsonObject(QJsonDocument::fromJson(jsonMessage).object());
            QString handlerName = jsonObject.value("method").toString();
            double id = jsonObject.value("id").toDouble();
            QByteArray response = "";
            QString responseType =
                jsonObject.value("params").toObject().value("response_type").toString();

            if (responseType == "notification") {
                response =
                    QJsonDocument(
                        QJsonObject({{"jsonrpc", "2.0"}, {"method", handlerName}, {"params", {}}}))
                        .toJson(QJsonDocument::JsonFormat::Compact);
            } else if (responseType == "error") {
                response = QJsonDocument(QJsonObject({{"jsonrpc", "2.0"},
                                                      {"method", handlerName},
                                                      {"error", QJsonObject()},
                                                      {"id", id}}))
                               .toJson(QJsonDocument::JsonFormat::Compact);
            } else if (responseType == "result") {
                response = QJsonDocument(QJsonObject({{"jsonrpc", "2.0"},
                                                      {"method", handlerName},
                                                      {"result", QJsonObject()},
                                                      {"id", id}}))
                               .toJson(QJsonDocument::JsonFormat::Compact);
            } else {
                return;
            }

            server.sendMessage(clientId, response);
        });

    StrataClient client(address_);

    connect(&client, &StrataClient::errorOccurred, this,
            [](const StrataClient::ClientError &errorType, const QString &) {
                if (StrataClient::ClientError::RequestTimeout == errorType) {
                    QFAIL_("Request timed out.");
                }
            });

    client.registerHandler("test_err_callback", [&errorCallbackHander](const QJsonObject &) {
        errorCallbackHander = true;
    });

    client.connect();
    waitForZmqMessages(zmqWaitTime);

    {
        errorCallbackHander = false;
        auto deferredRequest =
            client.sendRequest("test_err_callback", QJsonObject({{"response_type", "result"}}));

        QVERIFY(deferredRequest != nullptr);
        QSignalSpy finishedWithError(deferredRequest, &DeferredRequest::finishedWithError);
        QVERIFY(finishedWithError.isValid());

        QVERIFY((finishedWithError.count() == 0) && (finishedWithError.wait(100) == false));
        QVERIFY(false == errorCallbackHander);
    }

    {
        errorCallbackHander = false;
        auto deferredRequest =
            client.sendRequest("test_err_callback", QJsonObject({{"response_type", "error"}}));

        QVERIFY(deferredRequest != nullptr);
        QSignalSpy finishedWithError(deferredRequest, &DeferredRequest::finishedWithError);
        QVERIFY(finishedWithError.isValid());

        QVERIFY((finishedWithError.count() == 1) || (finishedWithError.wait(250) == true));
        QVERIFY(false == errorCallbackHander);
    }

    {
        errorCallbackHander = false;
        auto deferredRequest = client.sendRequest("test_err_callback",
                                                  QJsonObject({{"response_type", "notification"}}));

        QVERIFY(deferredRequest != nullptr);
        QSignalSpy finishedWithError(deferredRequest, &DeferredRequest::finishedWithError);
        QVERIFY(finishedWithError.isValid());

        QVERIFY((finishedWithError.count() == 0) && (finishedWithError.wait(100) == false));
        QTRY_VERIFY_WITH_TIMEOUT(errorCallbackHander, zmqWaitTime);
    }
}

void StrataClientTest::testTimedoutRequest()
{
    using DeferredRequest = strata::strataRPC::DeferredRequest;

    int testsNum = 10;
    int timedOutRequests = 0;

    ServerConnector server(address_);
    server.initialize();

    StrataClient client(address_);
    client.connect();
    waitForZmqMessages(50);

    for (int i = 0; i < testsNum; i++) {
        auto deferredRequest = client.sendRequest("test_timeout_request", QJsonObject({{}}));
        QVERIFY(deferredRequest != nullptr);
        connect(deferredRequest, &DeferredRequest::finishedWithError, this,
                [&timedOutRequests](const QJsonObject &) { ++timedOutRequests; });
    }

    QTRY_COMPARE_WITH_TIMEOUT(timedOutRequests, testsNum, 3000);
}

void StrataClientTest::testNoTimedoutRequest()
{
    using DeferredRequest = strata::strataRPC::DeferredRequest;
    int testsNum = 10;
    int timedOutRequests = 0;
    int successCallBacks = 0;

    ServerConnector server(address_);

    connect(&server, &ServerConnector::messageReceived, this,
            [&server](const QByteArray &clientId, const QByteArray &message) {
                QJsonObject jsonObject(QJsonDocument::fromJson(message).object());
                QString handlerName = jsonObject.value("method").toString();
                int id = jsonObject.value("id").toDouble();
                QByteArray response = QJsonDocument(QJsonObject({{"jsonrpc", "2.0"},
                                                                 {"method", handlerName},
                                                                 {"result", QJsonObject()},
                                                                 {"id", id}}))
                                          .toJson(QJsonDocument::JsonFormat::Compact);

                server.sendMessage(clientId, response);
            });

    server.initialize();

    StrataClient client(address_);

    connect(&client, &StrataClient::errorOccurred, this,
            [&timedOutRequests](const StrataClient::ClientError &errorType, const QString &) {
                if (StrataClient::ClientError::RequestTimeout == errorType) {
                    ++timedOutRequests;
                }
            });

    client.connect();
    waitForZmqMessages(50);

    for (int i = 0; i < testsNum; i++) {
        auto deferredRequest = client.sendRequest("test_timeout_request", QJsonObject({{}}));
        QVERIFY(deferredRequest != nullptr);
        connect(deferredRequest, &DeferredRequest::finishedSuccessfully, this,
                [&successCallBacks](const QJsonObject &) { ++successCallBacks; });
    }

    QTRY_COMPARE_WITH_TIMEOUT(timedOutRequests, 0, 100);
    QTRY_COMPARE_WITH_TIMEOUT(successCallBacks, testsNum, 100);
}

void StrataClientTest::testErrorOccourredSignal()
{
    qRegisterMetaType<StrataClient::ClientError>("StrataClient::ClientError");

    StrataClient client(address_);
    ServerConnector server(address_);
    StrataClient::ClientError errorType;
    QSignalSpy errorOccurred(&client, &StrataClient::errorOccurred);
    QVERIFY(errorOccurred.isValid());

    client.registerHandler("handler_1", [](const QJsonObject &) { return; });
    client.registerHandler("handler_1", [](const QJsonObject &) { return; });
    QVERIFY((errorOccurred.count() >= 1) || (errorOccurred.wait(250) == true));
    errorType = qvariant_cast<StrataClient::ClientError>(errorOccurred.takeFirst().at(0));
    QCOMPARE(errorType, StrataClient::ClientError::FailedToRegisterHandler);
    errorOccurred.clear();

    client.unregisterHandler("handler_2");
    QVERIFY((errorOccurred.count() >= 1) || (errorOccurred.wait(250) == true));
    errorType = qvariant_cast<StrataClient::ClientError>(errorOccurred.takeFirst().at(0));
    QCOMPARE(errorType, StrataClient::ClientError::FailedToUnregisterHandler);

    errorOccurred.clear();

    client.disconnect();
    // fail to send unregister & fail to disconnect.
    QVERIFY((errorOccurred.count() >= 1) || (errorOccurred.wait(250) == true));
    QVERIFY((errorOccurred.count() >= 2) || (errorOccurred.wait(250) == true));
    errorType = qvariant_cast<StrataClient::ClientError>(errorOccurred.at(0).at(0));
    QCOMPARE(errorType, StrataClient::ClientError::FailedToSendRequest);
    errorType = qvariant_cast<StrataClient::ClientError>(errorOccurred.at(1).at(0));
    QCOMPARE(errorType, StrataClient::ClientError::FailedToDisconnect);
    errorOccurred.clear();

    client.sendNotification("test_notification", QJsonObject{{}});
    QVERIFY((errorOccurred.count() >= 1) || (errorOccurred.wait(250) == true));
    errorType = qvariant_cast<StrataClient::ClientError>(errorOccurred.takeFirst().at(0));
    QCOMPARE(errorType, StrataClient::ClientError::FailedToSendNotification);
    errorOccurred.clear();

    server.initialize();
    client.connect();
    waitForZmqMessages(50);
    client.connect();  // This should fail

    QVERIFY((errorOccurred.count() >= 1) || (errorOccurred.wait(250) == true));
    QVERIFY((errorOccurred.count() >= 2) || (errorOccurred.wait(3000) == true));
    QVERIFY((errorOccurred.count() >= 3) || (errorOccurred.wait(250) == true));
    errorType = qvariant_cast<StrataClient::ClientError>(errorOccurred.at(0).at(0));
    QCOMPARE(errorType, StrataClient::ClientError::FailedToConnect);
    errorType = qvariant_cast<StrataClient::ClientError>(errorOccurred.at(1).at(0));
    QCOMPARE(errorType, StrataClient::ClientError::RequestTimeout);
    errorType = qvariant_cast<StrataClient::ClientError>(errorOccurred.at(2).at(0));
    QCOMPARE(errorType, StrataClient::ClientError::FailedToConnect);
    errorOccurred.clear();

    server.sendMessage("StrataClient", "not Json message");
    server.sendMessage("StrataClient", R"({"cmd":"this-is-invalid-api})");

    QVERIFY((errorOccurred.count() >= 1) || (errorOccurred.wait(250) == true));
    QVERIFY((errorOccurred.count() >= 2) || (errorOccurred.wait(250) == true));
    QVERIFY((errorOccurred.count() >= 3) || (errorOccurred.wait(250) == true));
    QVERIFY((errorOccurred.count() >= 4) || (errorOccurred.wait(250) == true));
    for (const auto &error : errorOccurred) {
        errorType = qvariant_cast<StrataClient::ClientError>(error.at(0));
        QCOMPARE(errorType, StrataClient::ClientError::FailedToBuildServerMessage);
    }
    errorOccurred.clear();

    QByteArray response = QJsonDocument(QJsonObject({{"jsonrpc", "2.0"},
                                                     {"method", "random_handler"},
                                                     {"result", QJsonObject()},
                                                     {"id", 10}}))
                              .toJson(QJsonDocument::JsonFormat::Compact);
    server.sendMessage("StrataClient", response);

    QVERIFY((errorOccurred.count() >= 1) || (errorOccurred.wait(250) == true));
    QVERIFY((errorOccurred.count() >= 2) || (errorOccurred.wait(250) == true));
    errorType = qvariant_cast<StrataClient::ClientError>(errorOccurred.at(0).at(0));
    QCOMPARE(errorType, StrataClient::ClientError::PendingRequestNotFound);
    errorType = qvariant_cast<StrataClient::ClientError>(errorOccurred.at(1).at(0));
    QCOMPARE(errorType, StrataClient::ClientError::FailedToBuildServerMessage);
    errorOccurred.clear();

    QByteArray noRegisteredHandler = QJsonDocument(QJsonObject({{"jsonrpc", "2.0"},
                                                                {"method", "non_existing_handler"},
                                                                {"params", QJsonObject()}}))
                                         .toJson(QJsonDocument::JsonFormat::Compact);
    server.sendMessage("StrataClient", noRegisteredHandler);

    QVERIFY((errorOccurred.count() >= 1) || (errorOccurred.wait(250) == true));
    errorType = qvariant_cast<StrataClient::ClientError>(errorOccurred.takeFirst().at(0));
    QCOMPARE(errorType, StrataClient::ClientError::HandlerNotFound);
    errorOccurred.clear();
}

void StrataClientTest::testSendNotification()
{
    bool serverGotNotification = false;

    ServerConnector server(address_);
    server.initialize();

    connect(&server, &ServerConnector::messageReceived, this,
            [&serverGotNotification](const QByteArray &, const QByteArray &message) {
                QJsonObject jsonObject(QJsonDocument::fromJson(message).object());

                if (jsonObject.value("method").toString() == "test_notification") {
                    serverGotNotification = true;

                    QVERIFY(jsonObject.contains("jsonrpc"));
                    QVERIFY(jsonObject.value("jsonrpc").isString());

                    QVERIFY(jsonObject.contains("id"));
                    QVERIFY(jsonObject.value("id").isDouble());
                    QCOMPARE(jsonObject.value("id").toDouble(), 0);

                    QVERIFY(jsonObject.contains("method"));
                    QVERIFY(jsonObject.value("method").isString());
                    QCOMPARE(jsonObject.value("method").toString(), "test_notification");

                    QVERIFY(jsonObject.contains("params"));
                    QVERIFY(jsonObject.value("params").isObject());
                }
            });

    StrataClient client(address_);
    client.connect();
    waitForZmqMessages(50);
    client.sendNotification("test_notification", QJsonObject{{"test_key", "test_value"}});

    QTRY_VERIFY_WITH_TIMEOUT(serverGotNotification, 100);
}
