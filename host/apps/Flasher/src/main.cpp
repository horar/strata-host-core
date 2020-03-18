#include <cstdlib>

#include <QCoreApplication>
#include <QSettings>
#include <QCommandLineParser>
#include <QTimer>
#include <QtLoggerSetup.h>

#include "logging/LoggingQtCategories.h"
#include "FlasherCli.h"

#include "flasher-cliVersion.h"  // CMake generated file

int main(int argc, char *argv[]) {
    QCoreApplication app(argc, argv);

    QSettings::setDefaultFormat(QSettings::IniFormat);
    QCoreApplication::setOrganizationName(QStringLiteral("ON Semiconductor"));
    QCoreApplication::setApplicationVersion(AppInfo::version.data());

    const QtLoggerSetup loggerInitialization(app);
    qCInfo(logCategoryFlasherCli) << QStringLiteral("%1 %2").arg(QCoreApplication::applicationName()).arg(QCoreApplication::applicationVersion());

    QCommandLineOption listOption(QStringList() << QStringLiteral("l") << QStringLiteral("list"),
                                  QStringLiteral("List of connected boards (serial devices)."));
    QCommandLineOption flashOption(QStringList() << QStringLiteral("f") << QStringLiteral("flash"),
                                   QStringLiteral("Flash firmware from <file> to board specified by 'device' option."), QStringLiteral("file"));
    QCommandLineOption deviceOption(QStringList() << QStringLiteral("d") << QStringLiteral("device"),
                                    QStringLiteral("Board number from 'list' option. Default is 1."), QStringLiteral("number"));
    QCommandLineParser parser;
    parser.setApplicationDescription(QStringLiteral("Flasher CLI"));
    parser.addHelpOption();
    parser.addOption(listOption);
    parser.addOption(flashOption);
    parser.addOption(deviceOption);

    if (parser.parse(QCoreApplication::arguments()) == false) {
        qCWarning(logCategoryFlasherCli).noquote() << parser.errorText();
        return EXIT_FAILURE;
    }

    if (parser.isSet(QStringLiteral("h"))) {
        qCInfo(logCategoryFlasherCli).noquote() << parser.helpText();
        return EXIT_SUCCESS;
    }

    strata::CliOptions options;

    if (parser.isSet(listOption)) {
        options.option = strata::CliOptions::Option::list;
    } else if (parser.isSet(flashOption)) {
        options.option = strata::CliOptions::Option::flash;
        options.file_name = parser.value(flashOption);
    }

    if (parser.isSet(deviceOption)) {
        QString number = parser.value(deviceOption);
        bool ok;
        options.device_number = number.toInt(&ok);
        if (ok == false) {
            qCWarning(logCategoryFlasherCli).noquote().nospace() << '\'' << number << "' is not a valid device number.";
            return EXIT_FAILURE;
        }
    }

    if (options.option == strata::CliOptions::Option::none) {
        qCWarning(logCategoryFlasherCli) << "Missing command line options!";
        qCInfo(logCategoryFlasherCli).noquote() << parser.helpText();
        return EXIT_FAILURE;
    }

    strata::FlasherCli flasherCli(options);

    QObject::connect(&flasherCli, &strata::FlasherCli::finished, &app, &QCoreApplication::exit, Qt::QueuedConnection);

    QTimer::singleShot(0, &flasherCli, &strata::FlasherCli::run);

    return app.exec();
}
