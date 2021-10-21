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

#include <QtLoggerConstants.h>
#include <QtLoggerSetup.h>

#include "logging/LoggingQtCategories.h"

#include "Commands.h"
#include "CliParser.h"

#include "Version.h"
#include "Timestamp.h"

using strata::loggers::QtLoggerSetup;

namespace constants = strata::loggers::contants;

int main(int argc, char *argv[]) {
    QSettings::setDefaultFormat(QSettings::IniFormat);
    QCoreApplication::setOrganizationName(QStringLiteral("onsemi"));
    QCoreApplication::setApplicationVersion(AppInfo::version.data());

    QCoreApplication app(argc, argv);

    const QtLoggerSetup loggerInitialization(app);
    qCDebug(logCategoryFlasherCli) << QString(constants::LOGLINE_LENGTH, constants::LOGLINE_CHAR_MAJOR);
    qCDebug(logCategoryFlasherCli) << QString("%1 %2").arg(QCoreApplication::applicationName(), QCoreApplication::applicationVersion());
    qCDebug(logCategoryFlasherCli) << QString("Build on %1 at %2").arg(Timestamp::buildTimestamp.data(), Timestamp::buildOnHost.data());
    qCDebug(logCategoryFlasherCli) << QString(constants::LOGLINE_LENGTH, constants::LOGLINE_CHAR_MINOR);
    qCDebug(logCategoryFlasherCli) << QString("Powered by Qt %1 (based on Qt %2)").arg(QString(qVersion()), qUtf8Printable(QT_VERSION_STR));
    qCDebug(logCategoryFlasherCli) << QString("Running on %1").arg(QSysInfo::prettyProductName());
    qCDebug(logCategoryFlasherCli) << QString("[arch: %1; kernel: %2 (%3); locale: %4]").arg(QSysInfo::currentCpuArchitecture(), QSysInfo::kernelType(), QSysInfo::kernelVersion(), QLocale::system().name());
    qCDebug(logCategoryFlasherCli) << QString(constants::LOGLINE_LENGTH, constants::LOGLINE_CHAR_MAJOR);

    strata::CliParser parser(QCoreApplication::arguments());

    strata::CommandShPtr command = parser.parse();

    QObject::connect(command.get(), &strata::Command::finished, &app, &QCoreApplication::exit, Qt::QueuedConnection);

    QTimer::singleShot(0, command.get(), &strata::Command::process);

    return app.exec();
}
