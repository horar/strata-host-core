#include <QtTest>

#include "StrataClientBenchmark.h"
#include "StrataServerBenchmark.h"

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    app.setAttribute(Qt::AA_Use96Dpi, true);
    QTEST_SET_MAIN_SOURCE_PATH
    StrataClientBenchmark tc1;
    StrataServerBenchmark tc2;

    int status = 0;
    status |= QTest::qExec(&tc1, argc, argv);
    status |= QTest::qExec(&tc2, argc, argv);

    if (status == 0) {
        qInfo() << "All tests have passed.";
    } else {
        qWarning() << "Some of tests have failed!";
    }

    return status;
}
