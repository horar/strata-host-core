#include <iostream>

#include <QCoreApplication>
#include <QSettings>
#include <QTimer>
#include <QtLoggerSetup.h>
#include "logging/LoggingQtCategories.h"
#include "flasher_cli.h"

int main(int argc, char *argv[]) {
    QCoreApplication app(argc, argv);
    std::cout << "Hello World!" << std::endl;

    QSettings::setDefaultFormat(QSettings::IniFormat);
    QCoreApplication::setOrganizationName(QStringLiteral("ON Semiconductor"));

    const QtLoggerSetup loggerInitialization(app);
    qCInfo(logCategoryFlasherCli) << QStringLiteral("%1 v%2").arg(QCoreApplication::applicationName()).arg(QCoreApplication::applicationVersion());


    strata::FlasherCli flasherCli;

    QObject::connect(&flasherCli, &strata::FlasherCli::finished, &app, &QCoreApplication::exit);

    QTimer::singleShot(0, &flasherCli, &strata::FlasherCli::run);

    return app.exec();
}
