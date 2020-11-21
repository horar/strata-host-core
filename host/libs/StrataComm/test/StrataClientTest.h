#pragma once

#include "QtTest.h"

#include <QObject>
#include <StrataClient.h>

using strata::strataComm::StrataClient;

class StrataClientTest : public QObject {
    Q_OBJECT

private slots:
    void testRegisterAndUnregisterHandlers();
    void testConnectDisconnectToTheServer();

private:
    static constexpr char address_[] = "tcp://127.0.0.1:5564";
};