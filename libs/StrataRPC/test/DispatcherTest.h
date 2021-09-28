/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QObject>
#include <StrataRPC/Message.h>

#include "Dispatcher.h"
#include "QtTest.h"
#include "TestHandlers.h"

using strata::strataRPC::Dispatcher;
using strata::strataRPC::Message;

class DispatcherTest : public QObject
{
    Q_OBJECT
public:
    DispatcherTest();

private slots:
    void testRegisteringHandlers();
    void testUregisterHandlers();
    void testDispatchHandlers();
    void testLargeNumberOfHandlers();
    void testDifferentArgumentType();
    void testDispatchUsingSignals();
private:
    TestHandlers th_;
    QVector<Message> messageList_;

signals:
    void disp(const Message &clientMessage);
};
