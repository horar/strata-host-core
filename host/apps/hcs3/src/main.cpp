
#include <QCoreApplication>
#include <QCommandLineParser>
#include <QSettings>

#include <EvEventsMgr.h>    //for EvEventsMgrInstance (windows WSA)

#include "HostControllerService.h"

#include <QtLoggerSetup.h>
#include "logging/LoggingQtCategories.h"


int main(int argc, char *argv[])
{
    QCoreApplication::setOrganizationName(QStringLiteral("ON Semiconductor"));
    QCoreApplication::setApplicationName(QStringLiteral("HCS"));
    QSettings::setDefaultFormat(QSettings::IniFormat);

    QCoreApplication theApp(argc, argv);

    const QtLoggerSetup loggerInitialization(theApp);
    qCInfo(logCategoryHcs) << QStringLiteral("%1 v%2").arg(QCoreApplication::applicationName()).arg(QCoreApplication::applicationVersion());

    spyglass::EvEventsMgrInstance instance;

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

