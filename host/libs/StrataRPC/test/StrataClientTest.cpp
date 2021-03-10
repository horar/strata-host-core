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
    QVERIFY_(
        client.registerHandler("handler_1", [](const strata::strataRPC::Message &) { return; }));
    QVERIFY_(
        client.registerHandler("handler_2", [](const strata::strataRPC::Message &) { return; }));
    QVERIFY_(false == client.registerHandler("handler_2",
                                             [](const strata::strataRPC::Message &) { return; }));

    QVERIFY_(client.unregisterHandler("handler_1"));
    QVERIFY_(client.unregisterHandler("handler_2"));
    QVERIFY_(false == client.unregisterHandler("handler_2"));
    QVERIFY_(false == client.unregisterHandler("not_registered_handler"));
}

void StrataClientTest::testConnectDisconnectToTheServer()
{
    // serverConnector set up
    strata::strataRPC::ServerConnector server(address_);
    server.initilizeConnector();
    bool serverRevicedMessage = false;
    connect(
        &server, &strata::strataRPC::ServerConnector::newMessageReceived, this,
        [&server, &serverRevicedMessage](const QByteArray &clientId, const QByteArray &message) {
            qDebug() << "ServerConnector new message handler. client id:" << clientId << "message"
                     << message;
            serverRevicedMessage = true;
            server.sendMessage(clientId, message);
        });

    // StrataClient set up
    StrataClient client(address_);

    bool clientReceivedMessage = false;
    connect(&client, &StrataClient::newServerMessageParsed, this,
            [&clientReceivedMessage] { clientReceivedMessage = true; });

    serverRevicedMessage = false;
    clientReceivedMessage = false;
    QVERIFY_(client.connectServer());
    waitForZmqMessages();
    QVERIFY_(serverRevicedMessage);
    QVERIFY_(clientReceivedMessage);

    serverRevicedMessage = false;
    clientReceivedMessage = false;
    QVERIFY_(client.disconnectServer());
    waitForZmqMessages();
    QVERIFY_(serverRevicedMessage);
    QVERIFY_(false == clientReceivedMessage);

    serverRevicedMessage = false;
    clientReceivedMessage = false;
    server.sendMessage("StrataClient", "test message");
    waitForZmqMessages();
    QVERIFY_(false == serverRevicedMessage);
    QVERIFY_(false == clientReceivedMessage);

    serverRevicedMessage = false;
    clientReceivedMessage = false;
    QVERIFY_(client.connectServer());
    waitForZmqMessages();
    QVERIFY_(serverRevicedMessage);
    QVERIFY_(clientReceivedMessage);
}

void StrataClientTest::testBuildRequest()
{
    // some variables used for validation.
    bool serverRevicedMessage = false;
    QString expectedMethod = "";
    int expectedId = 0;

    strata::strataRPC::ServerConnector server(address_);
    server.initilizeConnector();
    connect(&server, &strata::strataRPC::ServerConnector::newMessageReceived, this,
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
    client.connectServer();
    waitForZmqMessages();
    QVERIFY_(serverRevicedMessage);

    expectedMethod = "method_1";
    expectedId = 2;
    serverRevicedMessage = false;
    {
        auto deferredRequest = client.sendRequest("method_1", {{"param_1", 0}});
        QVERIFY_(deferredRequest != nullptr);
        waitForZmqMessages();
        QVERIFY_(serverRevicedMessage);
    }

    expectedMethod = "method_2";
    expectedId = 3;
    serverRevicedMessage = false;
    {
        auto deferredRequest = client.sendRequest("method_2", {});
        QVERIFY_(deferredRequest != nullptr);
        waitForZmqMessages();
        QVERIFY_(serverRevicedMessage);
    }
}

void StrataClientTest::testNonDefaultDealerId()
{
    bool defaultIdRecieved = false;
    bool customIdRecieved = false;

    strata::strataRPC::ServerConnector server(address_);
    server.initilizeConnector();

    connect(
        &server, &strata::strataRPC::ServerConnector::newMessageReceived, this,
        [&defaultIdRecieved, &customIdRecieved](const QByteArray &clientId, const QByteArray &) {
            if (clientId == "customId") {
                customIdRecieved = true;
            } else if (clientId == "StrataClient") {
                defaultIdRecieved = true;
            }
        });

    StrataClient client_1(address_);
    client_1.connectServer();

    StrataClient client_2(address_, "customId");
    client_2.connectServer();

    waitForZmqMessages();
    QVERIFY_(defaultIdRecieved);
    QVERIFY_(customIdRecieved);
}

void StrataClientTest::testWithNoCallbacks()
{
    using Message = strata::strataRPC::Message;

    int zmqWaitTime = 50;
    bool noCallbackHandler = false;

    strata::strataRPC::ServerConnector server(address_);
    server.initilizeConnector();

    connect(
        &server, &strata::strataRPC::ServerConnector::newMessageReceived, this,
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
                           [&noCallbackHandler](const Message &) { noCallbackHandler = true; });

    client.connectServer();

    noCallbackHandler = false;
    client.sendRequest("test_no_callbacks", QJsonObject({{"response_type", "notification"}}));
    waitForZmqMessages(zmqWaitTime);
    QVERIFY_(noCallbackHandler);

    noCallbackHandler = false;
    client.sendRequest("test_no_callbacks", QJsonObject({{"response_type", "error"}}));
    waitForZmqMessages(zmqWaitTime);
    QVERIFY_(noCallbackHandler);

    noCallbackHandler = false;
    client.sendRequest("test_no_callbacks", QJsonObject({{"response_type", "result"}}));
    waitForZmqMessages(zmqWaitTime);
    QVERIFY_(noCallbackHandler);
}

void StrataClientTest::testWithAllCallbacks()
{
    using Message = strata::strataRPC::Message;
    using DeferredRequest = strata::strataRPC::DeferredRequest;

    int zmqWaitTime = 50;
    bool allCallbacksHandler = false;
    bool allCallbacksErrCallback = false;
    bool allCallbacksResCallback = false;

    strata::strataRPC::ServerConnector server(address_);
    server.initilizeConnector();

    connect(
        &server, &strata::strataRPC::ServerConnector::newMessageReceived, this,
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

    client.registerHandler("test_all_callbacks",
                           [&allCallbacksHandler](const Message &) { allCallbacksHandler = true; });

    client.connectServer();

    {
        allCallbacksErrCallback = false;
        allCallbacksResCallback = false;
        allCallbacksHandler = false;
        auto deferredRequest =
            client.sendRequest("test_all_callbacks", QJsonObject({{"response_type", "error"}}));

        QVERIFY_(deferredRequest != nullptr);

        connect(deferredRequest, &DeferredRequest::finishedSuccessfully, this,
                [&allCallbacksResCallback](const Message &) { allCallbacksResCallback = true; });
        connect(deferredRequest, &DeferredRequest::finishedWithError, this,
                [&allCallbacksErrCallback](const Message &) { allCallbacksErrCallback = true; });
        connect(deferredRequest, &DeferredRequest::requestTimedout, this,
                [](int) { QFAIL_("Request timed out."); });

        waitForZmqMessages(zmqWaitTime);
        QVERIFY_(allCallbacksErrCallback);
        QVERIFY_(false == allCallbacksResCallback);
        QVERIFY_(false == allCallbacksHandler);
    }

    {
        allCallbacksErrCallback = false;
        allCallbacksResCallback = false;
        allCallbacksHandler = false;
        auto deferredRequest =
            client.sendRequest("test_all_callbacks", QJsonObject({{"response_type", "result"}}));

        QVERIFY_(deferredRequest != nullptr);

        connect(deferredRequest, &DeferredRequest::finishedSuccessfully, this,
                [&allCallbacksResCallback](const Message &) { allCallbacksResCallback = true; });
        connect(deferredRequest, &DeferredRequest::finishedWithError, this,
                [&allCallbacksErrCallback](const Message &) { allCallbacksErrCallback = true; });
        connect(deferredRequest, &DeferredRequest::requestTimedout, this,
                [](int) { QFAIL_("Request timed out."); });

        waitForZmqMessages(zmqWaitTime);
        QVERIFY_(allCallbacksResCallback);
        QVERIFY_(false == allCallbacksErrCallback);
        QVERIFY_(false == allCallbacksHandler);
    }

    {
        allCallbacksErrCallback = false;
        allCallbacksResCallback = false;
        allCallbacksHandler = false;

        auto deferredRequest = client.sendRequest("test_all_callbacks",
                                                  QJsonObject({{"response_type", "notification"}}));

        QVERIFY_(deferredRequest != nullptr);

        connect(deferredRequest, &DeferredRequest::finishedSuccessfully, this,
                [&allCallbacksResCallback](const Message &) { allCallbacksResCallback = true; });
        connect(deferredRequest, &DeferredRequest::finishedWithError, this,
                [&allCallbacksErrCallback](const Message &) { allCallbacksErrCallback = true; });
        connect(deferredRequest, &DeferredRequest::requestTimedout, this,
                [](int) { QFAIL_("Request timed out."); });

        waitForZmqMessages(zmqWaitTime);
        QVERIFY_(false == allCallbacksResCallback);
        QVERIFY_(false == allCallbacksErrCallback);
        QVERIFY_(allCallbacksHandler);
    }
}

void StrataClientTest::testWithOnlyResultCallbacks()
{
    using Message = strata::strataRPC::Message;
    using DeferredRequest = strata::strataRPC::DeferredRequest;

    int zmqWaitTime = 50;
    bool resCallbackHandler = false;
    bool resCallback = false;

    strata::strataRPC::ServerConnector server(address_);
    server.initilizeConnector();

    connect(
        &server, &strata::strataRPC::ServerConnector::newMessageReceived, this,
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

    client.registerHandler("test_res_callback",
                           [&resCallbackHandler](const Message &) { resCallbackHandler = true; });

    client.connectServer();

    {
        resCallback = false;
        resCallbackHandler = false;
        auto deferredRequest =
            client.sendRequest("test_res_callback", QJsonObject({{"response_type", "result"}}));

        QVERIFY_(deferredRequest != nullptr);

        connect(deferredRequest, &DeferredRequest::finishedSuccessfully, this,
                [&resCallback](const Message &) { resCallback = true; });
        connect(deferredRequest, &DeferredRequest::requestTimedout, this,
                [](int) { QFAIL_("Request timed out."); });

        waitForZmqMessages(zmqWaitTime);
        QVERIFY_(resCallback);
        QVERIFY_(false == resCallbackHandler);
    }

    {
        resCallback = false;
        resCallbackHandler = false;
        auto deferredRequest =
            client.sendRequest("test_res_callback", QJsonObject({{"response_type", "error"}}));

        QVERIFY_(deferredRequest != nullptr);

        connect(deferredRequest, &DeferredRequest::finishedSuccessfully, this,
                [&resCallback](const Message &) { resCallback = true; });
        connect(deferredRequest, &DeferredRequest::requestTimedout, this,
                [](int) { QFAIL_("Request timed out."); });

        waitForZmqMessages(zmqWaitTime);
        QVERIFY_(false == resCallback);
        QVERIFY_(resCallbackHandler);
    }

    {
        resCallback = false;
        resCallbackHandler = false;
        auto deferredRequest = client.sendRequest("test_res_callback",
                                                  QJsonObject({{"response_type", "notification"}}));

        QVERIFY_(deferredRequest != nullptr);

        connect(deferredRequest, &DeferredRequest::finishedSuccessfully, this,
                [&resCallback](const Message &) { resCallback = true; });
        connect(deferredRequest, &DeferredRequest::requestTimedout, this,
                [](int) { QFAIL_("Request timed out."); });

        waitForZmqMessages(zmqWaitTime);
        QVERIFY_(false == resCallback);
        QVERIFY_(resCallbackHandler);
    }
}

void StrataClientTest::testWithOnlyErrorCallbacks()
{
    using Message = strata::strataRPC::Message;
    using DeferredRequest = strata::strataRPC::DeferredRequest;

    int zmqWaitTime = 50;
    bool errorCallbackHander = false;
    bool errorCallback = false;

    strata::strataRPC::ServerConnector server(address_);
    server.initilizeConnector();

    connect(
        &server, &strata::strataRPC::ServerConnector::newMessageReceived, this,
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

    client.registerHandler("test_err_callback",
                           [&errorCallbackHander](const Message &) { errorCallbackHander = true; });

    client.connectServer();

    {
        errorCallback = false;
        errorCallbackHander = false;
        auto deferredRequest =
            client.sendRequest("test_err_callback", QJsonObject({{"response_type", "result"}}));

        QVERIFY_(deferredRequest != nullptr);

        connect(deferredRequest, &DeferredRequest::finishedWithError, this,
                [&errorCallback](const Message &) { errorCallback = true; });
        connect(deferredRequest, &DeferredRequest::requestTimedout, this,
                [](int) { QFAIL_("Request timed out."); });

        waitForZmqMessages(zmqWaitTime);
        QVERIFY_(false == errorCallback);
        QVERIFY_(errorCallbackHander);
    }

    {
        errorCallback = false;
        errorCallbackHander = false;
        auto deferredRequest =
            client.sendRequest("test_err_callback", QJsonObject({{"response_type", "error"}}));

        QVERIFY_(deferredRequest != nullptr);

        connect(deferredRequest, &DeferredRequest::finishedWithError, this,
                [&errorCallback](const Message &) { errorCallback = true; });
        connect(deferredRequest, &DeferredRequest::requestTimedout, this,
                [](int) { QFAIL_("Request timed out."); });

        waitForZmqMessages(zmqWaitTime);
        QVERIFY_(errorCallback);
        QVERIFY_(false == errorCallbackHander);
    }

    {
        errorCallback = false;
        errorCallbackHander = false;
        auto deferredRequest = client.sendRequest("test_err_callback",
                                                  QJsonObject({{"response_type", "notification"}}));

        QVERIFY_(deferredRequest != nullptr);

        connect(deferredRequest, &DeferredRequest::finishedWithError, this,
                [&errorCallback](const Message &) { errorCallback = true; });
        connect(deferredRequest, &DeferredRequest::requestTimedout, this,
                [](int) { QFAIL_("Request timed out."); });

        waitForZmqMessages(zmqWaitTime);
        QVERIFY_(false == errorCallback);
        QVERIFY_(errorCallbackHander);
    }
}

void StrataClientTest::testTimedoutRequest()
{
    using DeferredRequest = strata::strataRPC::DeferredRequest;

    int testsNum = 10;
    int timedOutRequests = 0;

    strata::strataRPC::ServerConnector server(address_);
    server.initilizeConnector();

    StrataClient client(address_);
    client.connectServer();

    for (int i = 0; i < testsNum; i++) {
        auto deferredRequest = client.sendRequest("test_timeout_request", QJsonObject({{}}));
        QVERIFY_(deferredRequest != nullptr);
        connect(deferredRequest, &DeferredRequest::finishedWithError, this,
                [&timedOutRequests](const strata::strataRPC::Message &) { ++timedOutRequests; });
    }
    waitForZmqMessages(1000);
    QCOMPARE_(timedOutRequests, testsNum);
}

void StrataClientTest::testNoTimedoutRequest()
{
    using DeferredRequest = strata::strataRPC::DeferredRequest;
    using Message = strata::strataRPC::Message;
    int testsNum = 10;
    int timedOutRequests = 0;
    int successCallBacks = 0;

    strata::strataRPC::ServerConnector server(address_);

    connect(&server, &strata::strataRPC::ServerConnector::newMessageReceived, this,
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

    server.initilizeConnector();

    StrataClient client(address_);
    client.connectServer();

    for (int i = 0; i < testsNum; i++) {
        auto deferredRequest = client.sendRequest("test_timeout_request", QJsonObject({{}}));
        QVERIFY_(deferredRequest != nullptr);
        connect(deferredRequest, &DeferredRequest::finishedSuccessfully, this,
                [&successCallBacks](const Message &) { ++successCallBacks; });
        connect(deferredRequest, &DeferredRequest::requestTimedout, this,
                [&timedOutRequests](int) { ++timedOutRequests; });
    }

    waitForZmqMessages(1000);
    QCOMPARE_(timedOutRequests, 0);
    QCOMPARE_(successCallBacks, testsNum);
}

void StrataClientTest::testErrorOccourredSignal()
{
    qRegisterMetaType<StrataClient::ClientError>("StrataClient::ClientError");

    StrataClient client(address_);
    strata::strataRPC::ServerConnector server(address_);
    StrataClient::ClientError errorType;
    QSignalSpy errorOccurred(&client, &StrataClient::errorOccurred);

    client.registerHandler("handler_1", [](const strata::strataRPC::Message &) { return; });
    client.registerHandler("handler_1", [](const strata::strataRPC::Message &) { return; });
    QCOMPARE_(errorOccurred.count(), 1);
    errorType = qvariant_cast<StrataClient::ClientError>(errorOccurred.takeFirst().at(0));
    QCOMPARE_(errorType, StrataClient::ClientError::FailedToRegisterHandler);
    errorOccurred.clear();

    client.unregisterHandler("handler_2");
    QCOMPARE_(errorOccurred.count(), 1);
    errorType = qvariant_cast<StrataClient::ClientError>(errorOccurred.takeFirst().at(0));
    QCOMPARE_(errorType, StrataClient::ClientError::FailedToUnregisterHandler);
    errorOccurred.clear();

    client.disconnectServer();
    QCOMPARE_(errorOccurred.count(), 2);  // fail to send unregister & fail to disconnect.
    errorType = qvariant_cast<StrataClient::ClientError>(errorOccurred.at(0).at(0));
    QCOMPARE_(errorType, StrataClient::ClientError::FailedToSendRequest);
    errorType = qvariant_cast<StrataClient::ClientError>(errorOccurred.at(1).at(0));
    QCOMPARE_(errorType, StrataClient::ClientError::FailedToDisconnect);
    errorOccurred.clear();

    server.initilizeConnector();
    client.connectServer();
    client.connectServer();  // This should fail
    QCOMPARE_(errorOccurred.count(), 1);
    errorType = qvariant_cast<StrataClient::ClientError>(errorOccurred.takeFirst().at(0));
    QCOMPARE_(errorType, StrataClient::ClientError::FailedToConnect);
    errorOccurred.clear();

    waitForZmqMessages(500);  // wait for the register_client messages to be timed out.
    QCOMPARE_(errorOccurred.count(), 1);
    errorType = qvariant_cast<StrataClient::ClientError>(errorOccurred.takeFirst().at(0));
    QCOMPARE_(errorType, StrataClient::ClientError::RequestTimeout);
    errorOccurred.clear();

    server.sendMessage("StrataClient", "not Json message");
    server.sendMessage("StrataClient", R"({"cmd":"this-is-invalid-api})");
    waitForZmqMessages();
    QCOMPARE_(errorOccurred.count(), 4);
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
    waitForZmqMessages();
    QCOMPARE_(errorOccurred.count(), 2);
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
    waitForZmqMessages();
    QCOMPARE_(errorOccurred.count(), 1);
    errorType = qvariant_cast<StrataClient::ClientError>(errorOccurred.takeFirst().at(0));
    QCOMPARE_(errorType, StrataClient::ClientError::HandlerNotFound);
    errorOccurred.clear();
}
