/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
#include "Timestamp.h"

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
