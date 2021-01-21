#include "RequestsControllerTest.h"

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
