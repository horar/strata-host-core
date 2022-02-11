/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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

        QVERIFY(requestInfo.first->getId() != 0);
        QVERIFY(false == requestInfo.second.isEmpty());
    }

    QVERIFY(rc.isPendingRequest(1));
    QVERIFY(false == rc.isPendingRequest(100));

    for (int i = 1; i < 30; i++) {
        QVERIFY(rc.removePendingRequest(i));
    }

    QVERIFY(false == rc.removePendingRequest(1));
    QVERIFY(false == rc.removePendingRequest(1000));
}

void RequestsControllerTest::testLargeNumberOfPendingRequests()
{
    RequestsController rc;

    for (int i = 0; i < 300; i++) {
        std::pair<DeferredRequest *, QByteArray> requestInfo =
            rc.addNewRequest(QString::number(i), {{"message_id", i}});
        QVERIFY(requestInfo.first->getId() != 0);
        QVERIFY(false == requestInfo.second.isEmpty());
    }
}

void RequestsControllerTest::testNonExistanteRequestId()
{
    RequestsController rc;

    QVERIFY(false == rc.isPendingRequest(0));
    QVERIFY(false == rc.isPendingRequest(-1));
    QVERIFY(false == rc.isPendingRequest(2));

    QVERIFY(false == rc.removePendingRequest(0));
    QVERIFY(false == rc.removePendingRequest(-1));
    QVERIFY(false == rc.removePendingRequest(2));
}

void RequestsControllerTest::testGetMethodName()
{
    RequestsController rc;
    std::pair<DeferredRequest *, QByteArray> requestInfo_1 =
        rc.addNewRequest("method_handler_1", {});
    QVERIFY(requestInfo_1.first->getId() != 0);
    QVERIFY(false == requestInfo_1.second.isEmpty());

    std::pair<DeferredRequest *, QByteArray> requestInfo_2 =
        rc.addNewRequest("method_handler_2", {});
    QVERIFY(requestInfo_2.first->getId() != 0);
    QVERIFY(false == requestInfo_2.second.isEmpty());

    QVERIFY(rc.isPendingRequest(1));
    QCOMPARE(rc.getMethodName(1), "method_handler_1");

    QVERIFY(rc.isPendingRequest(2));
    QCOMPARE(rc.getMethodName(2), "method_handler_2");

    QVERIFY(false == rc.isPendingRequest(3));
    QCOMPARE(rc.getMethodName(3), "");

    QVERIFY(rc.removePendingRequest(1));
    QVERIFY(false == rc.isPendingRequest(1));
    QCOMPARE(rc.getMethodName(1), "");
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

    QTRY_COMPARE_WITH_TIMEOUT(totalTimedoutRequests, totalNumOfRequests, 3000);
}
