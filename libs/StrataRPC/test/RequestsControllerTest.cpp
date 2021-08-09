#include "RequestsControllerTest.h"

#include <StrataRPC/Message.h>

using namespace strata::strataRPC;

QTEST_MAIN(RequestsControllerTest)

void RequestsControllerTest::testAddRequest()
{
    RequestsController rc;

    for (int i = 1; i < 30; i++) {
        std::pair<DeferredRequest *, QByteArray> requestInfo =
            rc.addNewRequest("method_1", {{"api", "v1"}});

        QVERIFY_(requestInfo.first->getId() != 0);
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
    RequestsController rc;

    for (int i = 0; i < 300; i++) {
        std::pair<DeferredRequest *, QByteArray> requestInfo =
            rc.addNewRequest(QString::number(i), {{"message_id", i}});
        QVERIFY_(requestInfo.first->getId() != 0);
        QVERIFY_(false == requestInfo.second.isEmpty());
    }
}

void RequestsControllerTest::testNonExistanteRequestId()
{
    RequestsController rc;

    QVERIFY_(false == rc.isPendingRequest(0));
    QVERIFY_(false == rc.isPendingRequest(-1));
    QVERIFY_(false == rc.isPendingRequest(2));

    QVERIFY_(false == rc.removePendingRequest(0));
    QVERIFY_(false == rc.removePendingRequest(-1));
    QVERIFY_(false == rc.removePendingRequest(2));
}

void RequestsControllerTest::testGetMethodName()
{
    RequestsController rc;
    std::pair<DeferredRequest *, QByteArray> requestInfo_1 =
        rc.addNewRequest("method_handler_1", {});
    QVERIFY_(requestInfo_1.first->getId() != 0);
    QVERIFY_(false == requestInfo_1.second.isEmpty());

    std::pair<DeferredRequest *, QByteArray> requestInfo_2 =
        rc.addNewRequest("method_handler_2", {});
    QVERIFY_(requestInfo_2.first->getId() != 0);
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

void RequestsControllerTest::testPopRequest()
{
    RequestsController rc;
    int numOfTestCases = 1000;

    for (int i = 0; i < numOfTestCases; i++) {
        const auto [deferredRequest, requestJson] =
            rc.addNewRequest("test_handler", QJsonObject({{}}));

        connect(deferredRequest, &DeferredRequest::finishedSuccessfully, this,
                [](const QJsonObject &) {});

        QVERIFY(deferredRequest->getId() > 0);
        QVERIFY(requestJson != "");
    }

    for (int i = 0; i < numOfTestCases; i++) {
        const auto [res, request] = rc.popPendingRequest(i + 1);
        QVERIFY(res);

        Message message;
        message.messageID = i;
    }

    const auto [res, request] = rc.popPendingRequest(numOfTestCases);
    QVERIFY(false == res);
}

void RequestsControllerTest::testRequestTimeout()
{
    int totalTimedoutRequests = 0;
    int totalNumOfRequests = 1000;

    RequestsController rc;

    connect(
        &rc, &RequestsController::requestTimedout, this,
        [&totalTimedoutRequests, &rc](const int &id) {
            auto [requestFound, request] = rc.popPendingRequest(id);
            if (false == requestFound && request.deferredRequest_ == nullptr) {
                return;
            }

            request.deferredRequest_->deleteLater();
            ++totalTimedoutRequests;
        },
        Qt::QueuedConnection);

    for (int i = 0; i < totalNumOfRequests; i++) {
        std::pair<DeferredRequest *, QByteArray> requestInfo =
            rc.addNewRequest("test", QJsonObject({{}}));
    }

    QTRY_COMPARE_WITH_TIMEOUT(totalTimedoutRequests, totalNumOfRequests, 550);
}
