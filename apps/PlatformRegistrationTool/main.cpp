/*
 * Copyright (c) 2018-2022 onsemi.
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

#include "Version.h"

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

namespace logConsts = strata::loggers::constants;
static QJSValue appVersionSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)

    QJSValue appInfo = scriptEngine->newObject();
    appInfo.setProperty("version", QStringLiteral("%1.%2.%3").arg(AppInfo::versionMajor.data()).arg(AppInfo::versionMinor.data()).arg(AppInfo::versionPatch.data()));
    appInfo.setProperty("buildId", AppInfo::buildId.data());
    appInfo.setProperty("gitRevision", AppInfo::gitRevision.data());
    appInfo.setProperty("countOfCommits", AppInfo::countOfCommits.data());
    appInfo.setProperty("stageOfDevelopment", AppInfo::stageOfDevelopment.data());
    appInfo.setProperty("fullVersion", AppInfo::version.data());
    return appInfo;
}

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

        qCInfo(lcPrt)
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
        qCCritical(lcPrt) << "failed to find import path.";
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
    qCInfo(lcPrt) << QString(logConsts::LOGLINE_LENGTH, logConsts::LOGLINE_CHAR_MAJOR);
    qCInfo(lcPrt) << QString("%1 %2").arg(QCoreApplication::applicationName(), QCoreApplication::applicationVersion());
    qCInfo(lcPrt) << QString("Build on %1 at %2").arg(Timestamp::buildTimestamp.data(), Timestamp::buildOnHost.data());
    qCInfo(lcPrt) << QString(logConsts::LOGLINE_LENGTH, logConsts::LOGLINE_CHAR_MINOR);
    qCInfo(lcPrt) << QString("Powered by Qt %1 (based on Qt %2)").arg(QString(qVersion()), qUtf8Printable(QT_VERSION_STR));
    qCInfo(lcPrt) << QString("Running on %1").arg(QSysInfo::prettyProductName());
    if (QSslSocket::supportsSsl()) {
        qCInfo(lcPrt) << QString("Using SSL %1 (based on SSL %2)").arg(QSslSocket::sslLibraryVersionString(), QSslSocket::sslLibraryBuildVersionString());
    } else {
        qCCritical(lcPrt) << QString("No SSL support!!");
    }
    qCInfo(lcPrt) << QString("[arch: %1; kernel: %2 (%3); locale: %4]").arg(QSysInfo::currentCpuArchitecture(), QSysInfo::kernelType(), QSysInfo::kernelVersion(), QLocale::system().name());
    qCInfo(lcPrt) << QString(logConsts::LOGLINE_LENGTH, logConsts::LOGLINE_CHAR_MAJOR);

    loadResources();

    QQmlApplicationEngine engine;
    QQmlFileSelector selector(&engine);

    addImportPaths(&engine);

    qmlRegisterType<PrtModel>("tech.strata.prt", 1, 0, "PrtModel");
    qmlRegisterUncreatableType<strata::PlatformManager>("tech.strata.sci", 1, 0, "PlatformManager", "can not instantiate PlatformManager in qml");
    qmlRegisterUncreatableType<Authenticator>("tech.strata.prt.authenticator", 1, 0, "Authenticator", "can not instantiate Authenticator in qml");
    qmlRegisterUncreatableType<RestClient>("tech.strata.prt.restclient", 1, 0, "RestClient", "can not instantiate RestClient in qml");
    qmlRegisterUncreatableType<Deferred>("tech.strata.prt.restclient", 1, 0, "Deferred", "can not instantiate Deferred in qml");
    qmlRegisterSingletonType("tech.strata.AppInfo", 1, 0, "AppInfo", appVersionSingletonProvider);

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
