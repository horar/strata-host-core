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
    void testUsingCallbacks();

private:
    void waitForZmqMessages(int delay = 100);
    static constexpr char address_[] = "tcp://127.0.0.1:5564";
};