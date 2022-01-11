/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "ConfigFileModel.h"
#include "ConfigFileSettings.h"
#include <QtLoggerSetup.h>
#include "logging/LoggingQtCategories.h"

#include "Version.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml/QQmlContext>
#include <QSettings>
#include <QResource>
#include <QDir>
#include <QIcon>
#include <QQmlFileSelector>

static QJSValue appVersionSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)

    QJSValue appInfo = scriptEngine->newObject();
    appInfo.setProperty("version", QStringLiteral("%1.%2.%3").arg(AppInfo::versionMajor.data()).arg(AppInfo::versionMinor.data()).arg(AppInfo::versionPatch.data()));
    appInfo.setProperty("buildId", AppInfo::buildId.data());
    appInfo.setProperty("gitRevision", AppInfo::gitRevision.data());
    appInfo.setProperty("numberOfCommits", AppInfo::numberOfCommits.data());
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

        qCInfo(lcLcu)
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
        qCCritical(lcLcu) << "failed to find import path.";
    }

    engine->addImportPath(applicationDir.path());

    engine->addImportPath("qrc:///");
}

int main(int argc, char *argv[])
{
    QCoreApplication::setOrganizationName(QStringLiteral("onsemi"));
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QSettings::setDefaultFormat(QSettings::IniFormat);

    QGuiApplication app(argc, argv);
    app.setWindowIcon(QIcon(":/images/lcu-logo.png"));

    const strata::loggers::QtLoggerSetup loggerInitialization(app);
    qCInfo(lcLcu) << QStringLiteral("%1 v%2").arg(QCoreApplication::applicationName(), QCoreApplication::applicationVersion());

    loadResources();

    qmlRegisterType<ConfigFileModel>("tech.strata.lcu", 1, 0, "ConfigFileModel");
    qmlRegisterType<ConfigFileSettings>("tech.strata.lcu", 1, 0, "ConfigFileSettings");

    QQmlApplicationEngine engine;

    qmlRegisterSingletonType("tech.strata.AppInfo", 1, 0, "AppInfo", appVersionSingletonProvider);

    QQmlFileSelector selector(&engine);
    addImportPaths(&engine);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }
    return app.exec();
}
