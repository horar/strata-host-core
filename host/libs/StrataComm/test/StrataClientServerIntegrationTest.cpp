#include "StrataClientServerIntegrationTest.h"

using strata::strataComm::ClientMessage;

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
                           [&server, &serverRecviedRegisterClient](const ClientMessage &cm) {
                               serverRecviedRegisterClient = true;
                               server.notifyClient(cm, {}, ClientMessage::ResponseType::Response);
                           });

    server.registerHandler("unregister",
                           [&server, &serverRecievedUnregisterClient](const ClientMessage &cm) {
                               serverRecievedUnregisterClient = true;
                               server.notifyClient(cm, {}, ClientMessage::ResponseType::Response);
                           });

    server.registerHandler(
        "example_command_sends_response",
        [&server, &serverReceivedExampleCommand1](const ClientMessage &cm) {
            serverReceivedExampleCommand1 = true;
            server.notifyClient(cm, {{"test", 1}}, ClientMessage::ResponseType::Response);
        });

    server.registerHandler("example_command_sends_response_and_notification",
                           [&server, &serverReceivedExampleCommand2](const ClientMessage &cm) {
                               serverReceivedExampleCommand2 = true;
                               server.notifyClient(cm, {{"message_type", "response"}},
                                                   ClientMessage::ResponseType::Response);
                               server.notifyClient(cm, {{"message_type", "notification"}},
                                                   ClientMessage::ResponseType::Notification);
                           });

    server.registerHandler("example_command_sends_error", [&server, &serverReceivedErrorCommand](
                                                              const ClientMessage &cm) {
        serverReceivedErrorCommand = true;
        server.notifyClient(cm, {{"test", 1}}, ClientMessage::ResponseType::Error);
    });

    server.registerHandler("platform_message",
                           [&server, &serverReceivedPlatformMessage](const ClientMessage &cm) {
                               serverReceivedPlatformMessage = true;
                               server.notifyClient(cm, {{"device_id", 100}, {"message", {}}},
                                                   ClientMessage::ResponseType::Notification);
                               server.notifyClient(cm, {{"device_id", 100}, {"message", {}}},
                                                   ClientMessage::ResponseType::PlatformMessage);
                           });

    // Client Handlers
    client.registerHandler("register_client",
                           [&client, &clientRecviedRegisterClient](const ClientMessage &cm) {
                               clientRecviedRegisterClient = true;
                               QCOMPARE_(cm.handlerName, "register_client");
                               QCOMPARE_(cm.messageType, ClientMessage::MessageType::Command);
                           });

    client.registerHandler("unregister",
                           [&client, &clientRecievedUnregisterClient](const ClientMessage &cm) {
                               // This should not be called.
                               clientRecievedUnregisterClient = true;
                               QFAIL_("Client already disconnected.");
                           });

    client.registerHandler("example_command_sends_response",
                           [&client, &clientReceivedExampleCommand1](const ClientMessage &cm) {
                               clientReceivedExampleCommand1 = true;
                               QCOMPARE_(cm.handlerName, "example_command_sends_response");
                               QCOMPARE_(cm.messageType, ClientMessage::MessageType::Command);
                           });

    client.registerHandler(
        "example_command_sends_response_and_notification",
        [&client, &clientReceivedExampleCommand2Notification,
         &clientReceivedExampleCommand2Response](const ClientMessage &cm) {
            // check once for the response and once for the notification
            QVERIFY_((cm.messageType == ClientMessage::MessageType::Command) ||
                     (cm.messageType == ClientMessage::MessageType::Notifiation));

            if (cm.messageType == ClientMessage::MessageType::Command) {
                clientReceivedExampleCommand2Response = true;
            } else if (cm.messageType == ClientMessage::MessageType::Notifiation) {
                clientReceivedExampleCommand2Notification = true;
            }
        });

    client.registerHandler("example_command_sends_error",
                           [&client, &clientReceivedErrorCommand](const ClientMessage &cm) {
                               clientReceivedErrorCommand = true;
                           });

    client.registerHandler("platform_message",
                           [&client, &clientReceivedPlatformMessage](const ClientMessage &) {
                               clientReceivedPlatformMessage = true;
                           });

    client.registerHandler("platform_notification",
                           [&client, &clientReceivedPlatformNotification](const ClientMessage &) {
                               clientReceivedPlatformNotification = true;
                           });

    client.registerHandler("server_notification",
                           [&client, &clientReceivedServerNotification](const ClientMessage &) {
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
                            &serverRecievedClient2Register](const ClientMessage &cm) {
                               if (cm.clientID == "client_1") {
                                   serverRecievedClient1Register = true;
                                   server.notifyClient(cm, {{"destination", "client_1"}},
                                                       ClientMessage::ResponseType::Response);
                               } else if (cm.clientID == "client_2") {
                                   serverRecievedClient2Register = true;
                                   server.notifyClient(cm, {{"destination", "client_2"}},
                                                       ClientMessage::ResponseType::Response);
                               }
                           });

    client_1.registerHandler(
        "register_client", [&client1ReceivedServerResponse](const ClientMessage &cm) {
            qDebug() << cm.payload;
            if (cm.payload.contains("destination") && cm.payload["destination"] == "client_1") {
                client1ReceivedServerResponse = true;
            } else {
                QFAIL_("Server responded to the wrong client");
            }
        });

    client_2.registerHandler(
        "register_client", [&client2ReceivedServerResponse](const ClientMessage &cm) {
            if (cm.payload.contains("destination") && cm.payload["destination"] == "client_2") {
                client2ReceivedServerResponse = true;
            } else {
                QFAIL_("Server responded to the wrong client");
            }
        });

    client_1.registerHandler("broadcasted_message",
                             [&client1ReceivedServerBroadcast](const ClientMessage &cm) {
                                 client1ReceivedServerBroadcast = true;
                             });

    client_2.registerHandler("broadcasted_message",
                             [&client2ReceivedServerBroadcast](const ClientMessage &cm) {
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
