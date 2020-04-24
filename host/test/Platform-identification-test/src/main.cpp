#include <QtCore>
#include <QCoreApplication>
#include <QCommandLineParser>

#include "PlatformIdentificationTest.h"

int main(int argc, char* argv[]) {
    // set up the QtCoreApp
    QCoreApplication theApp(argc, argv);

    // Commandline argument parser
    QCommandLineParser parser;

    // Add Commandline Options
    QCommandLineOption jlinkExePathOption(QStringList() << "j" << "jlink-path",
                                          QObject::tr("Path to JLinkExe executable."),
                                          QObject::tr("JLinkPath"));
    QCommandLineOption binariesPathOption(QStringList() << "b" << "binaries-path",
                                          QObject::tr("Path to the directory containing the binary files."),
                                          QObject::tr("binariesPath"));
    parser.addOptions({jlinkExePathOption, binariesPathOption});
    parser.process(theApp);

    // both args are required!
    QString jlinkExePath, binariesPath;
    if(parser.isSet("j") && parser.isSet("b")) {
        jlinkExePath = parser.value("j");
        binariesPath = parser.value("b");
    }
    else {
        std::cout << "args not supplied. existing :P" << std::endl;
        return -1;
    }

    // set up the test object
    PlatformIdentificationTest* mTest = new PlatformIdentificationTest;
    mTest->init(jlinkExePath, binariesPath); // pass the jlink and binaries paths.
    mTest->start();
    QObject::connect(mTest, &PlatformIdentificationTest::testDone, &theApp, &QCoreApplication::exit);
    return theApp.exec();
}
