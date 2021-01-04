#pragma once

#include <QObject>

#include "../src/Dispatcher.h"
#include "../src/Message.h"
#include "QtTest.h"
#include "TestHandlers.h"

using strata::strataComm::Dispatcher;
using strata::strataComm::Message;

class DispatcherTest : public QObject
{
    Q_OBJECT
public:
    DispatcherTest();

private slots:
    void testStartDispatcher();
    void testStopDispatcher();
    void testRegisteringHandlers();
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
