#include <QtCore>
#include <QCoreApplication>

#include "platformidentificationtest.h"

int main(int argc, char* argv[]) {
    // set up the QtCoreApp
    QCoreApplication theApp(argc, argv);

    // set up the test object
    PlatformIdentificationTest* mTest = new PlatformIdentificationTest;
    mTest->init();
    mTest->start();

    return theApp.exec();
}
