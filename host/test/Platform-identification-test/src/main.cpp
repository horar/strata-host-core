#include <QtCore>
#include <QCoreApplication>
#include <QCommandLineParser>

#include "PlatformIdentificationTest.h"

int main(int argc, char* argv[]) {
    QCoreApplication::setApplicationName(QStringLiteral("platform-identification-test"));
    QCoreApplication theApp(argc, argv);


    QCommandLineParser parser;
    parser.setApplicationDescription("Description: This is a simple test to verify that the released platforms are identifed by the PlatformManager.");
    parser.addHelpOption();

    QCommandLineOption jlinkExePathOption(QStringList() << "j" << "jlink-path",
                                          QObject::tr("Path to JLinkExe executable. (Required)"),
                                          QObject::tr("JLinkPath"));
    QCommandLineOption binariesPathOption(QStringList() << "b" << "binaries-path",
                                          QObject::tr("Path to the directory containing the binary files. (Required)"),
                                          QObject::tr("binariesPath"));
    parser.addOptions({jlinkExePathOption, binariesPathOption});
    parser.process(theApp);

    QString jlinkExePath, binariesPath;
    if (parser.isSet("j") && parser.isSet("b")) {
        jlinkExePath = parser.value("j");
        binariesPath = parser.value("b");
    } else {
        std::cerr << "No arguments were Supplied." << std::endl;
        parser.showHelp();
        return -1;
    }

    // set up the test object
    std::shared_ptr<PlatformIdentificationTest> test_(new PlatformIdentificationTest);
    if (!test_->init(jlinkExePath, binariesPath)) {  // pass the jlink and binaries paths.
        return -1;
    }

    QObject::connect(test_.get(), &PlatformIdentificationTest::testDone, &theApp, &QCoreApplication::exit);
    test_->start();
    return theApp.exec();
}
