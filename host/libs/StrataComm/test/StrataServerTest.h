#pragma once

#include "QtTest.h"

#include <StrataServer.h>
#include <QObject>

using strata::strataComm::StrataServer;

class StrataServerTest : public QObject
{
    Q_OBJECT

signals:
    void mockNewMessageRecived(const QByteArray &clientId, const QByteArray &message);

private slots:
    void testValidApiVer2Message();
    void testBuildNotificationApiV2();
    void testBuildResponseApiV2();
    void testBuildErrorApiV2();
    void testBuildPlatformMessageApiV2();

    void testValidApiVer1Message();
    void testParsePlatformMessageAPIv1();
    void testBuildNotificationApiV1();
    void testBuildResponseApiV1();
    void testBuildPlatformMessageApiV1();

    void testFloodTheServer();
    void testServerFunctionality();
    void testNotifyAllClients();
    void testNotifyClientByClientId();
    void testNotifyClientToNonExistingClient();

    void testInitializeServerFail();

private:
    static constexpr char address_[] = "tcp://127.0.0.1:5564";
    void waitForZmqMessages(int delay=100);
};
