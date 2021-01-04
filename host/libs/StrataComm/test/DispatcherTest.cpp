#include <QThread>

#include "DispatcherTest.h"

DispatcherTest::DispatcherTest()
{
    messageList_.push_back(
        {"handler_1", {}, 1, "mg", strata::strataComm::Message::MessageType::Command});
    messageList_.push_back(
        {"handler_2", {}, 2, "mg", strata::strataComm::Message::MessageType::Notification});
    messageList_.push_back(
        {"handler_3", {}, 3, "mg", strata::strataComm::Message::MessageType::Response});
    messageList_.push_back(
        {"handler_4", {}, 4, "mg", strata::strataComm::Message::MessageType::Error});
    messageList_.push_back(
        {"handler_5", {}, 5, "mg", strata::strataComm::Message::MessageType::Command});
}

void DispatcherTest::testStartDispatcher()
{
    Dispatcher dispatcher;

    QVERIFY_(dispatcher.start());
}

void DispatcherTest::testStopDispatcher()
{
    Dispatcher dispatcher;

    QVERIFY_(dispatcher.stop());
}

void DispatcherTest::testRegisteringHandlers()
{
    Dispatcher dispatcher;

    Message message;
    message.clientID = QByteArray("mg");
    message.handlerName = "handler_1";

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

void DispatcherTest::testDispatchHandlers()
{
    Dispatcher dispatcher;

    Message message;
    message.clientID = QByteArray("mg");
    message.handlerName = "handler_1";

    QVERIFY_(dispatcher.registerHandler(
        "handler_1", std::bind(&TestHandlers::handler_1, th_, std::placeholders::_1)));
    QVERIFY_(dispatcher.registerHandler(
        "handler_2", std::bind(&TestHandlers::handler_2, th_, std::placeholders::_1)));
    QVERIFY_(dispatcher.registerHandler(
        "handler_3", std::bind(&TestHandlers::handler_3, th_, std::placeholders::_1)));
    QVERIFY_(dispatcher.registerHandler(
        "handler_4", std::bind(&TestHandlers::handler_4, th_, std::placeholders::_1)));

    QCOMPARE_(dispatcher.dispatch(messageList_[0]), true);
    QCOMPARE_(dispatcher.dispatch(messageList_[1]), true);
    QCOMPARE_(dispatcher.dispatch(messageList_[2]), true);
    QCOMPARE_(dispatcher.dispatch(messageList_[3]), true);
    QCOMPARE_(dispatcher.dispatch(messageList_[4]), false);
    QCOMPARE_(dispatcher.dispatch(messageList_[2]), true);
    QCOMPARE_(dispatcher.dispatch(messageList_[4]), false);
    QCOMPARE_(dispatcher.dispatch(messageList_[3]), true);
    QCOMPARE_(dispatcher.dispatch(messageList_[0]), true);
}

void DispatcherTest::testDispatchHandlersUsingSignal()
{
    Dispatcher dispatcher;

    qRegisterMetaType<Message>("Message");
    connect(this, &DispatcherTest::disp, &dispatcher, &Dispatcher::dispatchHandler);

    QVERIFY_(dispatcher.registerHandler(
        "handler_1", std::bind(&TestHandlers::handler_1, th_, std::placeholders::_1)));
    QVERIFY_(dispatcher.registerHandler(
        "handler_2", std::bind(&TestHandlers::handler_2, th_, std::placeholders::_1)));
    QVERIFY_(dispatcher.registerHandler(
        "handler_3", std::bind(&TestHandlers::handler_3, th_, std::placeholders::_1)));
    QVERIFY_(dispatcher.registerHandler(
        "handler_4", std::bind(&TestHandlers::handler_4, th_, std::placeholders::_1)));

    emit disp(messageList_[0]);
    emit disp(messageList_[1]);
    emit disp(messageList_[2]);
    emit disp(messageList_[3]);
    emit disp(messageList_[3]);
    emit disp(messageList_[4]);
    emit disp(messageList_[0]);
}

void DispatcherTest::testDispatchHandlersInDispatcherThread()
{
    Dispatcher *dispatcher = new Dispatcher();
    QThread *myThread = new QThread();

    dispatcher->moveToThread(myThread);
    myThread->start();

    qRegisterMetaType<Message>("Message");
    connect(this, &DispatcherTest::disp, dispatcher, &Dispatcher::dispatchHandler);

    QVERIFY_(dispatcher->registerHandler(
        "handler_1", std::bind(&TestHandlers::handler_1, th_, std::placeholders::_1)));
    QVERIFY_(dispatcher->registerHandler(
        "handler_2", std::bind(&TestHandlers::handler_2, th_, std::placeholders::_1)));
    QVERIFY_(dispatcher->registerHandler(
        "handler_3", std::bind(&TestHandlers::handler_3, th_, std::placeholders::_1)));
    QVERIFY_(dispatcher->registerHandler(
        "handler_4", std::bind(&TestHandlers::handler_4, th_, std::placeholders::_1)));

    Message message;
    message.clientID = QByteArray("mg");
    message.handlerName = "handler_1";
    message.messageID = 0;

    emit disp(message);
    emit disp(message);
    emit disp(message);
    emit disp(message);
    emit disp(message);
    emit disp(message);
    emit disp(message);

    myThread->quit();
    myThread->wait();
}

void DispatcherTest::testDispatchHandlersLocalMessage()
{
    Dispatcher dispatcher;
    dispatcher.start();

    qRegisterMetaType<Message>("Message");
    connect(this, &DispatcherTest::disp, &dispatcher, &Dispatcher::dispatchHandler,
            Qt::QueuedConnection);

    dispatcher.registerHandler("handler_1",
                               std::bind(&TestHandlers::handler_1, th_, std::placeholders::_1));
    dispatcher.registerHandler("handler_2",
                               std::bind(&TestHandlers::handler_2, th_, std::placeholders::_1));
    dispatcher.registerHandler("handler_3",
                               std::bind(&TestHandlers::handler_3, th_, std::placeholders::_1));
    dispatcher.registerHandler("handler_4",
                               std::bind(&TestHandlers::handler_4, th_, std::placeholders::_1));

    Message message;
    message.clientID = QByteArray("mg");
    message.handlerName = "handler_1";

    emit disp(message);
    emit disp(message);
    emit disp(message);
    emit disp(message);
    emit disp(message);
    emit disp(message);
    emit disp(message);
}

void DispatcherTest::testLargeNumberOfHandlers()
{
    Dispatcher dispatcher;

    for (int i = 0; i < 1000; i++) {
        dispatcher.registerHandler(QString::number(i), [i](const Message &message) {
            QCOMPARE_(message.handlerName, QString::number(i));
        });
    }

    for (int i = 0; i < 1000; i++) {
        dispatcher.dispatch(
            {QString::number(i), {}, 1, "mg", strata::strataComm::Message::MessageType::Command});
    }
}

void DispatcherTest::testLargeNumberOfHandlersUsingDispatcherThread()
{
    Dispatcher *dispatcher = new Dispatcher();
    QThread *myThread = new QThread();

    qRegisterMetaType<Message>("Message");
    connect(this, &DispatcherTest::disp, dispatcher, &Dispatcher::dispatchHandler);

    dispatcher->moveToThread(myThread);
    myThread->start();

    for (int i = 0; i < 1000; i++) {
        dispatcher->registerHandler(QString::number(i), [i](const Message &message) {
            QCOMPARE_(message.handlerName, QString::number(i));
        });
    }

    for (int i = 0; i < 1000; i++) {
        emit disp(
            {QString::number(i), {}, 1, "mg", strata::strataComm::Message::MessageType::Command});
    }

    // wait for all events to be dispatched
    QTimer timer;
    timer.setSingleShot(true);
    timer.start(100);
    do {
        QCoreApplication::processEvents(QEventLoop::WaitForMoreEvents);
    } while (timer.isActive());

    myThread->quit();
    myThread->wait();
}
