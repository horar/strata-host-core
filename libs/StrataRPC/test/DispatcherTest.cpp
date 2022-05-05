/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include <QThread>

#include "DispatcherTest.h"

QTEST_MAIN(DispatcherTest)

void DispatcherTest::initTestCase()
{
    for (int i = 1; i < 6; ++i) {
        RpcRequest request;
        request.setClientId("mg");
        request.setId(i);
        request.setMethod(QString("handler_%1").arg(i));

        messageList_.push_back(request);
    }
}

void DispatcherTest::testRegisteringHandlers()
{
    Dispatcher<const RpcRequest &> dispatcher;

    QCOMPARE(dispatcher.registerHandler(
                  "handler_1", std::bind(&TestHandlers::handler_1, th_, std::placeholders::_1)),
              true);
    QCOMPARE(dispatcher.registerHandler(
                  "handler_1", std::bind(&TestHandlers::handler_1, th_, std::placeholders::_1)),
              false);
    QCOMPARE(dispatcher.registerHandler(
                  "handler_2", std::bind(&TestHandlers::handler_1, th_, std::placeholders::_1)),
              true);
    QCOMPARE(dispatcher.registerHandler(
                  "handler_1", std::bind(&TestHandlers::handler_2, th_, std::placeholders::_1)),
              false);
    QCOMPARE(dispatcher.registerHandler(
                  "handler_2", std::bind(&TestHandlers::handler_2, th_, std::placeholders::_1)),
              false);
    QCOMPARE(dispatcher.registerHandler(
                  "handler_3", std::bind(&TestHandlers::handler_3, th_, std::placeholders::_1)),
              true);
}

void DispatcherTest::testUregisterHandlers()
{
    Dispatcher<const RpcRequest &> dispatcher;

    QVERIFY(false == dispatcher.unregisterHandler("not_registered_handler"));

    QVERIFY(dispatcher.registerHandler("example_handler", [](const RpcRequest &) {}));
    QVERIFY(dispatcher.unregisterHandler("example_handler"));
    QVERIFY(false == dispatcher.unregisterHandler("example_handler"));
}

void DispatcherTest::testDispatchHandlers()
{
    Dispatcher<const RpcRequest &> dispatcher;

    QVERIFY(dispatcher.registerHandler(
        "handler_1", std::bind(&TestHandlers::handler_1, th_, std::placeholders::_1)));
    QVERIFY(dispatcher.registerHandler(
        "handler_2", std::bind(&TestHandlers::handler_2, th_, std::placeholders::_1)));
    QVERIFY(dispatcher.registerHandler(
        "handler_3", std::bind(&TestHandlers::handler_3, th_, std::placeholders::_1)));
    QVERIFY(dispatcher.registerHandler(
        "handler_4", std::bind(&TestHandlers::handler_4, th_, std::placeholders::_1)));

    QCOMPARE(dispatcher.dispatch(messageList_[0].method(), messageList_[0]), true);
    QCOMPARE(dispatcher.dispatch(messageList_[1].method(), messageList_[1]), true);
    QCOMPARE(dispatcher.dispatch(messageList_[2].method(), messageList_[2]), true);
    QCOMPARE(dispatcher.dispatch(messageList_[3].method(), messageList_[3]), true);
    QCOMPARE(dispatcher.dispatch(messageList_[4].method(), messageList_[4]), false);
    QCOMPARE(dispatcher.dispatch(messageList_[2].method(), messageList_[2]), true);
    QCOMPARE(dispatcher.dispatch(messageList_[4].method(), messageList_[4]), false);
    QCOMPARE(dispatcher.dispatch(messageList_[3].method(), messageList_[3]), true);
    QCOMPARE(dispatcher.dispatch(messageList_[0].method(), messageList_[0]), true);
}

void DispatcherTest::testLargeNumberOfHandlers()
{
    Dispatcher<const RpcRequest &> dispatcher;

    for (int i = 0; i < 1000; i++) {
        dispatcher.registerHandler(QString::number(i), [i](const RpcRequest &request) {
            QCOMPARE(request.method(), QString::number(i));
        });
    }

    for (int i = 0; i < 1000; i++) {
        RpcRequest request;
        request.setClientId("mg");
        request.setId(i);
        request.setMethod(QString::number(i));

        QCOMPARE(dispatcher.dispatch(QString::number(i), request), true);
    }
}

void DispatcherTest::testDifferentArgumentType()
{
    Dispatcher<const QJsonObject &> dispatcher;

    QVERIFY(dispatcher.registerHandler("test_handler_1", [](const QJsonObject &jsonPayload) {
        QCOMPARE(jsonPayload.value("value").toString(), "test");
    }));

    QCOMPARE(dispatcher.dispatch("test_handler_1", QJsonObject({{"value", "test"}})), true);
}

void DispatcherTest::testDispatchUsingSignals()
{
    Dispatcher<const RpcRequest &> *dispatcher = new Dispatcher<const RpcRequest &>;

    connect(this, &DispatcherTest::disp, this, [dispatcher](const RpcRequest &message) {
        QVERIFY(dispatcher->dispatch(message.method(), message));
    });

    dispatcher->registerHandler("test_handler_1", [](const RpcRequest &message) {
        QCOMPARE(message.method(), "test_handler_1");
    });

    dispatcher->registerHandler("test_handler_2", [](const RpcRequest &message) {
        QCOMPARE(message.method(), "test_handler_2");
    });

    RpcRequest request1;
    request1.setClientId("mg");
    request1.setId(1);
    request1.setMethod("test_handler_2");

    emit disp(request1);

    RpcRequest request2;
    request2.setClientId("mg");
    request2.setId(2);
    request2.setMethod("test_handler_1");

    emit disp(request2);

    delete dispatcher;
}
