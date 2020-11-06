#pragma once

#include <QObject>
#include "../src/Dispatcher.h"
#include "../src/ClientMessage.h"
#include "TestHandlers.h"
#include "QtTest.h"

using strata::strataComm::Dispatcher;
using strata::strataComm::ClientMessage;

class DispatcherTest : public QObject
{
    Q_OBJECT
public:
    DispatcherTest();

private slots:
    void testFunction1();
    void testFunction2();
    void testRegisteringHandlers();
    void testDispatchHandlers();
    void testDispatchHandlers_2();
    void testDispatchHandlers_3();
//    void testDispatchHandlers_4();
    void testDispatchHandlers_5();

    void testLargeNumberOfHandlers();
    void testLargeNumberOfHandlers_1();


private:
    TestHandlers th_;
    QVector<ClientMessage> cm_;

signals:
    void disp(const ClientMessage &clientMessage);
};

