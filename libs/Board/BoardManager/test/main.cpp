#include <QtTest>
#include "BoardManagerIntegrationTest.h"
#include "BoardManagerTest.h"
#include "DeviceOperationsTest.h"
#include "DeviceOperationsV2Test.h"

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    app.setAttribute(Qt::AA_Use96Dpi, true);
    QTEST_SET_MAIN_SOURCE_PATH
    BoardManagerTest tc1;
    DeviceOperationsTest tc2;
    DeviceOperationsV2Test tc3;
    BoardManagerIntegrationTest tc4;
    int status = 0;
    status |= QTest::qExec(&tc1, argc, argv);
    status |= QTest::qExec(&tc2, argc, argv);
    status |= QTest::qExec(&tc3, argc, argv);
    status |= QTest::qExec(&tc4, argc, argv);
    return status;
}

// QTEST_MAIN(BoardManagerTest)
// QTEST_MAIN(DeviceOperationsTest)
// QTEST_MAIN(DeviceOperationsV2Test)
// QTEST_MAIN(BoardManagerIntegrationTest)
