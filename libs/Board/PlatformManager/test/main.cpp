#include <QtTest>
#include "PlatformManagerIntegrationTest.h"
#include "PlatformManagerTest.h"
#include "PlatformOperationsTest.h"
#include "PlatformOperationsV2Test.h"
#include "PlatformMessageTest.h"
#include "PlatformErrorsTest.h"

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    app.setAttribute(Qt::AA_Use96Dpi, true);
    QTEST_SET_MAIN_SOURCE_PATH
    PlatformManagerTest tc1;
    PlatformOperationsTest tc2;
    PlatformOperationsV2Test tc3;
    PlatformManagerIntegrationTest tc4;
    PlatformMessageTest tc5;
    PlatformErrorsTest tc6;
    int status = 0;
    status |= QTest::qExec(&tc1, argc, argv);
    status |= QTest::qExec(&tc2, argc, argv);
    status |= QTest::qExec(&tc3, argc, argv);
    status |= QTest::qExec(&tc4, argc, argv);
    status |= QTest::qExec(&tc5, argc, argv);
    status |= QTest::qExec(&tc6, argc, argv);
    if (status == 0) {
        qInfo() << "All tests have passed.";
    } else {
        qWarning() << "Some of tests have failed!";
    }
    return status;
}

// QTEST_MAIN(PlatformManagerTest)
// QTEST_MAIN(PlatformOperationsTest)
// QTEST_MAIN(PlatformOperationsV2Test)
// QTEST_MAIN(PlatformManagerIntegrationTest)
// QTEST_MAIN(PlatformMessageTest)
// QTEST_MAIN(PlatformErrorsTest)
