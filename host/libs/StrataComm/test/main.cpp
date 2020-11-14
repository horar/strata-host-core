#include <QtTest>
#include "DispatcherTest.h"
#include "ClientsControllerTest.h"
#include "QzmqTest.h"
#include "StrataServerTest.h"

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    app.setAttribute(Qt::AA_Use96Dpi, true);
    QTEST_SET_MAIN_SOURCE_PATH
    // DispatcherTest tc1;
    // ClientsControllerTest tc2;
    // ServerConnectorTest tc3;
    StrataServerTest tc4;

    int status = 0;
    // status |= QTest::qExec(&tc1, argc, argv);
    // status |= QTest::qExec(&tc2, argc, argv);
    // status |= QTest::qExec(&tc3, argc, argv);
    status |= QTest::qExec(&tc4, argc, argv);
    return status;
}
