#pragma once

#include <QObject>

#include "../src/ClientMessage.h"
#include "../src/Dispatcher.h"
#include "QtTest.h"
#include "TestHandlers.h"

using strata::strataComm::ClientMessage;
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
    void testDispatchHandlersLocalClientMessage();

    void testLargeNumberOfHandlers();
    void testLargeNumberOfHandlersUsingDispatcherThread();

private:
    TestHandlers th_;
    QVector<ClientMessage> cm_;

signals:
    void disp(const ClientMessage &clientMessage);
};
