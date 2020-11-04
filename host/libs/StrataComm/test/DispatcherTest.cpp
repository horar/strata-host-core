#include "DispatcherTest.h"
#include <QThread>

DispatcherTest::DispatcherTest() {
    cm_.push_back({"handler_1",{},1,"mg",ClientMessage::MessageType::Command});
    cm_.push_back({"handler_2",{},2,"mg",ClientMessage::MessageType::Notifiation});
    cm_.push_back({"handler_3",{},3,"mg",ClientMessage::MessageType::none});
    cm_.push_back({"handler_4",{},4,"mg",ClientMessage::MessageType::Command});
    cm_.push_back({"handler_5",{},5,"mg",ClientMessage::MessageType::Command});
}

void DispatcherTest::testFunction1() {
    Dispatcher dispatcher;

    dispatcher.start();
}

void DispatcherTest::testFunction2() {
    Dispatcher dispatcher;

    dispatcher.stop();
}

void DispatcherTest::testRegisteringHandlers() {
    Dispatcher dispatcher;

    //    dispatcher.registerHandler("handler_1", std::bind(&DispatcherTest::testHandler, this));
    ClientMessage cm;
    cm.clientID = QByteArray("mg");
    cm.handlerName = "handler_1";

    QCOMPARE_(dispatcher.registerHandler("handler_1", std::bind(&TestHandlers::handler_1, th_, std::placeholders::_1)), true);
    QCOMPARE_(dispatcher.registerHandler("handler_1", std::bind(&TestHandlers::handler_1, th_, std::placeholders::_1)), false);
    QCOMPARE_(dispatcher.registerHandler("handler_2", std::bind(&TestHandlers::handler_1, th_, std::placeholders::_1)), true);
    QCOMPARE_(dispatcher.registerHandler("handler_1", std::bind(&TestHandlers::handler_2, th_, std::placeholders::_1)), false);
    QCOMPARE_(dispatcher.registerHandler("handler_2", std::bind(&TestHandlers::handler_2, th_, std::placeholders::_1)), false);
    QCOMPARE_(dispatcher.registerHandler("handler_3", std::bind(&TestHandlers::handler_3, th_, std::placeholders::_1)), true);
}

void DispatcherTest::testDispatchHandlers() {
    Dispatcher dispatcher;

    ClientMessage cm;
    cm.clientID = QByteArray("mg");
    cm.handlerName = "handler_1";

    dispatcher.registerHandler("handler_1", std::bind(&TestHandlers::handler_1, th_, std::placeholders::_1));
    dispatcher.registerHandler("handler_2", std::bind(&TestHandlers::handler_2, th_, std::placeholders::_1));
    dispatcher.registerHandler("handler_3", std::bind(&TestHandlers::handler_3, th_, std::placeholders::_1));
    dispatcher.registerHandler("handler_4", std::bind(&TestHandlers::handler_4, th_, std::placeholders::_1));

    QCOMPARE_(dispatcher.dispatch(cm_[0]), true);
    QCOMPARE_(dispatcher.dispatch(cm_[1]), true);
    QCOMPARE_(dispatcher.dispatch(cm_[2]), true);
    QCOMPARE_(dispatcher.dispatch(cm_[3]), true);
    QCOMPARE_(dispatcher.dispatch(cm_[4]), false);
    QCOMPARE_(dispatcher.dispatch(cm_[2]), true);
    QCOMPARE_(dispatcher.dispatch(cm_[4]), false);
    QCOMPARE_(dispatcher.dispatch(cm_[3]), true);
    QCOMPARE_(dispatcher.dispatch(cm_[0]), true);

}

void DispatcherTest::testDispatchHandlers_2() {
    Dispatcher dispatcher;

    qRegisterMetaType<ClientMessage>("ClientMessage");
    connect(this, &DispatcherTest::disp, &dispatcher, &Dispatcher::dispatchHandler);

    dispatcher.registerHandler("handler_1", std::bind(&TestHandlers::handler_1, th_, std::placeholders::_1));
    dispatcher.registerHandler("handler_2", std::bind(&TestHandlers::handler_2, th_, std::placeholders::_1));
    dispatcher.registerHandler("handler_3", std::bind(&TestHandlers::handler_3, th_, std::placeholders::_1));
    dispatcher.registerHandler("handler_4", std::bind(&TestHandlers::handler_4, th_, std::placeholders::_1));

    emit disp(cm_[0]);
    emit disp(cm_[1]);
    emit disp(cm_[2]);
    emit disp(cm_[3]);
    emit disp(cm_[3]);
    emit disp(cm_[4]);
    emit disp(cm_[0]);

}

void DispatcherTest::testDispatchHandlers_3() {
    Dispatcher *dispatcher = new Dispatcher();
    QThread *myThread = new QThread();

    dispatcher->moveToThread(myThread);
    myThread->start();

    qRegisterMetaType<ClientMessage>("ClientMessage");
    connect(this, &DispatcherTest::disp, dispatcher, &Dispatcher::dispatchHandler);

    dispatcher->registerHandler("handler_1", std::bind(&TestHandlers::handler_1, th_, std::placeholders::_1));
    dispatcher->registerHandler("handler_2", std::bind(&TestHandlers::handler_2, th_, std::placeholders::_1));
    dispatcher->registerHandler("handler_3", std::bind(&TestHandlers::handler_3, th_, std::placeholders::_1));
    dispatcher->registerHandler("handler_4", std::bind(&TestHandlers::handler_4, th_, std::placeholders::_1));

    ClientMessage cm;
    cm.clientID = QByteArray("mg");
    cm.handlerName = "handler_1";

    emit disp(cm);
    emit disp(cm);
    emit disp(cm);
    emit disp(cm);
    emit disp(cm);
    emit disp(cm);
    emit disp(cm);

//    QThread::sleep(2);
    myThread->terminate();
    myThread->wait();
}

void DispatcherTest::testDispatchHandlers_5() {
    Dispatcher dispatcher;
    dispatcher.start();

    qRegisterMetaType<ClientMessage>("ClientMessage");
    connect(this, &DispatcherTest::disp, &dispatcher, &Dispatcher::dispatchHandler, Qt::QueuedConnection);

    dispatcher.registerHandler("handler_1", std::bind(&TestHandlers::handler_1, th_, std::placeholders::_1));
    dispatcher.registerHandler("handler_2", std::bind(&TestHandlers::handler_2, th_, std::placeholders::_1));
    dispatcher.registerHandler("handler_3", std::bind(&TestHandlers::handler_3, th_, std::placeholders::_1));
    dispatcher.registerHandler("handler_4", std::bind(&TestHandlers::handler_4, th_, std::placeholders::_1));

    ClientMessage cm;
    cm.clientID = QByteArray("mg");
    cm.handlerName = "handler_1";

    emit disp(cm);
    emit disp(cm);
    emit disp(cm);
    emit disp(cm);
    emit disp(cm);
    emit disp(cm);
    emit disp(cm);

    dispatcher.thread()->wait();

}

void DispatcherTest::testLargeNumberOfHandlers() {
    Dispatcher dispatcher;

    for(int i=0; i < 1000; i++) {
        dispatcher.registerHandler(QString::number(i),[i](const ClientMessage &clientMessage) {
           qDebug() << i;
        });
    }

    for (int i=0; i < 1000; i++) {
        dispatcher.dispatch({QString::number(i),{},1,"mg",ClientMessage::MessageType::Command});
    }
}

void DispatcherTest::testLargeNumberOfHandlers_1() {
    Dispatcher *dispatcher = new Dispatcher();
    QThread *myThread = new QThread();

    qRegisterMetaType<ClientMessage>("ClientMessage");
    connect(this, &DispatcherTest::disp, dispatcher, &Dispatcher::dispatchHandler);

    dispatcher->moveToThread(myThread);
    myThread->start();

    for(int i=0; i < 1000; i++) {
        dispatcher->registerHandler(QString::number(i),[i](const ClientMessage &clientMessage) {
           qDebug() << i;
        });
    }

    for (int i=0; i < 1000; i++) {
        emit disp({QString::number(i),{},1,"mg",ClientMessage::MessageType::Command});
    }

    myThread->terminate();
    myThread->wait();
}
