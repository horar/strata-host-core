#pragma once

#include "QtTest.h"

#include <StrataClient.h>
#include <StrataServer.h>
#include <QObject>

using strata::strataComm::StrataClient;
using strata::strataComm::StrataServer;

class StrataClientServerIntegrationTest : public QObject
{
    Q_OBJECT

private slots:
    void testSingleClient();
    void testMultipleClients();

private:
    static constexpr char address_[] = "tcp://127.0.0.1:5564";
    void waitForZmqMessages(int delay = 100);
};