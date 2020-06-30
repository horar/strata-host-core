#include "HostControllerService.h"

#include "HostControllerServiceVersion.h"
#include "HostControllerServiceTimestamp.h"
#include "RunGuard.h"

#include "logging/LoggingQtCategories.h"

#include <QtLoggerSetup.h>

#include <CbLoggerSetup.h>

#include <QCoreApplication>
#include <QCommandLineParser>
#include <QSettings>
#include <QStandardPaths>
#include <QDir>

#if defined(Q_OS_WIN)
#include <EventsMgr/win32/EvEventsMgrInstance.h> // Windows WSA
#endif

#if !defined(Q_OS_WIN)
#include "unix/SignalHandlers.h"
#endif

int main(int argc, char *argv[])
{
    QSettings::setDefaultFormat(QSettings::IniFormat);
    QCoreApplication::setApplicationName(QStringLiteral("hcs"));
    QCoreApplication::setApplicationVersion(AppInfo::version.data());
    QCoreApplication::setOrganizationName(QStringLiteral("ON Semiconductor"));

    QCoreApplication app(argc, argv);

    QCommandLineParser parser;
    parser.setApplicationDescription("Strata Host Controller Service");
    parser.addOption({
        {QStringLiteral("f")},
        QObject::tr("Optional configuration <filename> (default: AppConfigLocation)."),
        QObject::tr("filename")
    });
    parser.addOption({
        {QStringLiteral("c")},
        QObject::tr("Clear cache data of Host Controller Service.")
    });
    parser.addVersionOption();
    parser.addHelpOption();
    parser.process(app);

    RunGuard appGuard{"tech.strata.hcs"};

    if (parser.isSet(QStringLiteral("c"))) {
        if (appGuard.tryToRun() == false) {
            qCritical() << QStringLiteral("Host Controller Service is already running - can't clear the cache data!!");
            return EXIT_FAILURE;
        }

        const QString cacheDir{QStandardPaths::writableLocation(QStandardPaths::AppDataLocation)};
        if (cacheDir.isEmpty()) {
            qWarning() << "Folder with application cached data either not accessible or not found!!";
            return EXIT_FAILURE;
        }
        qDebug() << "Cache location:" << cacheDir;

        for (const auto folder : {QStringLiteral("db"), QStringLiteral("documents")}) {
            QDir dir(QString("%1/%2").arg(cacheDir).arg(folder));
            qInfo() << "Removing" << dir.path() << ":" << dir.removeRecursively();
        }

        return EXIT_SUCCESS;
    }

    const QtLoggerSetup loggerInitialization(app);
    cbLoggerSetup(loggerInitialization.getQtLogCallback());

    qCInfo(logCategoryHcs) << QStringLiteral("================================================================================");
    qCInfo(logCategoryHcs) << QStringLiteral("%1 %2").arg(QCoreApplication::applicationName()).arg(QCoreApplication::applicationVersion());
    qCInfo(logCategoryHcs) << QStringLiteral("Build on %1 at %2").arg(Timestamp::buildTimestamp.data(), Timestamp::buildOnHost.data());
    qCInfo(logCategoryHcs) << QStringLiteral("--------------------------------------------------------------------------------");
    qCInfo(logCategoryHcs) << QStringLiteral("Powered by Qt %1 (based on Qt %2)").arg(QString(qVersion()), qUtf8Printable(QT_VERSION_STR));
    qCInfo(logCategoryHcs) << QStringLiteral("Running on %1").arg(QSysInfo::prettyProductName());
    qCInfo(logCategoryHcs) << QStringLiteral("[arch: %1; kernel: %2 (%3); locale: %4]").arg(QSysInfo::currentCpuArchitecture(), QSysInfo::kernelType(), QSysInfo::kernelVersion(), QLocale::system().name());
    qCInfo(logCategoryHcs) << QStringLiteral("================================================================================");

    if (appGuard.tryToRun() == false) {
        qCCritical(logCategoryHcs) << QStringLiteral("Another instance of Host Controller Service is already running.");
        return EXIT_FAILURE;
    }

#if defined(Q_OS_WIN)
    strata::events_mgr::EvEventsMgrInstance instance;
#endif

#if !defined(Q_OS_WIN)
    SignalHandlers sh(&app);
#endif

    QScopedPointer<HostControllerService> hcs(new HostControllerService);

    const QString config{parser.value(QStringLiteral("f"))};
    if (hcs->initialize(config) == false) {
        return EXIT_FAILURE;
    }

    QObject::connect(&app, &QCoreApplication::aboutToQuit, hcs.get(), &HostControllerService::onAboutToQuit);

    hcs->start();

    return app.exec();
}

