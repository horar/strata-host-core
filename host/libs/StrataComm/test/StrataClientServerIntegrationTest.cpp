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

void StrataClientServerIntegrationTest::testCase_1() 
{

    // variables to verify That handlers got executed.
    bool serverRecviedRegisterClient = false;
    bool serverRecievedUnregisterClient = false;
    bool serverRecivedExampleCommand1 = false;
    bool serverRecivedExampleCommand2 = false;
    bool serverRecivedErrorCommand = false;
    bool serverRecivedPlatformMessage = false;

    bool clientRecviedRegisterClient = false;
    bool clientRecievedUnregisterClient = false;
    bool clientRecivedExampleCommand1 = false;
    bool clientRecivedExampleCommand2Response = false;
    bool clientRecivedExampleCommand2Notification = false;
    bool clientRecivedErrorCommand = false;
    bool clientRecivedPlatformMessage = false;
    bool clientRecivedPlatformNotification = false;
    bool clientRecivedServerNotification = false;

    // create the server and client
    StrataServer server(address_);
    StrataClient client(address_);

    // add server handlers:
    //      register client
    //      unregister client
    //      example command 1
    //      example command 2
    //      error producing command
    //      notification handler
    //      platform?

    server.registerHandler("register_client", [&server, &serverRecviedRegisterClient](const ClientMessage &cm) {
        serverRecviedRegisterClient = true;
        server.notifyClient(cm, {}, ClientMessage::ResponseType::Response);
    });

    server.registerHandler("unregister", [&server, &serverRecievedUnregisterClient](const ClientMessage &cm) {
        serverRecievedUnregisterClient = true;
        server.notifyClient(cm, {}, ClientMessage::ResponseType::Response);
    });

    server.registerHandler("example_command_sends_response", [&server, &serverRecivedExampleCommand1](const ClientMessage &cm) {
        serverRecivedExampleCommand1 = true;
        server.notifyClient(cm, {{"test", 1}}, ClientMessage::ResponseType::Response);
    });

    server.registerHandler("example_command_sends_response_and_notification", [&server, &serverRecivedExampleCommand2](const ClientMessage &cm) {
        serverRecivedExampleCommand2 = true;
        server.notifyClient(cm, {{"message_type", "response"}}, ClientMessage::ResponseType::Response);
        server.notifyClient(cm, {{"message_type", "notification"}}, ClientMessage::ResponseType::Notification);
    });

    server.registerHandler("example_command_sends_error", [&server, &serverRecivedErrorCommand](const ClientMessage &cm) {
        serverRecivedErrorCommand = true;
        server.notifyClient(cm, {{"test", 1}}, ClientMessage::ResponseType::Error);
    });

    server.registerHandler("platform_message", [&server, &serverRecivedPlatformMessage](const ClientMessage &cm) {
        serverRecivedPlatformMessage = true;
        // validate it?
        server.notifyClient(cm, {{"device_id",100}, {"message",{}}}, ClientMessage::ResponseType::Notification);
        server.notifyClient(cm, {{"device_id",100}, {"message",{}}}, ClientMessage::ResponseType::PlatformMessage);
    });

    // add client handlers
    client.registerHandler("register_client", [&client, &clientRecviedRegisterClient](const ClientMessage &cm) {
        clientRecviedRegisterClient = true;
        QCOMPARE_(cm.handlerName, "register_client");
        QCOMPARE_(cm.messageType, ClientMessage::MessageType::Command);
    });

    client.registerHandler("unregister", [&client, &clientRecievedUnregisterClient](const ClientMessage &cm) {
        // This should not be called.
        clientRecievedUnregisterClient = true;
        QFAIL_("Client already disconnected.");
    });

    client.registerHandler("example_command_sends_response", [&client, &clientRecivedExampleCommand1](const ClientMessage &cm) {
        //client.notifyClient(cm, {{"test", 1}}, ClientMessage::ResponseType::Response);
        // validate the response
        clientRecivedExampleCommand1 = true;
        QCOMPARE_(cm.handlerName, "example_command_sends_response");
        QCOMPARE_(cm.messageType, ClientMessage::MessageType::Command);
    });

    client.registerHandler("example_command_sends_response_and_notification", [&client, &clientRecivedExampleCommand2Notification, &clientRecivedExampleCommand2Response](const ClientMessage &cm) {
        // client.notifyClient(cm, {{"message_type", "response"}}, ClientMessage::ResponseType::Response);
        // client.notifyClient(cm, {{"message_type", "notification"}}, ClientMessage::ResponseType::Notification);

        // check once for the response and once for the notification
        QVERIFY_((cm.messageType == ClientMessage::MessageType::Command) || (cm.messageType == ClientMessage::MessageType::Notifiation));

        if(cm.messageType == ClientMessage::MessageType::Command) {
            clientRecivedExampleCommand2Response = true;
        } else if (cm.messageType == ClientMessage::MessageType::Notifiation) {
            clientRecivedExampleCommand2Notification = true;
        }
    });

    client.registerHandler("example_command_sends_error", [&client, &clientRecivedErrorCommand](const ClientMessage &cm) {
        // client.notifyClient(cm, {{"test", 1}}, ClientMessage::ResponseType::Error);
        // validate the error
        clientRecivedErrorCommand = true;
    });

    client.registerHandler("platform_message", [&client, &clientRecivedPlatformMessage](const ClientMessage &) {
        // validate the platform message.
        clientRecivedPlatformMessage = true;
    });

    client.registerHandler("platform_notification", [&client, &clientRecivedPlatformNotification](const ClientMessage &) {
        // validate the platform notification.
        clientRecivedPlatformNotification = true;
    });

    client.registerHandler("server_notification", [&client, &clientRecivedServerNotification](const ClientMessage &) {
        // validate the notification.
        clientRecivedServerNotification = true;
    });

    // start the server
    server.init();

    // start the client
    client.connectServer();
    waitForZmqMessages();

    // check if the server got "register_client"
    // check if the client got the response for "register_client" command

    // start sending messages!
    // need to send the following:
    //  1. command from client to server
    //  2. response from server to client
    //  3. notification from servrt to client
    //  4. Error from server to client
    //  5. platform messages?

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

    // disconnect client
    client.disconnectServer();
    waitForZmqMessages();

    // verify that the server got "unregister_client" command

    // test done
    QVERIFY_(serverRecviedRegisterClient);
    QVERIFY_(serverRecievedUnregisterClient);
    QVERIFY_(serverRecivedExampleCommand1);
    QVERIFY_(serverRecivedExampleCommand2);
    QVERIFY_(serverRecivedErrorCommand);
    QVERIFY_(serverRecivedPlatformMessage);

    QVERIFY_(clientRecviedRegisterClient);
    QVERIFY_(clientRecivedExampleCommand1);
    QVERIFY_(clientRecivedExampleCommand2Response);
    QVERIFY_(clientRecivedExampleCommand2Notification);
    QVERIFY_(clientRecivedErrorCommand);
    QVERIFY_(clientRecivedPlatformMessage);
    QVERIFY_(clientRecivedPlatformNotification);
    QVERIFY_(clientRecivedServerNotification);
    QVERIFY_(false == clientRecievedUnregisterClient);
}
