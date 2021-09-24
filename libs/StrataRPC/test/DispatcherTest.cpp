/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include <QThread>

#include "DispatcherTest.h"

QTEST_MAIN(DispatcherTest)

DispatcherTest::DispatcherTest()
{
    messageList_.push_back(
        {"handler_1", {}, 1, "mg", strata::strataRPC::Message::MessageType::Command});
    messageList_.push_back(
        {"handler_2", {}, 2, "mg", strata::strataRPC::Message::MessageType::Notification});
    messageList_.push_back(
        {"handler_3", {}, 3, "mg", strata::strataRPC::Message::MessageType::Response});
    messageList_.push_back(
        {"handler_4", {}, 4, "mg", strata::strataRPC::Message::MessageType::Error});
    messageList_.push_back(
        {"handler_5", {}, 5, "mg", strata::strataRPC::Message::MessageType::Command});
}

void DispatcherTest::testRegisteringHandlers()
{
    Dispatcher<const Message &> dispatcher;

    QCOMPARE_(dispatcher.registerHandler(
                  "handler_1", std::bind(&TestHandlers::handler_1, th_, std::placeholders::_1)),
              true);
    QCOMPARE_(dispatcher.registerHandler(
                  "handler_1", std::bind(&TestHandlers::handler_1, th_, std::placeholders::_1)),
              false);
    QCOMPARE_(dispatcher.registerHandler(
                  "handler_2", std::bind(&TestHandlers::handler_1, th_, std::placeholders::_1)),
              true);
    QCOMPARE_(dispatcher.registerHandler(
                  "handler_1", std::bind(&TestHandlers::handler_2, th_, std::placeholders::_1)),
              false);
    QCOMPARE_(dispatcher.registerHandler(
                  "handler_2", std::bind(&TestHandlers::handler_2, th_, std::placeholders::_1)),
              false);
    QCOMPARE_(dispatcher.registerHandler(
                  "handler_3", std::bind(&TestHandlers::handler_3, th_, std::placeholders::_1)),
              true);
}

void DispatcherTest::testUregisterHandlers()
{
    Dispatcher<const Message &> dispatcher;

    QVERIFY_(false == dispatcher.unregisterHandler("not_registered_handler"));

    QVERIFY_(dispatcher.registerHandler("example_handler", [](const Message &) {}));
    QVERIFY_(dispatcher.unregisterHandler("example_handler"));
    QVERIFY_(false == dispatcher.unregisterHandler("example_handler"));
}

void DispatcherTest::testDispatchHandlers()
{
    Dispatcher<const Message &> dispatcher;

    QVERIFY_(dispatcher.registerHandler(
        "handler_1", std::bind(&TestHandlers::handler_1, th_, std::placeholders::_1)));
    QVERIFY_(dispatcher.registerHandler(
        "handler_2", std::bind(&TestHandlers::handler_2, th_, std::placeholders::_1)));
    QVERIFY_(dispatcher.registerHandler(
        "handler_3", std::bind(&TestHandlers::handler_3, th_, std::placeholders::_1)));
    QVERIFY_(dispatcher.registerHandler(
        "handler_4", std::bind(&TestHandlers::handler_4, th_, std::placeholders::_1)));

    QCOMPARE_(dispatcher.dispatch(messageList_[0].handlerName, messageList_[0]), true);
    QCOMPARE_(dispatcher.dispatch(messageList_[1].handlerName, messageList_[1]), true);
    QCOMPARE_(dispatcher.dispatch(messageList_[2].handlerName, messageList_[2]), true);
    QCOMPARE_(dispatcher.dispatch(messageList_[3].handlerName, messageList_[3]), true);
    QCOMPARE_(dispatcher.dispatch(messageList_[4].handlerName, messageList_[4]), false);
    QCOMPARE_(dispatcher.dispatch(messageList_[2].handlerName, messageList_[2]), true);
    QCOMPARE_(dispatcher.dispatch(messageList_[4].handlerName, messageList_[4]), false);
    QCOMPARE_(dispatcher.dispatch(messageList_[3].handlerName, messageList_[3]), true);
    QCOMPARE_(dispatcher.dispatch(messageList_[0].handlerName, messageList_[0]), true);
}

void DispatcherTest::testLargeNumberOfHandlers()
{
    Dispatcher<const Message &> dispatcher;

    for (int i = 0; i < 1000; i++) {
        dispatcher.registerHandler(QString::number(i), [i](const Message &message) {
            QCOMPARE_(message.handlerName, QString::number(i));
        });
    }

    for (int i = 0; i < 1000; i++) {
        dispatcher.dispatch(
            QString::number(i),
            {QString::number(i), {}, 1, "mg", strata::strataRPC::Message::MessageType::Command});
    }
}

void DispatcherTest::testDifferentArgumentType()
{
    Dispatcher<const QJsonObject &> dispatcher;

    QVERIFY_(dispatcher.registerHandler("test_handler_1", [](const QJsonObject &jsonPayload) {
        QCOMPARE(jsonPayload.value("value").toString(), "test");
    }));

    dispatcher.dispatch("test_handler_1", QJsonObject({{"value", "test"}}));
}

void DispatcherTest::testDispatchUsingSignals()
{
    Dispatcher<const Message &> *dispatcher = new Dispatcher<const Message &>;

    connect(this, &DispatcherTest::disp, this, [dispatcher](const Message &message) {
        QVERIFY_(dispatcher->dispatch(message.handlerName, message));
    });

    dispatcher->registerHandler("test_handler_1", [](const Message &message) {
        QCOMPARE_(message.handlerName, "test_handler_1");
    });

    dispatcher->registerHandler("test_handler_2", [](const Message &message) {
        QCOMPARE_(message.handlerName, "test_handler_2");
    });

    emit disp({"test_handler_1", {}, 1, "mg", strata::strataRPC::Message::MessageType::Command});
    emit disp({"test_handler_2", {}, 1, "mg", strata::strataRPC::Message::MessageType::Command});

    delete dispatcher;
}
