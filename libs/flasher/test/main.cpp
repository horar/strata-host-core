#include <QtTest>
#include "FlasherTest.h"

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    app.setAttribute(Qt::AA_Use96Dpi, true);
    QTEST_SET_MAIN_SOURCE_PATH
    FlasherTest tc1;
    int status = 0;
    status |= QTest::qExec(&tc1, argc, argv);
    return status;
}

// QTEST_MAIN(FlasherTest)
