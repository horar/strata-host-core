#pragma once

#include "QtTest.h"

#include <QObject>
#include <StrataServer.h>
#include <StrataClient.h>

using strata::strataComm::StrataServer;
using strata::strataComm::StrataClient;

class StrataClientServerIntegrationTest : public QObject {
    Q_OBJECT

private slots:
    void testCase_1();

private:
    static constexpr char address_[] = "tcp://127.0.0.1:5564";
    void waitForZmqMessages(int delay=100);
};