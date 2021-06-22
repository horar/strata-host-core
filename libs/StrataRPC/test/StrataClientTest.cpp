#include "StrataClientTest.h"
#include "ServerConnector.h"

#include <QSignalSpy>

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
    QVERIFY_(client.registerHandler("handler_1", [](const QJsonObject &) { return; }));
    QVERIFY_(client.registerHandler("handler_2", [](const QJsonObject &) { return; }));
    QVERIFY_(false == client.registerHandler("handler_2", [](const QJsonObject &) { return; }));

    QVERIFY_(client.unregisterHandler("handler_1"));
    QVERIFY_(client.unregisterHandler("handler_2"));
    QVERIFY_(false == client.unregisterHandler("handler_2"));
    QVERIFY_(false == client.unregisterHandler("not_registered_handler"));
}

void StrataClientTest::testConnectDisconnectToTheServer()
{
    bool serverRevicedMessage = false;
    bool clientReceivedMessage = false;

    // serverConnector set up
    strata::strataRPC::ServerConnector server(address_);
    server.initialize();
    connect(
        &server, &strata::strataRPC::ServerConnector::messageReceived, this,
        [&server, &serverRevicedMessage](const QByteArray &clientId, const QByteArray &message) {
            qDebug() << "ServerConnector new message handler. client id:" << clientId << "message"
                     << message;
            serverRevicedMessage = true;
            server.sendMessage(clientId, message);
        });

    // StrataClient set up
    StrataClient client(address_);

    QSignalSpy signalSpy(&client, &StrataClient::connected);

    connect(&client, &StrataClient::messageParsed, this,
            [&clientReceivedMessage] { clientReceivedMessage = true; });

    serverRevicedMessage = false;
    client.connect();
    QTRY_VERIFY_WITH_TIMEOUT(serverRevicedMessage, 100);
    QTRY_COMPARE_WITH_TIMEOUT(signalSpy.count(), 1, 100);
    signalSpy.clear();

    serverRevicedMessage = false;
    clientReceivedMessage = false;
    client.disconnect();
    QTRY_VERIFY_WITH_TIMEOUT(serverRevicedMessage, 100);
    QTRY_VERIFY_WITH_TIMEOUT(false == clientReceivedMessage, 100);

    serverRevicedMessage = false;
    clientReceivedMessage = false;
    server.sendMessage("StrataClient", "test message");
    QTRY_VERIFY_WITH_TIMEOUT(false == serverRevicedMessage, 100);
    QTRY_VERIFY_WITH_TIMEOUT(false == clientReceivedMessage, 100);

    serverRevicedMessage = false;
    clientReceivedMessage = false;
    client.connect();
    QTRY_VERIFY_WITH_TIMEOUT(serverRevicedMessage, 100);
    QTRY_COMPARE_WITH_TIMEOUT(signalSpy.count(), 1, 100);
    signalSpy.clear();
}

void StrataClientTest::testBuildRequest()
{
    // some variables used for validation.
    bool serverRevicedMessage = false;
    QString expectedMethod = "";
    int expectedId = 0;

    strata::strataRPC::ServerConnector server(address_);
    server.initialize();
    connect(&server, &strata::strataRPC::ServerConnector::messageReceived, this,
            [&expectedId, &expectedMethod, &serverRevicedMessage](const QByteArray &,
                                                                  const QByteArray &message) {
                QJsonObject jsonObject(QJsonDocument::fromJson(message).object());

                QVERIFY_(jsonObject.contains("jsonrpc"));
                QVERIFY_(jsonObject.value("jsonrpc").isString());

                QVERIFY_(jsonObject.contains("id"));
                QVERIFY_(jsonObject.value("id").isDouble());
                QCOMPARE_(jsonObject.value("id").toDouble(), expectedId);

                QVERIFY_(jsonObject.contains("method"));
                QVERIFY_(jsonObject.value("method").isString());
                QCOMPARE_(jsonObject.value("method").toString(), expectedMethod);

                QVERIFY_(jsonObject.contains("params"));
                QVERIFY_(jsonObject.value("params").isObject());

                serverRevicedMessage = true;
            });

    StrataClient client(address_);

    expectedMethod = "register_client";
    expectedId = 1;
    serverRevicedMessage = false;
    client.connect();
    QTRY_VERIFY_WITH_TIMEOUT(serverRevicedMessage, 100);

    expectedMethod = "method_1";
    expectedId = 2;
    serverRevicedMessage = false;
    {
        auto deferredRequest = client.sendRequest("method_1", {{"param_1", 0}});
        QVERIFY_(deferredRequest != nullptr);
        QTRY_VERIFY_WITH_TIMEOUT(serverRevicedMessage, 100);
    }

    expectedMethod = "method_2";
    expectedId = 3;
    serverRevicedMessage = false;
    {
        auto deferredRequest = client.sendRequest("method_2", {});
        QVERIFY_(deferredRequest != nullptr);
        QTRY_VERIFY_WITH_TIMEOUT(serverRevicedMessage, 100);
    }
}

void StrataClientTest::testNonDefaultDealerId()
{
    bool defaultIdRecieved = false;
    bool customIdRecieved = false;

    strata::strataRPC::ServerConnector server(address_);
    server.initialize();

    connect(
        &server, &strata::strataRPC::ServerConnector::messageReceived, this,
        [&defaultIdRecieved, &customIdRecieved](const QByteArray &clientId, const QByteArray &) {
            if (clientId == "customId") {
                customIdRecieved = true;
            } else if (clientId == "StrataClient") {
                defaultIdRecieved = true;
            }
        });

    StrataClient client_1(address_);
    client_1.connect();

    StrataClient client_2(address_, "customId");
    client_2.connect();

    QTRY_VERIFY_WITH_TIMEOUT(defaultIdRecieved, 100);
    QTRY_VERIFY_WITH_TIMEOUT(customIdRecieved, 100);
}

void StrataClientTest::testWithNoCallbacks()
{
    int zmqWaitTime = 50;
    bool noCallbackHandler = false;

    strata::strataRPC::ServerConnector server(address_);
    server.initialize();

    connect(
        &server, &strata::strataRPC::ServerConnector::messageReceived, this,
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
    QTRY_VERIFY_WITH_TIMEOUT(false == noCallbackHandler, zmqWaitTime);

    noCallbackHandler = false;
    client.sendRequest("test_no_callbacks", QJsonObject({{"response_type", "result"}}));
    QTRY_VERIFY_WITH_TIMEOUT(false == noCallbackHandler, zmqWaitTime);
}

void StrataClientTest::testWithAllCallbacks()
{
    using DeferredRequest = strata::strataRPC::DeferredRequest;

    int zmqWaitTime = 50;
    bool allCallbacksHandler = false;
    bool allCallbacksErrCallback = false;
    bool allCallbacksResCallback = false;

    strata::strataRPC::ServerConnector server(address_);
    server.initialize();

    connect(
        &server, &strata::strataRPC::ServerConnector::messageReceived, this,
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

    client.registerHandler("test_all_callbacks", [&allCallbacksHandler](const QJsonObject &) {
        allCallbacksHandler = true;
    });

    client.connect();
    waitForZmqMessages(zmqWaitTime);

    {
        allCallbacksErrCallback = false;
        allCallbacksResCallback = false;
        allCallbacksHandler = false;
        auto deferredRequest =
            client.sendRequest("test_all_callbacks", QJsonObject({{"response_type", "error"}}));

        QVERIFY_(deferredRequest != nullptr);

        connect(
            deferredRequest, &DeferredRequest::finishedSuccessfully, this,
            [&allCallbacksResCallback](const QJsonObject &) { allCallbacksResCallback = true; });
        connect(
            deferredRequest, &DeferredRequest::finishedWithError, this,
            [&allCallbacksErrCallback](const QJsonObject &) { allCallbacksErrCallback = true; });
        connect(deferredRequest, &DeferredRequest::requestTimedout, this,
                [](int) { QFAIL_("Request timed out."); });

        QTRY_VERIFY_WITH_TIMEOUT(allCallbacksErrCallback, zmqWaitTime);
        QTRY_VERIFY_WITH_TIMEOUT(false == allCallbacksResCallback, zmqWaitTime);
        QTRY_VERIFY_WITH_TIMEOUT(false == allCallbacksHandler, zmqWaitTime);
    }

    {
        allCallbacksErrCallback = false;
        allCallbacksResCallback = false;
        allCallbacksHandler = false;
        auto deferredRequest =
            client.sendRequest("test_all_callbacks", QJsonObject({{"response_type", "result"}}));

        QVERIFY_(deferredRequest != nullptr);

        connect(
            deferredRequest, &DeferredRequest::finishedSuccessfully, this,
            [&allCallbacksResCallback](const QJsonObject &) { allCallbacksResCallback = true; });
        connect(
            deferredRequest, &DeferredRequest::finishedWithError, this,
            [&allCallbacksErrCallback](const QJsonObject &) { allCallbacksErrCallback = true; });
        connect(deferredRequest, &DeferredRequest::requestTimedout, this,
                [](int) { QFAIL_("Request timed out."); });

        QTRY_VERIFY_WITH_TIMEOUT(allCallbacksResCallback, zmqWaitTime);
        QTRY_VERIFY_WITH_TIMEOUT(false == allCallbacksErrCallback, zmqWaitTime);
        QTRY_VERIFY_WITH_TIMEOUT(false == allCallbacksHandler, zmqWaitTime);
    }

    {
        allCallbacksErrCallback = false;
        allCallbacksResCallback = false;
        allCallbacksHandler = false;

        auto deferredRequest = client.sendRequest("test_all_callbacks",
                                                  QJsonObject({{"response_type", "notification"}}));

        QVERIFY_(deferredRequest != nullptr);

        connect(
            deferredRequest, &DeferredRequest::finishedSuccessfully, this,
            [&allCallbacksResCallback](const QJsonObject &) { allCallbacksResCallback = true; });
        connect(
            deferredRequest, &DeferredRequest::finishedWithError, this,
            [&allCallbacksErrCallback](const QJsonObject &) { allCallbacksErrCallback = true; });
        connect(deferredRequest, &DeferredRequest::requestTimedout, this,
                [](int) { QFAIL_("Request timed out."); });

        QTRY_VERIFY_WITH_TIMEOUT(false == allCallbacksResCallback, zmqWaitTime);
        QTRY_VERIFY_WITH_TIMEOUT(false == allCallbacksErrCallback, zmqWaitTime);
        QTRY_VERIFY_WITH_TIMEOUT(allCallbacksHandler, zmqWaitTime);
    }
}

void StrataClientTest::testWithOnlyResultCallbacks()
{
    using DeferredRequest = strata::strataRPC::DeferredRequest;

    int zmqWaitTime = 50;
    bool resCallbackHandler = false;
    bool resCallback = false;

    strata::strataRPC::ServerConnector server(address_);
    server.initialize();

    connect(
        &server, &strata::strataRPC::ServerConnector::messageReceived, this,
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

    client.registerHandler("test_res_callback", [&resCallbackHandler](const QJsonObject &) {
        resCallbackHandler = true;
    });

    client.connect();
    waitForZmqMessages(zmqWaitTime);

    {
        resCallback = false;
        resCallbackHandler = false;
        auto deferredRequest =
            client.sendRequest("test_res_callback", QJsonObject({{"response_type", "result"}}));

        QVERIFY_(deferredRequest != nullptr);

        connect(deferredRequest, &DeferredRequest::finishedSuccessfully, this,
                [&resCallback](const QJsonObject &) { resCallback = true; });
        connect(deferredRequest, &DeferredRequest::requestTimedout, this,
                [](int) { QFAIL_("Request timed out."); });

        QTRY_VERIFY_WITH_TIMEOUT(resCallback, zmqWaitTime);
        QTRY_VERIFY_WITH_TIMEOUT(false == resCallbackHandler, zmqWaitTime);
    }

    {
        resCallback = false;
        resCallbackHandler = false;
        auto deferredRequest =
            client.sendRequest("test_res_callback", QJsonObject({{"response_type", "error"}}));

        QVERIFY_(deferredRequest != nullptr);

        connect(deferredRequest, &DeferredRequest::finishedSuccessfully, this,
                [&resCallback](const QJsonObject &) { resCallback = true; });
        connect(deferredRequest, &DeferredRequest::requestTimedout, this,
                [](int) { QFAIL_("Request timed out."); });

        QTRY_VERIFY_WITH_TIMEOUT(false == resCallback, zmqWaitTime);
        QTRY_VERIFY_WITH_TIMEOUT(false == resCallbackHandler, zmqWaitTime);
    }

    {
        resCallback = false;
        resCallbackHandler = false;
        auto deferredRequest = client.sendRequest("test_res_callback",
                                                  QJsonObject({{"response_type", "notification"}}));

        QVERIFY_(deferredRequest != nullptr);

        connect(deferredRequest, &DeferredRequest::finishedSuccessfully, this,
                [&resCallback](const QJsonObject &) { resCallback = true; });
        connect(deferredRequest, &DeferredRequest::requestTimedout, this,
                [](int) { QFAIL_("Request timed out."); });

        QTRY_VERIFY_WITH_TIMEOUT(false == resCallback, zmqWaitTime);
        QTRY_VERIFY_WITH_TIMEOUT(resCallbackHandler, zmqWaitTime);
    }
}

void StrataClientTest::testWithOnlyErrorCallbacks()
{
    using DeferredRequest = strata::strataRPC::DeferredRequest;

    int zmqWaitTime = 50;
    bool errorCallbackHander = false;
    bool errorCallback = false;

    strata::strataRPC::ServerConnector server(address_);
    server.initialize();

    connect(
        &server, &strata::strataRPC::ServerConnector::messageReceived, this,
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

    client.registerHandler("test_err_callback", [&errorCallbackHander](const QJsonObject &) {
        errorCallbackHander = true;
    });

    client.connect();
    waitForZmqMessages(zmqWaitTime);

    {
        errorCallback = false;
        errorCallbackHander = false;
        auto deferredRequest =
            client.sendRequest("test_err_callback", QJsonObject({{"response_type", "result"}}));

        QVERIFY_(deferredRequest != nullptr);

        connect(deferredRequest, &DeferredRequest::finishedWithError, this,
                [&errorCallback](const QJsonObject &) { errorCallback = true; });
        connect(deferredRequest, &DeferredRequest::requestTimedout, this,
                [](int) { QFAIL_("Request timed out."); });

        QTRY_VERIFY_WITH_TIMEOUT(false == errorCallback, zmqWaitTime);
        QTRY_VERIFY_WITH_TIMEOUT(false == errorCallbackHander, zmqWaitTime);
    }

    {
        errorCallback = false;
        errorCallbackHander = false;
        auto deferredRequest =
            client.sendRequest("test_err_callback", QJsonObject({{"response_type", "error"}}));

        QVERIFY_(deferredRequest != nullptr);

        connect(deferredRequest, &DeferredRequest::finishedWithError, this,
                [&errorCallback](const QJsonObject &) { errorCallback = true; });
        connect(deferredRequest, &DeferredRequest::requestTimedout, this,
                [](int) { QFAIL_("Request timed out."); });

        QTRY_VERIFY_WITH_TIMEOUT(errorCallback, zmqWaitTime);
        QTRY_VERIFY_WITH_TIMEOUT(false == errorCallbackHander, zmqWaitTime);
    }

    {
        errorCallback = false;
        errorCallbackHander = false;
        auto deferredRequest = client.sendRequest("test_err_callback",
                                                  QJsonObject({{"response_type", "notification"}}));

        QVERIFY_(deferredRequest != nullptr);

        connect(deferredRequest, &DeferredRequest::finishedWithError, this,
                [&errorCallback](const QJsonObject &) { errorCallback = true; });
        connect(deferredRequest, &DeferredRequest::requestTimedout, this,
                [](int) { QFAIL_("Request timed out."); });

        QTRY_VERIFY_WITH_TIMEOUT(false == errorCallback, zmqWaitTime);
        QTRY_VERIFY_WITH_TIMEOUT(errorCallbackHander, zmqWaitTime);
    }
}

void StrataClientTest::testTimedoutRequest()
{
    using DeferredRequest = strata::strataRPC::DeferredRequest;

    int testsNum = 10;
    int timedOutRequests = 0;

    strata::strataRPC::ServerConnector server(address_);
    server.initialize();

    StrataClient client(address_);
    client.connect();
    waitForZmqMessages(50);

    for (int i = 0; i < testsNum; i++) {
        auto deferredRequest = client.sendRequest("test_timeout_request", QJsonObject({{}}));
        QVERIFY_(deferredRequest != nullptr);
        connect(deferredRequest, &DeferredRequest::finishedWithError, this,
                [&timedOutRequests](const QJsonObject &) { ++timedOutRequests; });
    }

    QTRY_COMPARE_WITH_TIMEOUT(timedOutRequests, testsNum, 1000);
}

void StrataClientTest::testNoTimedoutRequest()
{
    using DeferredRequest = strata::strataRPC::DeferredRequest;
    int testsNum = 10;
    int timedOutRequests = 0;
    int successCallBacks = 0;

    strata::strataRPC::ServerConnector server(address_);

    connect(&server, &strata::strataRPC::ServerConnector::messageReceived, this,
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
    client.connect();
    waitForZmqMessages(50);

    for (int i = 0; i < testsNum; i++) {
        auto deferredRequest = client.sendRequest("test_timeout_request", QJsonObject({{}}));
        QVERIFY_(deferredRequest != nullptr);
        connect(deferredRequest, &DeferredRequest::finishedSuccessfully, this,
                [&successCallBacks](const QJsonObject &) { ++successCallBacks; });
        connect(deferredRequest, &DeferredRequest::requestTimedout, this,
                [&timedOutRequests](int) { ++timedOutRequests; });
    }

    QTRY_COMPARE_WITH_TIMEOUT(timedOutRequests, 0, 100);
    QTRY_COMPARE_WITH_TIMEOUT(successCallBacks, testsNum, 100);
}

void StrataClientTest::testErrorOccourredSignal()
{
    qRegisterMetaType<StrataClient::ClientError>("StrataClient::ClientError");

    StrataClient client(address_);
    strata::strataRPC::ServerConnector server(address_);
    StrataClient::ClientError errorType;
    QSignalSpy errorOccurred(&client, &StrataClient::errorOccurred);

    client.registerHandler("handler_1", [](const QJsonObject &) { return; });
    client.registerHandler("handler_1", [](const QJsonObject &) { return; });
    QCOMPARE_(errorOccurred.count(), 1);
    errorType = qvariant_cast<StrataClient::ClientError>(errorOccurred.takeFirst().at(0));
    QCOMPARE_(errorType, StrataClient::ClientError::FailedToRegisterHandler);
    // waitForZmqMessages(50);
    errorOccurred.clear();

    client.unregisterHandler("handler_2");
    QCOMPARE_(errorOccurred.count(), 1);
    errorType = qvariant_cast<StrataClient::ClientError>(errorOccurred.takeFirst().at(0));
    QCOMPARE_(errorType, StrataClient::ClientError::FailedToUnregisterHandler);

    errorOccurred.clear();

    client.disconnect();
    waitForZmqMessages(50);
    QCOMPARE_(errorOccurred.count(), 2);  // fail to send unregister & fail to disconnect.
    errorType = qvariant_cast<StrataClient::ClientError>(errorOccurred.at(0).at(0));
    QCOMPARE_(errorType, StrataClient::ClientError::FailedToSendRequest);
    errorType = qvariant_cast<StrataClient::ClientError>(errorOccurred.at(1).at(0));
    QCOMPARE_(errorType, StrataClient::ClientError::FailedToDisconnect);
    errorOccurred.clear();

    client.sendNotification("test_notification", QJsonObject{{}});
    waitForZmqMessages(50);
    errorType = qvariant_cast<StrataClient::ClientError>(errorOccurred.takeFirst().at(0));
    QCOMPARE_(errorType, StrataClient::ClientError::FailedToSendNotification);
    // waitForZmqMessages();
    errorOccurred.clear();

    server.initialize();
    client.connect();
    waitForZmqMessages(50);
    client.connect();  // This should fail
    // waitForZmqMessages(50);
    QTRY_COMPARE_WITH_TIMEOUT(errorOccurred.count(), 1, 100);
    errorType = qvariant_cast<StrataClient::ClientError>(errorOccurred.takeFirst().at(0));
    QCOMPARE_(errorType, StrataClient::ClientError::FailedToConnect);
    errorOccurred.clear();

    QTRY_COMPARE_WITH_TIMEOUT(errorOccurred.count(), 2, 500);
    errorType = qvariant_cast<StrataClient::ClientError>(errorOccurred.at(0).at(0));
    QCOMPARE_(errorType, StrataClient::ClientError::RequestTimeout);
    errorType = qvariant_cast<StrataClient::ClientError>(errorOccurred.at(1).at(0));
    QCOMPARE_(errorType, StrataClient::ClientError::FailedToConnect);
    errorOccurred.clear();

    server.sendMessage("StrataClient", "not Json message");
    server.sendMessage("StrataClient", R"({"cmd":"this-is-invalid-api})");

    QTRY_COMPARE_WITH_TIMEOUT(errorOccurred.count(), 4, 100);
    for (const auto &error : errorOccurred) {
        errorType = qvariant_cast<StrataClient::ClientError>(error.at(0));
        QCOMPARE_(errorType, StrataClient::ClientError::FailedToBuildServerMessage);
    }
    errorOccurred.clear();

    QByteArray response = QJsonDocument(QJsonObject({{"jsonrpc", "2.0"},
                                                     {"method", "random_handler"},
                                                     {"result", QJsonObject()},
                                                     {"id", 10}}))
                              .toJson(QJsonDocument::JsonFormat::Compact);
    server.sendMessage("StrataClient", response);

    QTRY_COMPARE_WITH_TIMEOUT(errorOccurred.count(), 2, 100);
    errorType = qvariant_cast<StrataClient::ClientError>(errorOccurred.at(0).at(0));
    QCOMPARE_(errorType, StrataClient::ClientError::PendingRequestNotFound);
    errorType = qvariant_cast<StrataClient::ClientError>(errorOccurred.at(1).at(0));
    QCOMPARE_(errorType, StrataClient::ClientError::FailedToBuildServerMessage);
    errorOccurred.clear();

    QByteArray noRegisteredHandler = QJsonDocument(QJsonObject({{"jsonrpc", "2.0"},
                                                                {"method", "non_existing_handler"},
                                                                {"params", QJsonObject()}}))
                                         .toJson(QJsonDocument::JsonFormat::Compact);
    server.sendMessage("StrataClient", noRegisteredHandler);

    QTRY_COMPARE_WITH_TIMEOUT(errorOccurred.count(), 1, 100);
    errorType = qvariant_cast<StrataClient::ClientError>(errorOccurred.takeFirst().at(0));
    QCOMPARE_(errorType, StrataClient::ClientError::HandlerNotFound);
    errorOccurred.clear();
}

void StrataClientTest::testSendNotification()
{
    bool serverGotNotification = false;

    strata::strataRPC::ServerConnector server(address_);
    server.initialize();

    connect(&server, &strata::strataRPC::ServerConnector::messageReceived, this,
            [&serverGotNotification](const QByteArray &, const QByteArray &message) {
                QJsonObject jsonObject(QJsonDocument::fromJson(message).object());

                if (jsonObject.value("method").toString() == "test_notification") {
                    serverGotNotification = true;

                    QVERIFY_(jsonObject.contains("jsonrpc"));
                    QVERIFY_(jsonObject.value("jsonrpc").isString());

                    QVERIFY_(jsonObject.contains("id"));
                    QVERIFY_(jsonObject.value("id").isDouble());
                    QCOMPARE_(jsonObject.value("id").toDouble(), 0);

                    QVERIFY_(jsonObject.contains("method"));
                    QVERIFY_(jsonObject.value("method").isString());
                    QCOMPARE_(jsonObject.value("method").toString(), "test_notification");

                    QVERIFY_(jsonObject.contains("params"));
                    QVERIFY_(jsonObject.value("params").isObject());
                }
            });

    StrataClient client(address_);
    client.connect();
    waitForZmqMessages(50);
    client.sendNotification("test_notification", QJsonObject{{"test_key", "test_value"}});

    QTRY_VERIFY_WITH_TIMEOUT(serverGotNotification, 100);
}
