#pragma once

#include "QtTest.h"

#include <StrataRPC/StrataClient.h>
#include <QObject>

using strata::strataRPC::StrataClient;

class StrataClientBenchmark : public QObject
{
    Q_OBJECT;

private slots:
    void benchmarkLargeNumberOfHandlers();

private:
    static constexpr char address_[] = "tcp://127.0.0.1:5564";
};