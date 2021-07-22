#pragma once

#include <StrataRPC/StrataServer.h>
#include <QObject>
#include <QtTest>

using strata::strataRPC::StrataServer;

class StrataServerBenchmark : public QObject
{
    Q_OBJECT;

private slots:
    void benchmarkLargeNumberOfHandlers();
    void benchmarkLargeNUmberOfClients();
    void benchmarkRegisteringClients();
    void benchmarkNotifyClientAPIv2();
    void benchmarkNotifyClientAPIv1();
    void benchmarkNotifyClientWithLargeNumberOfClients();

private:
    static constexpr char address_[] = "tcp://127.0.0.1:5564";
};
