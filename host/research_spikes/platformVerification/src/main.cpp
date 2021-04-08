#include "Version.h"
#include "Timestamp.h"
#include "Verificator.h"
#include "logging/LoggingQtCategories.h"
#include <QtLoggerSetup.h>

#include <QCoreApplication>
#include <QCommandLineParser>
#include <QSettings>
#include <QStandardPaths>
#include <QDir>

int main(int argc, char *argv[])
{
    QSettings::setDefaultFormat(QSettings::IniFormat);
    QCoreApplication::setApplicationName(QStringLiteral("Platform Verification"));
    QCoreApplication::setApplicationVersion(AppInfo::version.data());
    QCoreApplication::setOrganizationName(QStringLiteral("ON Semiconductor"));

    QCoreApplication app(argc, argv);

    const strata::loggers::QtLoggerSetup loggerInitialization(app);

    qCInfo(logCategoryPlatformVerification) << QStringLiteral("================================================================================");
    qCInfo(logCategoryPlatformVerification) << QStringLiteral("%1 %2").arg(QCoreApplication::applicationName()).arg(QCoreApplication::applicationVersion());
    qCInfo(logCategoryPlatformVerification) << QStringLiteral("Build on %1 at %2").arg(Timestamp::buildTimestamp.data(), Timestamp::buildOnHost.data());
    qCInfo(logCategoryPlatformVerification) << QStringLiteral("--------------------------------------------------------------------------------");
    qCInfo(logCategoryPlatformVerification) << QStringLiteral("Powered by Qt %1 (based on Qt %2)").arg(QString(qVersion()), qUtf8Printable(QT_VERSION_STR));
    qCInfo(logCategoryPlatformVerification) << QStringLiteral("Running on %1").arg(QSysInfo::prettyProductName());
    qCInfo(logCategoryPlatformVerification) << QStringLiteral("[arch: %1; kernel: %2 (%3); locale: %4]").arg(QSysInfo::currentCpuArchitecture(), QSysInfo::kernelType(), QSysInfo::kernelVersion(), QLocale::system().name());
    qCInfo(logCategoryPlatformVerification) << QStringLiteral("================================================================================");

    strata::Verificator verificator;

    QObject::connect(qApp, &QCoreApplication::aboutToQuit,
                     &verificator, &strata::Verificator::stop);

    verificator.start();

    return app.exec();
}
