#pragma once

#include <StrataRPC/StrataClient.h>
#include <QObject>
#include <QtTest>

using strata::strataRPC::StrataClient;

class StrataClientBenchmark : public QObject
{
    Q_OBJECT;

private slots:
    void benchmarkLargeNumberOfHandlers();
    void benchmarkSendRequest();
    void benchmarkSendNotification();

private:
    static constexpr char address_[] = "tcp://127.0.0.1:5564";
};