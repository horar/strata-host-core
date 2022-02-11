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

#include <StrataRPC/StrataClient.h>
#include <QObject>

using strata::strataRPC::StrataClient;

class StrataClientTest : public QObject
{
    Q_OBJECT

private slots:
    void testRegisterAndUnregisterHandlers();
    void testConnectDisconnectToTheServer();
    void testBuildRequest();
    void testNonDefaultDealerId();
    void testWithNoCallbacks();
    void testWithAllCallbacks();
    void testWithOnlyResultCallbacks();
    void testWithOnlyErrorCallbacks();
    void testTimedoutRequest();
    void testNoTimedoutRequest();
    void testErrorOccourredSignal();
    void testSendNotification();

private:
    void waitForZmqMessages(int delay);
    static constexpr char address_[] = "tcp://127.0.0.1:5564";
};
