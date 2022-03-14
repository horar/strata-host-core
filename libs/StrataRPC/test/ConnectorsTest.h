/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QCoreApplication>
#include <QEventLoop>
#include <QObject>

#include "ClientConnector.h"
#include "QtTest.h"
#include "ServerConnector.h"

class ConnectorsTest : public QObject
{
    Q_OBJECT

#ifdef false
private slots:
    void testOpenServerConnectorFaild();
    void testServerAndClient();
    void testMultipleClients();
    void testFloodTheServer();
    void testFloodTheClient();
    void testDisconnectClient();
    void testFailedToSendMessageFromClientConnector();
    void testFailedToSendMessageFromServerConnector();
    void testClientConnectorErrorSignals();

private:
    void waitForZmqMessages(int delay);
    static constexpr char address_[] = "tcp://127.0.0.1:5564";

#endif
};
