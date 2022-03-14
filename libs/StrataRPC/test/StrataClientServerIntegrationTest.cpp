/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "StrataClientServerIntegrationTest.h"

//using strata::strataRPC::Message;

QTEST_MAIN(StrataClientServerIntegrationTest)

#ifdef false
constexpr std::chrono::milliseconds check_timeout_interval = std::chrono::milliseconds(10);
constexpr std::chrono::milliseconds request_timeout = std::chrono::milliseconds(100);
constexpr int zmqWaitTimeSuccess = 250; // newarly always skipped, will never wait this long unless CPU is stalled
constexpr int zmqWaitTime = 50;         // will always wait this long checking for failures, etc

void StrataClientServerIntegrationTest::waitForZmqMessages(int delay)
{
    QTimer timer;
    timer.setSingleShot(true);
    timer.start(delay);
    do {
        QCoreApplication::processEvents(QEventLoop::WaitForMoreEvents);
    } while (timer.isActive());
}

void StrataClientServerIntegrationTest::testSingleClient()
{
    // variables to verify That handlers got executed.
    bool serverRecviedRegisterClient = false;
    bool serverRecievedUnregisterClient = false;
    bool serverReceivedExampleCommand1 = false;
    bool serverReceivedExampleCommand2 = false;
    bool serverReceivedErrorCommand = false;
    bool serverReceivedPlatformMessage = false;

    bool clientRecievedUnregisterClient = false;
    bool clientReceivedExampleCommand1 = false;
    bool clientReceivedExampleCommand2Response = false;
    bool clientReceivedExampleCommand2Notification = false;
    bool clientReceivedErrorCommand = false;
    bool clientReceivedPlatformMessage = false;
    bool clientReceivedPlatformNotification = false;
    bool clientReceivedServerNotification = false;

    StrataServer server(address_, false);
    StrataClient client(address_, "StrataClient", check_timeout_interval, request_timeout);

    // Server handlers
    server.registerHandler("register_client",
                           [&server, &serverRecviedRegisterClient](const Message &message) {
                               serverRecviedRegisterClient = true;
                               server.notifyClient(message, {{"handler_name", "register_client"}},
                                                   strata::strataRPC::ResponseType::Response);
                           });

    server.registerHandler(
        "unregister_client", [&server, &serverRecievedUnregisterClient](const Message &message) {
            serverRecievedUnregisterClient = true;
            server.notifyClient(message, {}, strata::strataRPC::ResponseType::Response);
        });

    server.registerHandler(
        "example_command_sends_response",
        [&server, &serverReceivedExampleCommand1](const Message &message) {
            serverReceivedExampleCommand1 = true;
            server.notifyClient(message,
                                {{"handler_name", "example_command_sends_response"}, {"test", 1}},
                                strata::strataRPC::ResponseType::Response);
        });

    server.registerHandler("example_command_sends_response_and_notification",
                           [&server, &serverReceivedExampleCommand2](const Message &message) {
                               serverReceivedExampleCommand2 = true;
                               server.notifyClient(message, {{"message_type", "response"}},
                                                   strata::strataRPC::ResponseType::Response);
                               server.notifyClient(message, {{"message_type", "notification"}},
                                                   strata::strataRPC::ResponseType::Notification);
                           });

    server.registerHandler("example_command_sends_error",
                           [&server, &serverReceivedErrorCommand](const Message &message) {
                               serverReceivedErrorCommand = true;
                               server.notifyClient(message, {{"message_type", "error"}},
                                                   strata::strataRPC::ResponseType::Error);
                           });

    server.registerHandler(
        "platform_message", [&server, &serverReceivedPlatformMessage](const Message &message) {
            serverReceivedPlatformMessage = true;
            server.notifyClient(message, {{"device_id", 100}, {"message", {}}},
                                strata::strataRPC::ResponseType::Notification);
            server.notifyClient(message, {{"device_id", 100}, {"message", {}}},
                                strata::strataRPC::ResponseType::PlatformMessage);
        });

    // Client Handlers
    QSignalSpy ClientConnectedSignalSpy(&client, &StrataClient::connected);
    QVERIFY(ClientConnectedSignalSpy.isValid());

    client.registerHandler("unregister_client", [&clientRecievedUnregisterClient](const QJsonObject &) {
        // This should not be called.
        clientRecievedUnregisterClient = true;
        QFAIL("Client already disconnected.");
    });

    client.registerHandler(
        "example_command_sends_response_and_notification",
        [&clientReceivedExampleCommand2Notification](const QJsonObject &payload) {
            QVERIFY(payload.value("message_type") == "notification");
            if (payload.value("message_type") == "notification") {
                clientReceivedExampleCommand2Notification = true;
            }
        });

    // verify messageType
    client.registerHandler("platform_message",
                           [&clientReceivedPlatformMessage](const QJsonObject &) {
                               clientReceivedPlatformMessage = true;
                           });

    client.registerHandler("platform_notification",
                           [&clientReceivedPlatformNotification](const QJsonObject &) {
                               clientReceivedPlatformNotification = true;
                           });

    client.registerHandler("server_notification",
                           [&clientReceivedServerNotification](const QJsonObject &) {
                               clientReceivedServerNotification = true;
                           });

    QSignalSpy serverInitialized(&server, &StrataServer::initialized);
    QVERIFY(serverInitialized.isValid());
    server.initialize();
    QVERIFY((serverInitialized.count() == 1) || (serverInitialized.wait(zmqWaitTimeSuccess) == true));

    QSignalSpy clientConnected(&client, &StrataClient::connected);
    QVERIFY(clientConnected.isValid());
    client.connect();
    QVERIFY((clientConnected.count() == 1) || (clientConnected.wait(zmqWaitTimeSuccess) == true));

    {
        auto deferredRequest =
            client.sendRequest("example_command_sends_response", {{"key", "value"}});
        QVERIFY(deferredRequest != nullptr);
        connect(deferredRequest, &strata::strataRPC::DeferredRequest::finishedSuccessfully, this,
                [&clientReceivedExampleCommand1](const QJsonObject &payload) {
                    clientReceivedExampleCommand1 = true;
                    QVERIFY(true == payload.contains("handler_name"));
                    QVERIFY(true == payload.value("handler_name").isString());
                    QCOMPARE(payload.value("handler_name").toString(),
                              "example_command_sends_response");
                });
    }
    {
        auto deferredRequest = client.sendRequest("example_command_sends_response_and_notification",
                                                  {{"key", "value"}});
        QVERIFY(deferredRequest != nullptr);
        connect(deferredRequest, &strata::strataRPC::DeferredRequest::finishedSuccessfully, this,
                [&clientReceivedExampleCommand2Response](const QJsonObject &payload) {
                    QVERIFY(payload.value("message_type") == "response");
                    if (payload.value("message_type") == "response") {
                        clientReceivedExampleCommand2Response = true;
                    }
                });
    }
    {
        auto deferredRequest =
            client.sendRequest("example_command_sends_error", {{"key", "value"}});
        QVERIFY(deferredRequest != nullptr);
        connect(deferredRequest, &strata::strataRPC::DeferredRequest::finishedWithError, this,
                [&clientReceivedErrorCommand](const QJsonObject &payload) {
                    clientReceivedErrorCommand = true;
                    QVERIFY(true == payload.contains("message_type"));
                    QVERIFY(true == payload.value("message_type").isString());
                    QCOMPARE(payload.value("message_type").toString(), "error");
                });
    }
    {
        auto deferredRequest = client.sendRequest(
            "platform_message", {{"device_id", 2020}, {"message", "json string!"}});
        QVERIFY(deferredRequest != nullptr);
    }

    server.notifyAllClients("server_notification", {{"list", "of platforms"}});

    QTRY_VERIFY_WITH_TIMEOUT(serverRecviedRegisterClient, zmqWaitTimeSuccess);
    QTRY_VERIFY_WITH_TIMEOUT(serverReceivedExampleCommand1, zmqWaitTimeSuccess);
    QTRY_VERIFY_WITH_TIMEOUT(serverReceivedExampleCommand2, zmqWaitTimeSuccess);
    QTRY_VERIFY_WITH_TIMEOUT(serverReceivedErrorCommand, zmqWaitTimeSuccess);
    QTRY_VERIFY_WITH_TIMEOUT(serverReceivedPlatformMessage, zmqWaitTimeSuccess);
    QVERIFY((ClientConnectedSignalSpy.count() == 1) || (ClientConnectedSignalSpy.wait(zmqWaitTimeSuccess) == true));
    QTRY_VERIFY_WITH_TIMEOUT(clientReceivedExampleCommand1, zmqWaitTimeSuccess);
    QTRY_VERIFY_WITH_TIMEOUT(clientReceivedExampleCommand2Response, zmqWaitTimeSuccess);
    QTRY_VERIFY_WITH_TIMEOUT(clientReceivedExampleCommand2Notification, zmqWaitTimeSuccess);
    QTRY_VERIFY_WITH_TIMEOUT(clientReceivedErrorCommand, zmqWaitTimeSuccess);
    QTRY_VERIFY_WITH_TIMEOUT(clientReceivedPlatformMessage, zmqWaitTimeSuccess);
    QTRY_VERIFY_WITH_TIMEOUT(clientReceivedPlatformNotification, zmqWaitTimeSuccess);
    QTRY_VERIFY_WITH_TIMEOUT(clientReceivedServerNotification, zmqWaitTimeSuccess);

    client.disconnect();

    QTRY_VERIFY_WITH_TIMEOUT(serverRecievedUnregisterClient, zmqWaitTimeSuccess);
    waitForZmqMessages(zmqWaitTime);
    QVERIFY(false == clientRecievedUnregisterClient);
}

void StrataClientServerIntegrationTest::testMultipleClients()
{
    bool serverRecievedClient1Register = false;
    bool serverRecievedClient2Register = false;
    bool client1ReceivedServerResponse = false;
    bool client1ReceivedServerBroadcast = false;
    bool client2ReceivedServerResponse = false;
    bool client2ReceivedServerBroadcast = false;

    StrataServer server(address_, false);
    StrataClient client_1(address_, "client_1", check_timeout_interval, request_timeout);
    StrataClient client_2(address_, "client_2", check_timeout_interval, request_timeout);

    QSignalSpy clientConnectedSignalSpy_1(&client_1, &StrataClient::connected);
    QSignalSpy clientConnectedSignalSpy_2(&client_2, &StrataClient::connected);
    QVERIFY(clientConnectedSignalSpy_1.isValid());
    QVERIFY(clientConnectedSignalSpy_2.isValid());

    server.registerHandler("register_client",
                           [&server, &serverRecievedClient1Register,
                            &serverRecievedClient2Register](const Message &message) {
                               if (message.clientID == "client_1") {
                                   serverRecievedClient1Register = true;
                                   server.notifyClient(message, {{"destination", "client_1"}},
                                                       strata::strataRPC::ResponseType::Response);
                               } else if (message.clientID == "client_2") {
                                   serverRecievedClient2Register = true;
                                   server.notifyClient(message, {{"destination", "client_2"}},
                                                       strata::strataRPC::ResponseType::Response);
                               }
                           });

    client_1.registerHandler(
        "register_client", [&client1ReceivedServerResponse](const QJsonObject &message) {
            if (message.contains("destination") && message["destination"] == "client_1") {
                client1ReceivedServerResponse = true;
            } else {
                QFAIL("Server responded to the wrong client");
            }
        });

    client_2.registerHandler(
        "register_client", [&client2ReceivedServerResponse](const QJsonObject &message) {
            if (message.contains("destination") && message["destination"] == "client_2") {
                client2ReceivedServerResponse = true;
            } else {
                QFAIL("Server responded to the wrong client");
            }
        });

    client_1.registerHandler("broadcasted_message",
                             [&client1ReceivedServerBroadcast](const QJsonObject &) {
                                 client1ReceivedServerBroadcast = true;
                             });

    client_2.registerHandler("broadcasted_message",
                             [&client2ReceivedServerBroadcast](const QJsonObject &) {
                                 client2ReceivedServerBroadcast = true;
                             });

    QSignalSpy serverInitialized(&server, &StrataServer::initialized);
    QVERIFY(serverInitialized.isValid());
    server.initialize();
    QVERIFY((serverInitialized.count() == 1) || (serverInitialized.wait(zmqWaitTimeSuccess) == true));

    client_1.connect();
    QTRY_VERIFY_WITH_TIMEOUT(serverRecievedClient1Register, zmqWaitTimeSuccess);
    QVERIFY((clientConnectedSignalSpy_1.count() == 1) || (clientConnectedSignalSpy_1.wait(zmqWaitTimeSuccess) == true));

    client_2.connect();
    QTRY_VERIFY_WITH_TIMEOUT(serverRecievedClient2Register, zmqWaitTimeSuccess);
    QVERIFY((clientConnectedSignalSpy_2.count() == 1) || (clientConnectedSignalSpy_2.wait(zmqWaitTimeSuccess) == true));

    server.notifyAllClients("broadcasted_message", {{"message", "message to all clients."}});

    QTRY_VERIFY_WITH_TIMEOUT(client1ReceivedServerBroadcast, zmqWaitTimeSuccess);
    QTRY_VERIFY_WITH_TIMEOUT(client2ReceivedServerBroadcast, zmqWaitTimeSuccess);
}

void StrataClientServerIntegrationTest::testCallbacks()
{
    StrataServer server(address_);
    StrataClient client(address_, "StrataClient", check_timeout_interval, request_timeout);

    server.registerHandler("test_error_callback", [&server](const Message &message) {
        server.notifyClient(message, QJsonObject{}, strata::strataRPC::ResponseType::Error);
    });

    server.registerHandler("test_result_callback", [&server](const Message &message) {
        server.notifyClient(message, QJsonObject{}, strata::strataRPC::ResponseType::Response);
    });

    QSignalSpy serverInitialized(&server, &strata::strataRPC::StrataServer::initialized);
    QVERIFY(serverInitialized.isValid());
    server.initialize();
    QVERIFY((serverInitialized.count() == 1) || (serverInitialized.wait(zmqWaitTimeSuccess) == true));

    QSignalSpy clientConnected(&client, &StrataClient::connected);
    QVERIFY(clientConnected.isValid());
    client.connect();
    QVERIFY((clientConnected.count() == 1) || (clientConnected.wait(zmqWaitTimeSuccess) == true));

    {
        auto deferredRequest = client.sendRequest("test_error_callback", QJsonObject{});
        QVERIFY(deferredRequest != nullptr);
        QSignalSpy finishedWithError(deferredRequest, &strata::strataRPC::DeferredRequest::finishedWithError);
        QVERIFY(finishedWithError.isValid());
        QVERIFY((finishedWithError.count() == 1) || (finishedWithError.wait(zmqWaitTimeSuccess) == true));
    }

    {
        auto deferredRequest = client.sendRequest("test_result_callback", QJsonObject{});
        QVERIFY(deferredRequest != nullptr);
        QSignalSpy finishedSuccessfully(deferredRequest, &strata::strataRPC::DeferredRequest::finishedSuccessfully);
        QVERIFY(finishedSuccessfully.isValid());
        QVERIFY((finishedSuccessfully.count() == 1) || (finishedSuccessfully.wait(zmqWaitTimeSuccess) == true));
    }
}
#endif
