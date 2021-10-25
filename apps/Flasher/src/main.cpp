/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include <QCommandLineParser>
#include <QCoreApplication>
#include <QObject>
#include <QSettings>
#include <QTimer>

#include <QtLoggerConstants.h>
#include <QtLoggerSetup.h>

#include "logging/LoggingQtCategories.h"

#include "CliParser.h"

#include "Timestamp.h"
#include "Version.h"

using strata::flashercli::CommandShPtr;
using strata::flashercli::CliParser;
using strata::flashercli::commands::Command;
using strata::loggers::QtLoggerSetup;

namespace logConsts = strata::loggers::constants;

int main(int argc, char *argv[])
{
    QSettings::setDefaultFormat(QSettings::IniFormat);
    QCoreApplication::setOrganizationName(QStringLiteral("onsemi"));
    QCoreApplication::setApplicationVersion(AppInfo::version.data());

    QCoreApplication app(argc, argv);

    const QtLoggerSetup loggerInitialization(app);
    qCDebug(lcFlasherCli) << QString(logConsts::LOGLINE_LENGTH, logConsts::LOGLINE_CHAR_MAJOR);
    qCDebug(lcFlasherCli) << QString("%1 %2").arg(QCoreApplication::applicationName(), QCoreApplication::applicationVersion());
    qCDebug(lcFlasherCli) << QString("Build on %1 at %2").arg(Timestamp::buildTimestamp.data(), Timestamp::buildOnHost.data());
    qCDebug(lcFlasherCli) << QString(logConsts::LOGLINE_LENGTH, logConsts::LOGLINE_CHAR_MINOR);
    qCDebug(lcFlasherCli) << QString("Powered by Qt %1 (based on Qt %2)").arg(QString(qVersion()), qUtf8Printable(QT_VERSION_STR));
    qCDebug(lcFlasherCli) << QString("Running on %1").arg(QSysInfo::prettyProductName());
    qCDebug(lcFlasherCli) << QString("[arch: %1; kernel: %2 (%3); locale: %4]").arg(QSysInfo::currentCpuArchitecture(), QSysInfo::kernelType(), QSysInfo::kernelVersion(), QLocale::system().name());
    qCDebug(lcFlasherCli) << QString(logConsts::LOGLINE_LENGTH, logConsts::LOGLINE_CHAR_MAJOR);

    CliParser parser(QCoreApplication::arguments());
    CommandShPtr command = parser.parse();

    QObject::connect(command.get(), &Command::finished, &app, &QCoreApplication::exit, Qt::QueuedConnection);

    QTimer::singleShot(0, command.get(), &Command::process);

    return app.exec();
}
