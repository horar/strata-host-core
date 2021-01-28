#include "RequestsControllerTest.h"

#include <StrataRPC/Message.h>

void RequestsControllerTest::testAddRequest()
{
    strata::strataRPC::RequestsController rc;

    for (int i = 1; i < 30; i++) {
        std::pair<int, QByteArray> requestInfo = rc.addNewRequest("method_1", {{"api", "v1"}});

        QVERIFY_(requestInfo.first != 0);
        QVERIFY_(false == requestInfo.second.isEmpty());
    }

    QVERIFY_(rc.isPendingRequest(1));
    QVERIFY_(false == rc.isPendingRequest(100));

    for (int i = 1; i < 30; i++) {
        QVERIFY_(rc.removePendingRequest(i));
    }

    QVERIFY_(false == rc.removePendingRequest(1));
    QVERIFY_(false == rc.removePendingRequest(1000));
}

void RequestsControllerTest::testLargeNumberOfPendingRequests()
{
    strata::strataRPC::RequestsController rc;

    for (int i = 0; i < 300; i++) {
        std::pair<int, QByteArray> requestInfo =
            rc.addNewRequest(QString::number(i), {{"message_id", i}});
        QVERIFY_(requestInfo.first != 0);
        QVERIFY_(false == requestInfo.second.isEmpty());
    }
}

void RequestsControllerTest::testNonExistanteRequestId()
{
    strata::strataRPC::RequestsController rc;

    QVERIFY_(false == rc.isPendingRequest(0));
    QVERIFY_(false == rc.isPendingRequest(-1));
    QVERIFY_(false == rc.isPendingRequest(2));

    QVERIFY_(false == rc.removePendingRequest(0));
    QVERIFY_(false == rc.removePendingRequest(-1));
    QVERIFY_(false == rc.removePendingRequest(2));
}

void RequestsControllerTest::testGetMethodName()
{
    strata::strataRPC::RequestsController rc;
    std::pair<int, QByteArray> requestInfo_1 = rc.addNewRequest("method_handler_1", {});
    QVERIFY_(requestInfo_1.first != 0);
    QVERIFY_(false == requestInfo_1.second.isEmpty());

    std::pair<int, QByteArray> requestInfo_2 = rc.addNewRequest("method_handler_2", {});
    QVERIFY_(requestInfo_2.first != 0);
    QVERIFY_(false == requestInfo_2.second.isEmpty());

    QVERIFY_(rc.isPendingRequest(1));
    QCOMPARE_(rc.getMethodName(1), "method_handler_1");

    QVERIFY_(rc.isPendingRequest(2));
    QCOMPARE_(rc.getMethodName(2), "method_handler_2");

    QVERIFY_(false == rc.isPendingRequest(3));
    QCOMPARE_(rc.getMethodName(3), "");

    QVERIFY_(rc.removePendingRequest(1));
    QVERIFY_(false == rc.isPendingRequest(1));
    QCOMPARE_(rc.getMethodName(1), "");
}

void RequestsControllerTest::testRequestCallbacks()
{
    strata::strataRPC::Request myRequest("test_handler", QJsonObject({{}}), 0);

    if (myRequest.resultCallback_) {
        qDebug() << "there is result callback";
    } else {
        qDebug() << "no result callback";
    }

    if (myRequest.errorCallback_) {
        qDebug() << "there is error callback";
    } else {
        qDebug() << "no error callback";
    }

    myRequest.resultCallback_ = [this](const strata::strataRPC::Message &message) {
        qDebug() << "in result callback";
    };

    myRequest.errorCallback_ = [this](const strata::strataRPC::Message &message) {
        qDebug() << "in error callback";
    };

    if (myRequest.resultCallback_) {
        qDebug() << "there is result callback";
        myRequest.resultCallback_(strata::strataRPC::Message());
    } else {
        qDebug() << "no result callback";
    }

    if (myRequest.errorCallback_) {
        qDebug() << "there is error callback";
        myRequest.errorCallback_(strata::strataRPC::Message());
    } else {
        qDebug() << "no error callback";
    }

    ///////////////////////////////////////
    
    strata::strataRPC::Request request_2(
        "test_1", QJsonObject({{}}), 1,
        [this](const strata::strataRPC::Message &message) { qDebug() << "in error callback 2"; },
        [this](const strata::strataRPC::Message &message) { qDebug() << "in res callback 2"; });

    qDebug() << "request_2";
    if (request_2.resultCallback_) {
        qDebug() << "there is result callback";
        request_2.resultCallback_(strata::strataRPC::Message());
    } else {
        qDebug() << "no result callback";
    }

    if (request_2.errorCallback_) {
        qDebug() << "there is error callback";
        request_2.errorCallback_(strata::strataRPC::Message());
    } else {
        qDebug() << "no error callback";
    }

    qDebug() << "request_3";
    strata::strataRPC::Request request_3(
        "test_1", QJsonObject({{}}), 1,
        nullptr,
        [this](const strata::strataRPC::Message &message) { qDebug() << "in res callback 3"; });

    if (request_3.resultCallback_) {
        qDebug() << "there is result callback";
        request_3.resultCallback_(strata::strataRPC::Message());
    } else {
        qDebug() << "no result callback";
    }

    if (request_3.errorCallback_) {
        qDebug() << "there is error callback";
        request_3.errorCallback_(strata::strataRPC::Message());
    } else {
        qDebug() << "no error callback";
    }

    qDebug() << "request_4";
    strata::strataRPC::Request request_4(
        "test_1", QJsonObject({{}}), 1,
        [this](const strata::strataRPC::Message &message) { qDebug() << "in error callback 4"; },
        nullptr);

    if (request_4.resultCallback_) {
        qDebug() << "there is result callback";
        request_4.resultCallback_(strata::strataRPC::Message());
    } else {
        qDebug() << "no result callback";
    }

    if (request_4.errorCallback_) {
        qDebug() << "there is error callback";
        request_4.errorCallback_(strata::strataRPC::Message());
    } else {
        qDebug() << "no error callback";
    }
}
