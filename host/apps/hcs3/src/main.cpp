#include "HostControllerServiceVersion.h"

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
    QCoreApplication::setApplicationName(QStringLiteral("hcs"));
    QCoreApplication::setApplicationVersion(version);
    QSettings::setDefaultFormat(QSettings::IniFormat);

    QCoreApplication theApp(argc, argv);

    QCommandLineParser parser;
    parser.setApplicationDescription("Strata Host Controller Service");
    parser.addOption({
        {QStringLiteral("f")},
         QObject::tr("optional configuration <filename> (default: AppConfigLocation)"),
         QObject::tr("filename")
    });
    parser.addVersionOption();
    parser.addHelpOption();
    parser.process(theApp);

    const QtLoggerSetup loggerInitialization(theApp);
    qCInfo(logCategoryHcs) << QStringLiteral("%1 %2").arg(QCoreApplication::applicationName()).arg(QCoreApplication::applicationVersion());

    spyglass::EvEventsMgrInstance instance;

    QScopedPointer<HostControllerService> hcs(new HostControllerService);

    const QString config{parser.value(QStringLiteral("f"))};
    if (hcs->initialize(config) == false) {
        return 1;
    }

    QObject::connect(&theApp, &QCoreApplication::aboutToQuit, hcs.get(), &HostControllerService::onAboutToQuit);

    hcs->start();

    return theApp.exec();
}

