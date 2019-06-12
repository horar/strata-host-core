
#include <QCoreApplication>
#include <QCommandLineParser>

#include "HostControllerService.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setOrganizationName(QStringLiteral("ON Semiconductor"));
    QCoreApplication::setApplicationName(QStringLiteral("HCS"));

    QCoreApplication theApp(argc, argv);

    QCommandLineParser parser;
    parser.setApplicationDescription("HCS");
    parser.addHelpOption();
    QCommandLineOption fileOption("f",
                                  QCoreApplication::translate("main", "optional configuration file"),
                                  QCoreApplication::translate("main", "filename"));
    parser.addOption(fileOption);

    parser.process(theApp);

    QString config = parser.value(fileOption);

    QScopedPointer<HostControllerService> hcs(new HostControllerService);

    if (hcs->initialize(config) == false) {
        return 1;
    }

    hcs->start();

    return theApp.exec();
}

