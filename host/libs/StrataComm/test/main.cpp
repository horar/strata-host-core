#include <QtTest>

#include "ClientsControllerTest.h"
#include "DispatcherTest.h"
#include "QzmqTest.h"
#include "RequestsControllerTest.h"
#include "StrataClientTest.h"
#include "StrataServerTest.h"
#include "StrataClientServerIntegrationTest.h"

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    app.setAttribute(Qt::AA_Use96Dpi, true);
    QTEST_SET_MAIN_SOURCE_PATH
    // DispatcherTest tc1;
    // ClientsControllerTest tc2;
    // ServerConnectorTest tc3;
    // StrataServerTest tc4;
    // StrataClientTest tc5;
    // RequestsControllerTest tc6;
    StrataClientServerIntegrationTest tc7;

    int status = 0;
    // status |= QTest::qExec(&tc1, argc, argv);
    // status |= QTest::qExec(&tc2, argc, argv);
    // status |= QTest::qExec(&tc3, argc, argv);
    // status |= QTest::qExec(&tc4, argc, argv);
    // status |= QTest::qExec(&tc5, argc, argv);
    // status |= QTest::qExec(&tc6, argc, argv);
    status |= QTest::qExec(&tc7, argc, argv);
    return status;
}
