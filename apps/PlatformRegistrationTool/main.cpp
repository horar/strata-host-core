/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "PrtModel.h"

#include "Timestamp.h"
#include "Version.h"

#include <PlatformManager.h>

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml/QQmlContext>
#include <QSettings>
#include <QResource>
#include <QDir>
#include <QIcon>
#include <QQmlFileSelector>

#include "logging/LoggingQtCategories.h"

#include <QtLoggerConstants.h>
#include <QtLoggerSetup.h>

using strata::loggers::QtLoggerSetup;

namespace constants = strata::loggers::contants;

void loadResources() {
    QDir applicationDir(QCoreApplication::applicationDirPath());

    const auto resources = {
        QStringLiteral("component-fonts.rcc"),
        QStringLiteral("component-common.rcc"),
        QStringLiteral("component-sgwidgets.rcc"),
        QStringLiteral("component-theme.rcc")};

#ifdef Q_OS_MACOS
    applicationDir.cdUp();
    applicationDir.cdUp();
    applicationDir.cdUp();
#endif

    for (const auto& resourceName : resources) {
        QString resourcePath = applicationDir.filePath(resourceName);

        qCInfo(logCategoryPrt)
                << "Loading"
                << resourceName << ":"
                << QResource::registerResource(resourcePath);
    }
}

void addImportPaths(QQmlApplicationEngine *engine) {
    QDir applicationDir(QCoreApplication::applicationDirPath());

#ifdef Q_OS_MACOS
    applicationDir.cdUp();
    applicationDir.cdUp();
    applicationDir.cdUp();
#endif

    bool status = applicationDir.cd("imports");
    if (status == false) {
        qCCritical(logCategoryPrt) << "failed to find import path.";
    }

    engine->addImportPath(applicationDir.path());

    engine->addImportPath("qrc:///");
}

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QSettings::setDefaultFormat(QSettings::IniFormat);
    QCoreApplication::setOrganizationName(QStringLiteral("onsemi"));
    QCoreApplication::setApplicationVersion(AppInfo::version.data());

    QGuiApplication app(argc, argv);
    app.setWindowIcon(QIcon(":/images/prt-logo.svg"));

    const QtLoggerSetup loggerInitialization(app);
    qCInfo(logCategoryPrt) << QString(constants::LOGLINE_LENGTH, constants::LOGLINE_CHAR_MAJOR);
    qCInfo(logCategoryPrt) << QString("%1 %2").arg(QCoreApplication::applicationName(), QCoreApplication::applicationVersion());
    qCInfo(logCategoryPrt) << QString("Build on %1 at %2").arg(Timestamp::buildTimestamp.data(), Timestamp::buildOnHost.data());
    qCInfo(logCategoryPrt) << QString(constants::LOGLINE_LENGTH, constants::LOGLINE_CHAR_MINOR);
    qCInfo(logCategoryPrt) << QString("Powered by Qt %1 (based on Qt %2)").arg(QString(qVersion()), qUtf8Printable(QT_VERSION_STR));
    qCInfo(logCategoryPrt) << QString("Running on %1").arg(QSysInfo::prettyProductName());
    if (QSslSocket::supportsSsl()) {
        qCInfo(logCategoryPrt) << QString("Using SSL %1 (based on SSL %2)").arg(QSslSocket::sslLibraryVersionString(), QSslSocket::sslLibraryBuildVersionString());
    } else {
        qCCritical(logCategoryPrt) << QString("No SSL support!!");
    }
    qCInfo(logCategoryPrt) << QString("[arch: %1; kernel: %2 (%3); locale: %4]").arg(QSysInfo::currentCpuArchitecture(), QSysInfo::kernelType(), QSysInfo::kernelVersion(), QLocale::system().name());
    qCInfo(logCategoryPrt) << QString(constants::LOGLINE_LENGTH, constants::LOGLINE_CHAR_MAJOR);

    loadResources();

    QQmlApplicationEngine engine;
    QQmlFileSelector selector(&engine);

    addImportPaths(&engine);

    qmlRegisterType<PrtModel>("tech.strata.prt", 1, 0, "PrtModel");
    qmlRegisterUncreatableType<strata::PlatformManager>("tech.strata.sci", 1, 0, "PlatformManager", "can not instantiate PlatformManager in qml");
    qmlRegisterUncreatableType<Authenticator>("tech.strata.prt.authenticator", 1, 0, "Authenticator", "can not instantiate Authenticator in qml");
    qmlRegisterUncreatableType<RestClient>("tech.strata.prt.restclient", 1, 0, "RestClient", "can not instantiate RestClient in qml");
    qmlRegisterUncreatableType<Deferred>("tech.strata.prt.restclient", 1, 0, "Deferred", "can not instantiate Deferred in qml");

    qmlRegisterUncreatableType<strata::FlasherConnector>("tech.strata.flasherConnector", 1, 0, "FlasherConnector", "can not instantiate FlasherConnector in qml");
    qRegisterMetaType<strata::FlasherConnector::Operation>();
    qRegisterMetaType<strata::FlasherConnector::State>();
    qRegisterMetaType<strata::FlasherConnector::Result>();

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
