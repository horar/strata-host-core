#pragma once

#include <QObject>

#include "QtTest.h"
#include <StrataServer.h>

using strata::strataComm::StrataServer;

class StrataServerTest : public QObject {
    Q_OBJECT

signals:
    void mockNewMessageRecived(const QByteArray &clientId, const QString &message);

private slots:
    void testParseClientMessage();
    void testValidApiVer2Message();
    void testValidApiVer1Message();
    void testFloodTheServer();
    void testBuildNotificationApiV2();



private:
    static constexpr char address_[] = "tcp://127.0.0.1:5564";
};
