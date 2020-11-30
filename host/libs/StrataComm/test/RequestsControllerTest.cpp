#include "RequestsControllerTest.h"


void RequestsControllerTest::testAddRequest() 
{
    strata::strataComm::RequestsController rc;
    connect(&rc, &strata::strataComm::RequestsController::sendRequest, this, [](const QByteArray &request) {
        qDebug() << request;
    });

    rc.addNewRequest("method_1", {{"api", "v1"}});
    rc.addNewRequest("method_1", {{"api", "v1"}});
    rc.addNewRequest("method_1", {{"api", "v1"}});
    rc.addNewRequest("method_1", {{"api", "v1"}});
    rc.addNewRequest("method_1", {{"api", "v1"}});
    rc.addNewRequest("method_1", {{"api", "v1"}});
    rc.addNewRequest("method_1", {{"api", "v1"}});
    rc.addNewRequest("method_1", {{"api", "v1"}});
    rc.addNewRequest("method_1", {{"api", "v1"}});
    rc.addNewRequest("method_1", {{"api", "v1"}});
    rc.addNewRequest("method_1", {{"api", "v1"}});
    rc.addNewRequest("method_1", {{"api", "v1"}});
    rc.addNewRequest("method_1", {{"api", "v1"}});
    rc.addNewRequest("method_1", {{"api", "v1"}});
    rc.addNewRequest("method_1", {{"api", "v1"}});
    rc.addNewRequest("method_1", {{"api", "v1"}});
    rc.addNewRequest("method_1", {{"api", "v1"}});
    rc.addNewRequest("method_1", {{"api", "v1"}});
    rc.addNewRequest("method_1", {{"api", "v1"}});
    rc.addNewRequest("method_1", {{"api", "v1"}});
    rc.addNewRequest("method_1", {{"api", "v1"}});
    rc.addNewRequest("method_1", {{"api", "v1"}});
    rc.addNewRequest("method_1", {{"api", "v1"}});
    rc.addNewRequest("method_1", {{"api", "v1"}});
    rc.addNewRequest("method_1", {{"api", "v1"}});
    rc.addNewRequest("method_1", {{"api", "v1"}});
    rc.addNewRequest("method_1", {{"api", "v1"}});
    rc.addNewRequest("method_1", {{"api", "v1"}});
    rc.addNewRequest("method_1", {{"api", "v1"}});


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
    strata::strataComm::RequestsController rc;

    for (int i=0; i<300; i++) {
        rc.addNewRequest(QString::number(i), {{"message_id", i}});
    }
}

void RequestsControllerTest::testNonExistanteRequestId() 
{
    strata::strataComm::RequestsController rc;

    QVERIFY_(false == rc.isPendingRequest(0));
    QVERIFY_(false == rc.isPendingRequest(-1));
    QVERIFY_(false == rc.isPendingRequest(2));

    QVERIFY_(false == rc.removePendingRequest(0));
    QVERIFY_(false == rc.removePendingRequest(-1));
    QVERIFY_(false == rc.removePendingRequest(2));
}
