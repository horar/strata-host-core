#pragma once

#include "QtTest.h"

#include <QObject>
#include <StrataServer.h>

using strata::strataComm::StrataServer;

class StrataServerTest : public QObject {
    Q_OBJECT

signals:
    void mockNewMessageRecived(const QByteArray &clientId, const QByteArray &message);

private slots:
    void testValidApiVer2Message();
    void testValidApiVer1Message();
    void testFloodTheServer();
    void testBuildNotificationApiV2();
    void testServerFunctionality();
    void testBuildPlatformMessageV1();

private:
    static constexpr char address_[] = "tcp://127.0.0.1:5564";
};
