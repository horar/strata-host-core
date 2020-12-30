#pragma once

#include <QObject>

#include "../src/Message.h"
#include "../src/Dispatcher.h"
#include "QtTest.h"
#include "TestHandlers.h"

using strata::strataComm::Message;
using strata::strataComm::Dispatcher;

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
    QVector<Message> cm_;

signals:
    void disp(const Message &clientMessage);
};
