#pragma once

#include "QtTest.h"

#include <StrataRPC/StrataServer.h>
#include <QObject>

using strata::strataRPC::StrataServer;

class StrataServerBenchmark : public QObject
{
    Q_OBJECT;

private slots:
    void benchmarkLargeNumberOfHandlers();

private:
    static constexpr char address_[] = "tcp://127.0.0.1:5564";
};