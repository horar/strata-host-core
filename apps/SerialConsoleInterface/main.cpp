/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include <PlatformManager.h>
#include <Mock/MockDevice.h>
#include "SciModel.h"
#include "HexModel.h"

#include <SGCore/AppUi.h>

#include "Version.h"
#include "Timestamp.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSettings>
#include <QResource>
#include <QIcon>
#include <QDir>
#include <QQmlFileSelector>
#include <QSslSocket>
#ifdef Q_OS_WIN
#include <QVersionNumber>
#endif

#include <QtLoggerConstants.h>
#include <QtLoggerSetup.h>

#include "logging/LoggingQtCategories.h"

using strata::loggers::QtLoggerSetup;

namespace logConsts = strata::loggers::constants;
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
        QStringLiteral("component-sgwidgets.rcc"),
        QStringLiteral("component-fonts.rcc"),
        QStringLiteral("component-theme.rcc")
    };

#ifdef Q_OS_MACOS
    applicationDir.cdUp();
    applicationDir.cdUp();
    applicationDir.cdUp();
#endif

    for (const auto& resourceName : resources) {
        QString resourcePath = applicationDir.filePath(resourceName);

        qCInfo(lcSci)
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
        qCCritical(lcSci) << "failed to find import path.";
    }

    engine->addImportPath(applicationDir.path());

    engine->addImportPath("qrc:///");
}

void addSupportedPlugins(QQmlFileSelector *selector)
{
    QStringList supportedPlugins{QString(std::string(AppInfo::supportedPlugins_).c_str()).split(QChar(':'))};
    supportedPlugins.removeAll(QString(""));

    if (supportedPlugins.empty() == false) {
        qInfo(lcSci) << "Supported plugins:" << supportedPlugins.join(", ");
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
                qCWarning(lcSci) << QStringLiteral("Resource file for '%1' plugin does not exist.").arg(pluginName);
                continue;
            }
            qCDebug(lcSci) << QStringLiteral("Loading '%1: %2'").arg(resourceFile, QResource::registerResource(resourceFile));
        }
    }
}

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QSettings::setDefaultFormat(QSettings::IniFormat);
    QCoreApplication::setOrganizationName(QStringLiteral("onsemi"));
    QGuiApplication::setApplicationVersion(AppInfo::version.data());

    QGuiApplication app(argc, argv);
    app.setWindowIcon(QIcon(":/images/sci-logo.svg"));

    const QtLoggerSetup loggerInitialization(app);
    qCInfo(lcSci) << QString(logConsts::LOGLINE_LENGTH, logConsts::LOGLINE_CHAR_MAJOR);
    qCInfo(lcSci) << QString("%1 %2").arg(QCoreApplication::applicationName(), QCoreApplication::applicationVersion());
    qCInfo(lcSci) << QString("Build on %1 at %2").arg(Timestamp::buildTimestamp.data(), Timestamp::buildOnHost.data());
    qCInfo(lcSci) << QString(logConsts::LOGLINE_LENGTH, logConsts::LOGLINE_CHAR_MINOR);
    qCInfo(lcSci) << QString("Powered by Qt %1 (based on Qt %2)").arg(QString(qVersion()), qUtf8Printable(QT_VERSION_STR));

#if defined(Q_OS_WIN)
    QVersionNumber kernelVersion = QVersionNumber::fromString(QSysInfo::kernelVersion());
    if ((kernelVersion.majorVersion() == 10) &&
        (kernelVersion.minorVersion() == 0) &&
        (kernelVersion.microVersion() >= 21996)) {
        qCInfo(lcSci).nospace() << "Running on Windows 11 (" << kernelVersion.majorVersion() << "." << kernelVersion.minorVersion() << ")";
    } else {
        qCInfo(lcSci) << QString("Running on %1").arg(QSysInfo::prettyProductName());
    }
#else
    qCInfo(lcSci) << QString("Running on %1").arg(QSysInfo::prettyProductName());
#endif

    if (QSslSocket::supportsSsl()) {
        qCInfo(lcSci) << QString("Using SSL %1 (based on SSL %2)").arg(QSslSocket::sslLibraryVersionString(), QSslSocket::sslLibraryBuildVersionString());
    } else {
        qCCritical(lcSci) << QString("No SSL support!!");
    }
    qCInfo(lcSci) << QString("[arch: %1; kernel: %2 (%3); locale: %4]").arg(QSysInfo::currentCpuArchitecture(), QSysInfo::kernelType(), QSysInfo::kernelVersion(), QLocale::system().name());
    qCInfo(lcSci) << QString(logConsts::LOGLINE_LENGTH, logConsts::LOGLINE_CHAR_MAJOR);

    qmlRegisterUncreatableType<SciModel>("tech.strata.sci", 1, 0, "SciModel", "cannot instantiate SciModel in qml");
    qmlRegisterUncreatableType<SciPlatformModel>("tech.strata.sci", 1, 0, "SciPlatformModel", "cannot instantiate SciPlatformModel in qml");
    qmlRegisterUncreatableType<SciPlatform>("tech.strata.sci", 1, 0, "SciPlatform", "cannot instantiate SciPlatform in qml");
    qmlRegisterUncreatableType<SciScrollbackModel>("tech.strata.sci", 1, 0, "SciScrollbackModel", "cannot instantiate SciScrollbackModel in qml");
    qmlRegisterUncreatableType<SciCommandHistoryModel>("tech.strata.sci", 1, 0, "SciCommandHistoryModel", "cannot instantiate SciCommandHistoryModel in qml");
    qmlRegisterUncreatableType<SciFilterSuggestionModel>("tech.strata.sci", 1, 0, "SciFilterSuggestionModel", "cannot instantiate SciFilterSuggestionModel in qml");
    qmlRegisterUncreatableType<SciFilterScrollbackModel>("tech.strata.sci", 1, 0, "SciFilterScrollbackModel", "cannot instantiate SciFilterScrollbackModel in qml");
    qmlRegisterUncreatableType<SciSearchScrollbackModel>("tech.strata.sci", 1, 0, "SciSearchScrollbackModel", "cannot instantiate SciSearchScrollbackModel in qml");
    qmlRegisterUncreatableType<SciMessageQueueModel>("tech.strata.sci", 1, 0, "SciMessageQueueModel", "cannot instantiate SciMessageQueueModel in qml");
    qmlRegisterUncreatableType<strata::PlatformManager>("tech.strata.sci", 1, 0, "PlatformManager", "can not instantiate PlatformManager in qml");
    qmlRegisterUncreatableType<SciMockDeviceModel>("tech.strata.sci", 1, 0, "SciMockDeviceModel", "cannot instantiate SciMockDeviceModel in qml");
    qmlRegisterUncreatableType<SciMockCommandModel>("tech.strata.sci", 1, 0, "SciMockCommandModel", "cannot instantiate SciMockCommandModel in qml");
    qmlRegisterUncreatableType<SciMockResponseModel>("tech.strata.sci", 1, 0, "SciMockResponseModel", "cannot instantiate SciMockResponseModel in qml");
    qmlRegisterUncreatableType<SciMockVersionModel>("tech.strata.sci", 1, 0, "SciMockVersionModel", "cannot instantiate SciMockVersionModel in qml");
#ifdef APPS_FEATURE_BLE
    qmlRegisterUncreatableType<SciBleDeviceModel>("tech.strata.sci", 1, 0, "SciBleDeviceModel", "cannot instantiate SciBleDeviceModel in qml");
#endif // APPS_FEATURE_BLE

    qmlRegisterUncreatableType<strata::device::MockDevice>("tech.strata.sci", 1, 0, "MockDevice", "cannot instantiate MockDevice in qml");
    qRegisterMetaType<strata::device::MockCommand>("MockCommand");
    qRegisterMetaType<strata::device::MockResponse>("MockResponse");
    qRegisterMetaType<strata::device::MockVersion>("MockVersion");

    qmlRegisterSingletonType(QUrl("qrc:/SciSettings.qml"), "tech.strata.sci", 1, 0, "Settings");

    qmlRegisterUncreatableType<strata::FlasherConnector>("tech.strata.flasherConnector", 1, 0, "FlasherConnector", "can not instantiate FlasherConnector in qml");
    qRegisterMetaType<strata::FlasherConnector::Operation>();
    qRegisterMetaType<strata::FlasherConnector::State>();
    qRegisterMetaType<strata::FlasherConnector::Result>();

    qmlRegisterType<HexModel>("tech.strata.sci", 1, 0, "HexModel");
    qmlRegisterSingletonType("tech.strata.AppInfo", 1, 0, "AppInfo", appVersionSingletonProvider);

    qmlRegisterUncreatableType<SciPlatformTestModel>("tech.strata.sci", 1, 0, "SciPlatformTestModel", "cannot instantiate SciPlatformTestModel in qml");
    qmlRegisterUncreatableType<SciPlatformTestMessageModel>("tech.strata.sci", 1, 0, "SciPlatformTestMessageModel", "cannot instantiate SciPlatformTestMessageModel in qml");


    loadResources();

    // make sure that objects in context properties are declared before engine, to maintain proper order of destruction
    SciModel sciModel_;

    QQmlApplicationEngine engine;
    QQmlFileSelector selector(&engine);

    addSupportedPlugins(&selector);
    addImportPaths(&engine);

    engine.rootContext()->setContextProperty("sciModel", &sciModel_);

    QObject::connect(&engine, &QQmlApplicationEngine::warnings, &sciModel_, &SciModel::handleQmlWarning);

    strata::SGCore::AppUi ui(engine, QUrl(QStringLiteral("qrc:/ErrorDialog.qml")));
    QObject::connect(
        &ui, &strata::SGCore::AppUi::uiFails, &app, []() { QCoreApplication::exit(EXIT_FAILURE); },
        Qt::QueuedConnection);

#ifdef APPS_FEATURE_BLE
    engine.rootContext()->setContextProperty("APPS_FEATURE_BLE", QVariant(APPS_FEATURE_BLE));
#endif // APPS_FEATURE_BLE

    ui.loadUrl(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
