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
    void testDispatchHandlersUsingSignal();
    void testDispatchHandlersInDispatcherThread();
    void testDispatchHandlersLocalMessage();
    void testLargeNumberOfHandlers();
    void testLargeNumberOfHandlersUsingDispatcherThread();

private:
    TestHandlers th_;
    QVector<Message> messageList_;

signals:
    void disp(const Message &clientMessage);
};
