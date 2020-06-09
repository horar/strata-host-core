#include <QtTest>
#include "BoardManagerIntegrationTest.h"
#include "BoardManagerTest.h"
#include "DeviceOperationsTest.h"
#include <iostream>

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    app.setAttribute(Qt::AA_Use96Dpi, true);
    QTEST_SET_MAIN_SOURCE_PATH
    BoardManagerTest tc1;
    DeviceOperationsTest tc2;
    BoardManagerIntegrationTest tc3;
    int status = 0;
    status |= QTest::qExec(&tc1, argc, argv);
    status |= QTest::qExec(&tc2, argc, argv);
    status |= QTest::qExec(&tc3, argc, argv);
    return status;
}

// QTEST_MAIN(BoardManagerTest)
// QTEST_MAIN(DeviceOperationsTest)
// QTEST_MAIN(BoardManagerIntegrationTest)
