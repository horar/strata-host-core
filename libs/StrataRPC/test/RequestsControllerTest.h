#pragma once

#include "QtTest.h"

#include <QObject>
#include "RequestsController.h"

class RequestsControllerTest : public QObject
{
    Q_OBJECT

private slots:
    void testAddRequest();
    void testLargeNumberOfPendingRequests();
    void testNonExistanteRequestId();
    void testGetMethodName();
    void testPopRequest();
    void testRequestTimeout();
};
