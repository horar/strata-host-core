/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
