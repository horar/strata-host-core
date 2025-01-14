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
#include <StrataRPC/StrataServer.h>
#include <QObject>

using strata::strataRPC::StrataClient;
using strata::strataRPC::StrataServer;

class StrataClientServerIntegrationTest : public QObject
{
    Q_OBJECT

private slots:

    void init();
    void cleanup();
    void initTestCase();
    void cleanupTestCase();


    void testUnregisteredClient();
    void testTimeoutRequest();
    void testClientRegistration();
    void testNotification();
    void testBroadcastToAll();

private:
    static constexpr char address_[] = "tcp://127.0.0.1:5564";
    void waitForMessages(int delay);

    StrataServer *server;
    StrataClient *client1;

    void callRegisterClient(StrataClient *client);
    void callUnregisterClient(strata::strataRPC::StrataClient *client);
};
