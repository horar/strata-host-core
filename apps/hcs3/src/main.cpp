/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "HostControllerService.h"

#include "Version.h"
#include "Timestamp.h"
#include "RunGuard.h"

#include "HostControllerServiceNode.h"

#include "logging/LoggingQtCategories.h"

#include <QtLoggerConstants.h>
#include <QtLoggerSetup.h>
#include <CbLoggerSetup.h>

#include <QCoreApplication>
#include <QCommandLineParser>
#include <QSettings>
#include <QStandardPaths>
#include <QDir>

#if !defined(Q_OS_WIN)
#include "unix/SignalHandlers.h"
#endif

using strata::loggers::QtLoggerSetup;
using strata::loggers::cbLoggerSetup;

namespace logConsts = strata::loggers::constants;

int main(int argc, char *argv[])
{
    QSettings::setDefaultFormat(QSettings::IniFormat);
    QCoreApplication::setApplicationName(QStringLiteral("Host Controller Service"));
    QCoreApplication::setApplicationVersion(AppInfo::version.data());
    QCoreApplication::setOrganizationName(QStringLiteral("onsemi"));

    QCoreApplication app(argc, argv);

    QCommandLineParser parser;
    parser.setApplicationDescription("Strata Host Controller Service");
    parser.addOption({
        {QStringLiteral("f")},
        QObject::tr("Optional configuration <filename> (default: AppConfigLocation)."),
        QObject::tr("filename")
    });
    parser.addOption({
        {QStringLiteral("i")},
        QObject::tr("Optional numerical HCS Identifier <identifier> (default: 0)."),
        QObject::tr("identifier")
    });
    parser.addOption({
        {QStringLiteral("c")},
        QObject::tr("Clear cache data of Host Controller Service for <stage>."),
    });
    parser.addPositionalArgument(QStringLiteral("<stage>"),
                                QObject::tr("Specifies folder to be cleared."));
    parser.addVersionOption();
    parser.addHelpOption();
    parser.process(app);

    RunGuard appGuard{"tech.strata.hcs"};

    if (parser.isSet(QStringLiteral("c"))) {
        if (appGuard.tryToRun() == false) {
            qCritical() << QStringLiteral("Host Controller Service is already running - can't clear the cache data!!");
            return EXIT_FAILURE;
        }

        QStringList stageArgs = parser.positionalArguments();
        if (stageArgs.count() == 0 ) {
            qInfo() << "Folder with application cached data not entered. Listing all potential folders:" ;
            QDir dir = QDir(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation));
            dir.setFilter(QDir::AllDirs | QDir::NoDotAndDotDot);

            QStringList list = dir.entryList();
            for (const auto& i : list) {
                qInfo() << i;
            }
            return EXIT_FAILURE;
        }
        else if (stageArgs.count() > 1) {
            qWarning() << "Too many arguments were entered";
            return EXIT_FAILURE;
        }

        QString cacheDir{QStandardPaths::writableLocation(QStandardPaths::AppDataLocation)};
        if (cacheDir.isEmpty()) {
            qWarning() << "Folder with application cached data either not accessible or not found!!";
            return EXIT_FAILURE;
        }
        cacheDir.append(QString("/%1").arg(stageArgs.at(0)).toUpper());
        qDebug() << "Cache location:" << cacheDir;

        QDir dir(cacheDir);
        if (dir.exists() == false) {
            qWarning() << "Choosen folder with application cached data does not exist!";
            return EXIT_FAILURE;
        }

        qInfo() << "Removing" << dir.path() << ":" << dir.removeRecursively();

        return EXIT_SUCCESS;
    }

    const QtLoggerSetup loggerInitialization(app);
    cbLoggerSetup(loggerInitialization.getQtLogCallback());

    qCInfo(logCategoryHcs) << QString(logConsts::LOGLINE_LENGTH, logConsts::LOGLINE_CHAR_MAJOR);
    qCInfo(logCategoryHcs) << QString("%1 %2").arg(QCoreApplication::applicationName(), QCoreApplication::applicationVersion());
    qCInfo(logCategoryHcs) << QString("Build on %1 at %2").arg(Timestamp::buildTimestamp.data(), Timestamp::buildOnHost.data());
    qCInfo(logCategoryHcs) << QString(logConsts::LOGLINE_LENGTH, logConsts::LOGLINE_CHAR_MINOR);
    qCInfo(logCategoryHcs) << QString("Powered by Qt %1 (based on Qt %2)").arg(QString(qVersion()), qUtf8Printable(QT_VERSION_STR));
    qCInfo(logCategoryHcs) << QString("Running on %1").arg(QSysInfo::prettyProductName());
    if (QSslSocket::supportsSsl()) {
        qCInfo(logCategoryHcs) << QString("Using SSL %1 (based on SSL %2)").arg(QSslSocket::sslLibraryVersionString(), QSslSocket::sslLibraryBuildVersionString());
    } else {
        qCCritical(logCategoryHcs) << QString("No SSL support!!");
    }
    qCInfo(logCategoryHcs) << QString("[arch: %1; kernel: %2 (%3); locale: %4]").arg(QSysInfo::currentCpuArchitecture(), QSysInfo::kernelType(), QSysInfo::kernelVersion(), QLocale::system().name());
    qCInfo(logCategoryHcs) << QString(logConsts::LOGLINE_LENGTH, logConsts::LOGLINE_CHAR_MAJOR);

    if (appGuard.tryToRun() == false) {
        qCCritical(logCategoryHcs) << QStringLiteral("Another instance of Host Controller Service is already running.");
        return EXIT_FAILURE + 1; // LC: todo..
    }

    unsigned hcsIdentifier = 0;
    if (parser.isSet(QStringLiteral("i"))) {
        const QString hcsStringIdentifier{parser.value(QStringLiteral("i"))};
        bool ok = true;
        hcsIdentifier = hcsStringIdentifier.toUInt(&ok);
        if (ok == false) {
            qCCritical(logCategoryHcs) << QStringLiteral("Non-numerical identifier provided:") << hcsStringIdentifier;
            return EXIT_FAILURE;
        }
    }

    HostControllerServiceNode hcsNode(hcsIdentifier);
    hcsNode.start(QUrl(QStringLiteral("local:hcs3")));
    QObject::connect(qApp, &QCoreApplication::aboutToQuit,
                     &hcsNode, &HostControllerServiceNode::stop);

#if !defined(Q_OS_WIN)
    SignalHandlers sh(&app);
#endif

    std::unique_ptr<HostControllerService> hcs{std::make_unique<HostControllerService>()};

    const QString config{parser.value(QStringLiteral("f"))};
    if (hcs->initialize(config) == false) {
        return EXIT_FAILURE;
    }

    QObject::connect(&app, &QCoreApplication::aboutToQuit, hcs.get(), &HostControllerService::onAboutToQuit);

    hcs->start();

    return app.exec();
}
