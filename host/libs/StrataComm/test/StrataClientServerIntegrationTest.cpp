#include "StrataClientServerIntegrationTest.h"

using strata::strataComm::Message;

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

    bool clientRecviedRegisterClient = false;
    bool clientRecievedUnregisterClient = false;
    bool clientReceivedExampleCommand1 = false;
    bool clientReceivedExampleCommand2Response = false;
    bool clientReceivedExampleCommand2Notification = false;
    bool clientReceivedErrorCommand = false;
    bool clientReceivedPlatformMessage = false;
    bool clientReceivedPlatformNotification = false;
    bool clientReceivedServerNotification = false;

    StrataServer server(address_);
    StrataClient client(address_);

    // Server handlers
    server.registerHandler("register_client",
                           [&server, &serverRecviedRegisterClient](const Message &cm) {
                               serverRecviedRegisterClient = true;
                               server.notifyClient(cm, {}, strata::strataComm::ResponseType::Response);
                           });

    server.registerHandler("unregister",
                           [&server, &serverRecievedUnregisterClient](const Message &cm) {
                               serverRecievedUnregisterClient = true;
                               server.notifyClient(cm, {}, strata::strataComm::ResponseType::Response);
                           });

    server.registerHandler(
        "example_command_sends_response",
        [&server, &serverReceivedExampleCommand1](const Message &cm) {
            serverReceivedExampleCommand1 = true;
            server.notifyClient(cm, {{"test", 1}}, strata::strataComm::ResponseType::Response);
        });

    server.registerHandler("example_command_sends_response_and_notification",
                           [&server, &serverReceivedExampleCommand2](const Message &cm) {
                               serverReceivedExampleCommand2 = true;
                               server.notifyClient(cm, {{"message_type", "response"}},
                                                   strata::strataComm::ResponseType::Response);
                               server.notifyClient(cm, {{"message_type", "notification"}},
                                                   strata::strataComm::ResponseType::Notification);
                           });

    server.registerHandler("example_command_sends_error", [&server, &serverReceivedErrorCommand](
                                                              const Message &cm) {
        serverReceivedErrorCommand = true;
        server.notifyClient(cm, {{"test", 1}}, strata::strataComm::ResponseType::Error);
    });

    server.registerHandler("platform_message",
                           [&server, &serverReceivedPlatformMessage](const Message &cm) {
                               serverReceivedPlatformMessage = true;
                               server.notifyClient(cm, {{"device_id", 100}, {"message", {}}},
                                                   strata::strataComm::ResponseType::Notification);
                               server.notifyClient(cm, {{"device_id", 100}, {"message", {}}},
                                                   strata::strataComm::ResponseType::PlatformMessage);
                           });

    // Client Handlers
    client.registerHandler("register_client",
                           [&client, &clientRecviedRegisterClient](const Message &cm) {
                               clientRecviedRegisterClient = true;
                               QCOMPARE_(cm.handlerName, "register_client");
                               QCOMPARE_(cm.messageType, strata::strataComm::MessageType::Command);
                           });

    client.registerHandler("unregister",
                           [&client, &clientRecievedUnregisterClient](const Message &cm) {
                               // This should not be called.
                               clientRecievedUnregisterClient = true;
                               QFAIL_("Client already disconnected.");
                           });

    client.registerHandler("example_command_sends_response",
                           [&client, &clientReceivedExampleCommand1](const Message &cm) {
                               clientReceivedExampleCommand1 = true;
                               QCOMPARE_(cm.handlerName, "example_command_sends_response");
                               QCOMPARE_(cm.messageType, strata::strataComm::MessageType::Command);
                           });

    client.registerHandler(
        "example_command_sends_response_and_notification",
        [&client, &clientReceivedExampleCommand2Notification,
         &clientReceivedExampleCommand2Response](const Message &cm) {
            // check once for the response and once for the notification
            QVERIFY_((cm.messageType == strata::strataComm::MessageType::Command) ||
                     (cm.messageType == strata::strataComm::MessageType::Notifiation));

            if (cm.messageType == strata::strataComm::MessageType::Command) {
                clientReceivedExampleCommand2Response = true;
            } else if (cm.messageType == strata::strataComm::MessageType::Notifiation) {
                clientReceivedExampleCommand2Notification = true;
            }
        });

    client.registerHandler("example_command_sends_error",
                           [&client, &clientReceivedErrorCommand](const Message &cm) {
                               clientReceivedErrorCommand = true;
                           });

    client.registerHandler("platform_message",
                           [&client, &clientReceivedPlatformMessage](const Message &) {
                               clientReceivedPlatformMessage = true;
                           });

    client.registerHandler("platform_notification",
                           [&client, &clientReceivedPlatformNotification](const Message &) {
                               clientReceivedPlatformNotification = true;
                           });

    client.registerHandler("server_notification",
                           [&client, &clientReceivedServerNotification](const Message &) {
                               clientReceivedServerNotification = true;
                           });

    server.init();
    client.connectServer();
    waitForZmqMessages();

    client.sendRequest("example_command_sends_response", {{"key", "value"}});
    waitForZmqMessages();

    client.sendRequest("example_command_sends_response_and_notification", {{"key", "value"}});
    waitForZmqMessages();

    client.sendRequest("example_command_sends_error", {{"key", "value"}});
    waitForZmqMessages();

    client.sendRequest("platform_message", {{"device_id", 2020}, {"message", "json string!"}});
    waitForZmqMessages();

    server.notifyAllClients("server_notification", {{"list", "of platforms"}});
    waitForZmqMessages();

    client.disconnectServer();
    waitForZmqMessages();

    QVERIFY_(serverRecviedRegisterClient);
    QVERIFY_(serverRecievedUnregisterClient);
    QVERIFY_(serverReceivedExampleCommand1);
    QVERIFY_(serverReceivedExampleCommand2);
    QVERIFY_(serverReceivedErrorCommand);
    QVERIFY_(serverReceivedPlatformMessage);

    QVERIFY_(clientRecviedRegisterClient);
    QVERIFY_(clientReceivedExampleCommand1);
    QVERIFY_(clientReceivedExampleCommand2Response);
    QVERIFY_(clientReceivedExampleCommand2Notification);
    QVERIFY_(clientReceivedErrorCommand);
    QVERIFY_(clientReceivedPlatformMessage);
    QVERIFY_(clientReceivedPlatformNotification);
    QVERIFY_(clientReceivedServerNotification);
    QVERIFY_(false == clientRecievedUnregisterClient);
}

void StrataClientServerIntegrationTest::testMultipleClients()
{
    bool serverRecievedClient1Register = false;
    bool serverRecievedClient2Register = false;
    bool client1ReceivedServerResponse = false;
    bool client1ReceivedServerBroadcast = false;
    bool client2ReceivedServerResponse = false;
    bool client2ReceivedServerBroadcast = false;

    StrataServer server(address_);
    StrataClient client_1(address_, "client_1");
    StrataClient client_2(address_, "client_2");

    server.registerHandler("register_client",
                           [&server, &serverRecievedClient1Register,
                            &serverRecievedClient2Register](const Message &cm) {
                               if (cm.clientID == "client_1") {
                                   serverRecievedClient1Register = true;
                                   server.notifyClient(cm, {{"destination", "client_1"}},
                                                       strata::strataComm::ResponseType::Response);
                               } else if (cm.clientID == "client_2") {
                                   serverRecievedClient2Register = true;
                                   server.notifyClient(cm, {{"destination", "client_2"}},
                                                       strata::strataComm::ResponseType::Response);
                               }
                           });

    client_1.registerHandler(
        "register_client", [&client1ReceivedServerResponse](const Message &cm) {
            qDebug() << cm.payload;
            if (cm.payload.contains("destination") && cm.payload["destination"] == "client_1") {
                client1ReceivedServerResponse = true;
            } else {
                QFAIL_("Server responded to the wrong client");
            }
        });

    client_2.registerHandler(
        "register_client", [&client2ReceivedServerResponse](const Message &cm) {
            if (cm.payload.contains("destination") && cm.payload["destination"] == "client_2") {
                client2ReceivedServerResponse = true;
            } else {
                QFAIL_("Server responded to the wrong client");
            }
        });

    client_1.registerHandler("broadcasted_message",
                             [&client1ReceivedServerBroadcast](const Message &cm) {
                                 client1ReceivedServerBroadcast = true;
                             });

    client_2.registerHandler("broadcasted_message",
                             [&client2ReceivedServerBroadcast](const Message &cm) {
                                 client2ReceivedServerBroadcast = true;
                             });

    server.init();
    client_1.connectServer();
    client_2.connectServer();
    waitForZmqMessages();

    QVERIFY_(serverRecievedClient1Register);
    QVERIFY_(serverRecievedClient2Register);
    QVERIFY_(client1ReceivedServerResponse);
    QVERIFY_(client2ReceivedServerResponse);

    server.notifyAllClients("broadcasted_message", {{"message", "message to all clients."}});
    waitForZmqMessages();

    QVERIFY_(client1ReceivedServerBroadcast);
    QVERIFY_(client2ReceivedServerBroadcast);
}
