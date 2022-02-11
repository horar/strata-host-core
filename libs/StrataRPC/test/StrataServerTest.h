/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include "QtTest.h"

#include <StrataRPC/StrataServer.h>
#include <QObject>

using strata::strataRPC::StrataServer;

class StrataServerTest : public QObject
{
    Q_OBJECT

signals:
    void mockNewMessageReceived(const QByteArray &clientId, const QByteArray &message);

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
    void testdefaultHandlers();
    void testErrorOccourredSignal();

private:
    static constexpr char address_[] = "tcp://127.0.0.1:5564";
    void waitForZmqMessages(int delay);
};
