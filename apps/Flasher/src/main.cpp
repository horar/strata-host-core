#include <QCoreApplication>
#include <QSettings>
#include <QCommandLineParser>
#include <QObject>
#include <QTimer>
#include <QtLoggerSetup.h>

#include "logging/LoggingQtCategories.h"
#include "Commands.h"
#include "CliParser.h"

#include "Version.h"  // CMake generated file

int main(int argc, char *argv[]) {
    QCoreApplication app(argc, argv);

    QSettings::setDefaultFormat(QSettings::IniFormat);
    QCoreApplication::setOrganizationName(QStringLiteral("onsemi"));
    QCoreApplication::setApplicationVersion(AppInfo::version.data());

    const strata::loggers::QtLoggerSetup loggerInitialization(app);
    qCDebug(logCategoryFlasherCli).noquote() << QStringLiteral("%1 %2").arg(QCoreApplication::applicationName()).arg(QCoreApplication::applicationVersion());

    strata::CliParser parser(QCoreApplication::arguments());

    strata::CommandShPtr command = parser.parse();

    QObject::connect(command.get(), &strata::Command::finished, &app, &QCoreApplication::exit, Qt::QueuedConnection);

    QTimer::singleShot(0, command.get(), &strata::Command::process);

    return app.exec();
}
