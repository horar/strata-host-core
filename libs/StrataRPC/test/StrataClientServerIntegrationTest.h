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
    void testSingleClient();
    void testMultipleClients();
    void testCallbacks();

private:
    static constexpr char address_[] = "tcp://127.0.0.1:5564";
    void waitForZmqMessages(int delay = 100);
};