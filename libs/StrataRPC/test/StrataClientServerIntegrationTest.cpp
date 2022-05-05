/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "StrataClientServerIntegrationTest.h"

#include "StrataRPC/RpcRequest.h"

#include <QJsonObject>

using strata::strataRPC::RpcRequest;
using strata::strataRPC::DeferredReply;

QTEST_MAIN(StrataClientServerIntegrationTest)

constexpr std::chrono::milliseconds check_timeout_interval = std::chrono::milliseconds(10);
constexpr std::chrono::milliseconds request_timeout = std::chrono::milliseconds(100);
constexpr int zmqWaitTimeSuccess = 250; // newarly always skipped, will never wait this long unless CPU is stalled
constexpr int zmqWaitTime = 50;         // will always wait this long checking for failures, etc


void StrataClientServerIntegrationTest::init()
{
    server = new StrataServer(address_, this);
    client1 = new StrataClient(address_, "StrataClient1", check_timeout_interval, request_timeout, this);

    QSignalSpy initializedSpy(server, &StrataServer::initialized);
    QVERIFY(initializedSpy.isValid());
    server->initialize();
    QVERIFY((initializedSpy.count() == 1) || initializedSpy.wait(zmqWaitTimeSuccess));

    QSignalSpy connectedSpy(client1, &StrataClient::connected);
    QVERIFY(connectedSpy.isValid());
    client1->initializeAndConnect();
    QVERIFY(connectedSpy.count() == 1 || connectedSpy.wait(zmqWaitTimeSuccess));
}

void StrataClientServerIntegrationTest::cleanup()
{
    QSignalSpy disconnectSpy(client1, &StrataClient::disconnected);
    QVERIFY(disconnectSpy.isValid());

    client1->disconnect();
    QVERIFY(disconnectSpy.count() == 1 || disconnectSpy.wait(zmqWaitTimeSuccess));

    server->deleteLater();
    client1->deleteLater();
}

void StrataClientServerIntegrationTest::initTestCase()
{
    qRegisterMetaType<strata::strataRPC::RpcErrorCode>("RpcErrorCode");
}

void StrataClientServerIntegrationTest::cleanupTestCase()
{
}

void StrataClientServerIntegrationTest::testUnregisteredClient()
{
    DeferredReply *reply = client1->sendRequest("some_method", {{}});
    QVERIFY(reply != nullptr);

    QSignalSpy errorSpy(reply, &DeferredReply::finishedWithError);
    QVERIFY(errorSpy.isValid());
    QVERIFY(errorSpy.count() == 1 || errorSpy.wait(zmqWaitTimeSuccess));

    QJsonObject errorObject = errorSpy.takeFirst().at(0).toJsonObject();
    QVERIFY(errorObject.value("code").toInt() == strata::strataRPC::ClientNotRegistered);
}

void StrataClientServerIntegrationTest::testTimeoutRequest()
{

    server->registerHandler(
        "ping",
        [](const RpcRequest &) {
        //request received, but do nothing
        });

    //client registration
    callRegisterClient(client1);


    DeferredReply *reply = client1->sendRequest("ping", {{}});
    QVERIFY(reply != nullptr);

    QSignalSpy errorSpy(reply, &DeferredReply::finishedWithError);
    QVERIFY(errorSpy.isValid());
    QVERIFY(errorSpy.count() == 1 || errorSpy.wait(zmqWaitTimeSuccess));

    QJsonObject errorObject = errorSpy.takeFirst().at(0).toJsonObject();
    QVERIFY(errorObject.value("code").toInt() == strata::strataRPC::ReplyTimeoutError);

}

void StrataClientServerIntegrationTest::testClientRegistration()
{
    server->registerHandler(
        "ping",
        [this](const RpcRequest &request) {
        server->sendReply(request.clientId(), request.id(), {{}});
        });

    //client registration
    callRegisterClient(client1);

    //known procedure
    {
        DeferredReply *reply = client1->sendRequest("ping", {});
        QVERIFY(reply != nullptr);

        QSignalSpy successSpy(reply, &DeferredReply::finishedSuccessfully);
        QVERIFY(successSpy.isValid());
        QVERIFY(successSpy.count() == 1 || successSpy.wait(zmqWaitTimeSuccess));
    }


    //unknown procedure
    {
        DeferredReply *reply = client1->sendRequest("some_method", {{}});
        QVERIFY(reply != nullptr);

        QSignalSpy errorSpy(reply, &DeferredReply::finishedWithError);
        QVERIFY(errorSpy.isValid());
        QVERIFY(errorSpy.count() == 1 || errorSpy.wait(zmqWaitTimeSuccess));

        QJsonObject errorObject = errorSpy.takeFirst().at(0).toJsonObject();
        QVERIFY(errorObject.value("code").toInt() == strata::strataRPC::MethodNotFoundError);
    }

    //client unregistration
    callUnregisterClient(client1);

    //some procedure
    {
        DeferredReply *reply = client1->sendRequest("some_method", {{}});
        QVERIFY(reply != nullptr);

        QSignalSpy errorSpy(reply, &DeferredReply::finishedWithError);
        QVERIFY(errorSpy.isValid());
        QVERIFY(errorSpy.count() == 1 || errorSpy.wait(zmqWaitTimeSuccess));

        QJsonObject errorObject = errorSpy.takeFirst().at(0).toJsonObject();
        QVERIFY(errorObject.value("code").toInt() == strata::strataRPC::ClientNotRegistered);
    }
}

void StrataClientServerIntegrationTest::testNotification()
{
    bool notificationReceived = false;

    server->registerHandler(
                "ask_for_notification",
                [this](const RpcRequest &request) {

        QTimer::singleShot(std::chrono::milliseconds(1), this, [request, this](){
            server->sendNotification(request.clientId(),"test_notification", {{"test","test"}});
        });
    });

    client1->registerHandler(
                "test_notification",
                [&notificationReceived](const QJsonObject &){
        notificationReceived = true;
    });

    //client registration
    callRegisterClient(client1);

    //ask for notification with notification
    client1->sendNotification("ask_for_notification", {});

    //wait for notification
    waitForMessages(zmqWaitTimeSuccess);

    QVERIFY(notificationReceived);
}

void StrataClientServerIntegrationTest::testBroadcastToAll()
{
    //second client
    StrataClient *client2 = new StrataClient(address_, "StrataClient2", check_timeout_interval, request_timeout, this);
    QSignalSpy connectedSpy(client2, &StrataClient::connected);
    QVERIFY(connectedSpy.isValid());
    client2->initializeAndConnect();
    QVERIFY(connectedSpy.count() == 1 || connectedSpy.wait(zmqWaitTimeSuccess));


    bool notification1Received = false;
    bool notification2Received = false;

    client1->registerHandler(
                "test_notification",
                [&notification1Received](const QJsonObject &){
        notification1Received = true;
    });

    client2->registerHandler(
                "test_notification",
                [&notification2Received](const QJsonObject &){
        notification2Received = true;
    });

    //client registration
    callRegisterClient(client1);
    callRegisterClient(client2);

    //broadcast to all clients
    server->broadcastNotification("test_notification", {{}});

    //wait for notification
    waitForMessages(zmqWaitTimeSuccess);

    qDebug() << notification1Received << notification2Received;

    QVERIFY(notification1Received && notification2Received);
}

void StrataClientServerIntegrationTest::waitForMessages(int delay)
{
    QTimer timer;
    timer.setSingleShot(true);
    timer.start(delay);
    do {
        QCoreApplication::processEvents(QEventLoop::WaitForMoreEvents);
    } while (timer.isActive());
}

void StrataClientServerIntegrationTest::callRegisterClient(StrataClient *client)
{
    DeferredReply *reply = client->sendRequest("register_client", {{"api_version","2.0"}});
    QVERIFY(reply != nullptr);

    QSignalSpy successSpy(reply, &DeferredReply::finishedSuccessfully);
    QVERIFY(successSpy.isValid());
    QVERIFY(successSpy.count() == 1 || successSpy.wait(zmqWaitTimeSuccess));
}

void StrataClientServerIntegrationTest::callUnregisterClient(StrataClient *client)
{
    DeferredReply *reply = client->sendRequest("unregister_client", {});
    QVERIFY(reply != nullptr);

    QSignalSpy successSpy(reply, &DeferredReply::finishedSuccessfully);
    QVERIFY(successSpy.isValid());
    QVERIFY(successSpy.count() == 1 || successSpy.wait(zmqWaitTimeSuccess));
}
