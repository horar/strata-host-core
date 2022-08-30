/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QObject>
#include <StrataRPC/RpcRequest.h>

#include "Dispatcher.h"
#include "QtTest.h"
#include "TestHandlers.h"

using strata::strataRPC::Dispatcher;

class DispatcherTest : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void testRegisteringHandlers();
    void testUregisterHandlers();
    void testDispatchHandlers();
    void testLargeNumberOfHandlers();
    void testDifferentArgumentType();
    void testDispatchUsingSignals();
private:
    TestHandlers th_;
    QVector<RpcRequest> messageList_;

signals:
    void disp(const RpcRequest &clientMessage);

};
