/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "WgModel.h"

#include <SGCore/AppUi.h>

#include "Version.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtWidgets/QApplication>
#include <QQmlContext>
#include <QSettings>
#include <QResource>
#include <QDir>
#include <QIcon>
#include <QQmlFileSelector>
#include <QtLoggerSetup.h>

#include "logging/LoggingQtCategories.h"

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
        QStringLiteral("component-theme.rcc")
    };


#ifdef Q_OS_MACOS
    applicationDir.cdUp();
    applicationDir.cdUp();
    applicationDir.cdUp();
#endif

    for (const auto& resourceName : resources) {
        QString resourcePath = applicationDir.filePath(resourceName);

        qCInfo(lcWg)
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
        qCCritical(lcWg) << "failed to find import path.";
    }

    engine->addImportPath(applicationDir.path());

    engine->addImportPath("qrc:///");
}

void addSupportedPlugins(QQmlFileSelector *selector)
{
    QStringList supportedPlugins{QString(std::string(AppInfo::supportedPlugins_).c_str()).split(QChar(':'))};
    supportedPlugins.removeAll(QString(""));

    if (supportedPlugins.empty() == false) {
        qInfo(lcWg) << "Supported plugins:" << supportedPlugins.join(", ");
        selector->setExtraSelectors(supportedPlugins);

        QDir applicationDir(QCoreApplication::applicationDirPath());
        #ifdef Q_OS_MACOS
            applicationDir.cdUp();
            applicationDir.cdUp();
            applicationDir.cdUp();
        #endif

        for (const auto& pluginName : qAsConst(supportedPlugins)) {
            const QString resourceFile(
                QStringLiteral("%1/plugins/%2.rcc").arg(applicationDir.path(), pluginName));

            if (QFile::exists(resourceFile) == false) {
                qCWarning(lcWg) << QStringLiteral("Resource file for '%1' plugin does not exist.").arg(pluginName);
                continue;
            }
            qCDebug(lcWg) << QStringLiteral("Loading '%1: %2'").arg(resourceFile, QResource::registerResource(resourceFile));
        }
    }
}

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QSettings::setDefaultFormat(QSettings::IniFormat);
    QCoreApplication::setOrganizationName(QStringLiteral("onsemi"));
    QGuiApplication::setApplicationVersion(AppInfo::version.data());

    QApplication app(argc, argv);
    app.setWindowIcon(QIcon(":/images/wg-logo.svg"));

    const strata::loggers::QtLoggerSetup loggerInitialization(app);
    qCInfo(lcWg) << QStringLiteral("%1 %2").arg(QCoreApplication::applicationName()).arg(QCoreApplication::applicationVersion());

    qmlRegisterSingletonType("tech.strata.AppInfo", 1, 0, "AppInfo", appVersionSingletonProvider);

    loadResources();

    WgModel wgModel_;

    QQmlApplicationEngine engine;
    QQmlFileSelector selector(&engine);

    addSupportedPlugins(&selector);
    addImportPaths(&engine);

    engine.rootContext()->setContextProperty("wgModel", &wgModel_);

    QObject::connect(&engine, &QQmlApplicationEngine::warnings, &wgModel_, &WgModel::handleQmlWarning);

    strata::SGCore::AppUi ui(engine, QUrl(QStringLiteral("qrc:/ErrorDialog.qml")));
    QObject::connect(
        &ui, &strata::SGCore::AppUi::uiFails, &app, []() { QCoreApplication::exit(EXIT_FAILURE); },
        Qt::QueuedConnection);

    ui.loadUrl(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
