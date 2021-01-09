#pragma once

#include <QCoreApplication>
#include <QEventLoop>
#include <QObject>

#include "ClientConnector.h"
#include "ServerConnector.h"
#include "QtTest.h"

class ConnectorsTest : public QObject
{
    Q_OBJECT

private slots:
    void testOpenServerConnectorFaild();
    void testServerAndClient();
    void testMultipleClients();
    void testFloodTheServer();
    void testFloodTheClient();
    void testDisconnectClient();
    void testFailedToSendMessageFromClientConnector();
    void testFailedToSendMessageFromServerConnector();

private:
    void waitForZmqMessages(int delay = 100);
    static constexpr char address_[] = "tcp://127.0.0.1:5564";
};
