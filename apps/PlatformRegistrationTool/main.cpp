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
#include <SGCore/AppUi.h>

#include "Version.h"

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

#include "logging/LoggingQtCategories.h"

#include <QtLoggerConstants.h>
#include <QtLoggerSetup.h>

using strata::loggers::QtLoggerSetup;

namespace logConsts = strata::loggers::constants;
static QJSValue appVersionSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)

    QJSValue appInfo = scriptEngine->newObject();
    appInfo.setProperty("version", QStringLiteral("%1.%2.%3").arg(AppInfo::versionMajor.data(), AppInfo::versionMinor.data(), AppInfo::versionPatch.data()));
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

void addSupportedPlugins(QQmlFileSelector *selector)
{
    QStringList supportedPlugins{QString(std::string(AppInfo::supportedPlugins_).c_str()).split(QChar(':'))};
    supportedPlugins.removeAll(QString(""));

    if (supportedPlugins.empty() == false) {
        qInfo(lcPrt) << "Supported plugins:" << supportedPlugins.join(", ");
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
                qCWarning(lcPrt) << QStringLiteral("Resource file for '%1' plugin does not exist.").arg(pluginName); 
                continue;
            }
            qCDebug(lcPrt) << QStringLiteral("Loading '%1: %2'").arg(resourceFile, QResource::registerResource(resourceFile));
        }
    }
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

#if defined(Q_OS_WIN)
    QVersionNumber kernelVersion = QVersionNumber::fromString(QSysInfo::kernelVersion());
    if ((kernelVersion.majorVersion() == 10) &&
        (kernelVersion.minorVersion() == 0) &&
        (kernelVersion.microVersion() >= 21996)) {
        qCInfo(lcPrt).nospace() << "Running on Windows 11 (" << kernelVersion.majorVersion() << "." << kernelVersion.minorVersion() << ")";
    } else {
        qCInfo(lcPrt) << QString("Running on %1").arg(QSysInfo::prettyProductName());
    }
#else
    qCInfo(lcPrt) << QString("Running on %1").arg(QSysInfo::prettyProductName());
#endif

    if (QSslSocket::supportsSsl()) {
        qCInfo(lcPrt) << QString("Using SSL %1 (based on SSL %2)").arg(QSslSocket::sslLibraryVersionString(), QSslSocket::sslLibraryBuildVersionString());
    } else {
        qCCritical(lcPrt) << QString("No SSL support!!");
    }
    qCInfo(lcPrt) << QString("[arch: %1; kernel: %2 (%3); locale: %4]").arg(QSysInfo::currentCpuArchitecture(), QSysInfo::kernelType(), QSysInfo::kernelVersion(), QLocale::system().name());
    qCInfo(lcPrt) << QString(logConsts::LOGLINE_LENGTH, logConsts::LOGLINE_CHAR_MAJOR);

    loadResources();

    PrtModel prtModel_;

    QQmlApplicationEngine engine;
    QQmlFileSelector selector(&engine);

    addSupportedPlugins(&selector);
    addImportPaths(&engine);

    qmlRegisterUncreatableType<PrtModel>("tech.strata.prt", 1, 0, "PrtModel", "can not instantiate PrtModel in qml");
    qmlRegisterUncreatableType<strata::PlatformManager>("tech.strata.sci", 1, 0, "PlatformManager", "can not instantiate PlatformManager in qml");
    qmlRegisterUncreatableType<Authenticator>("tech.strata.prt.authenticator", 1, 0, "Authenticator", "can not instantiate Authenticator in qml");
    qmlRegisterUncreatableType<RestClient>("tech.strata.prt.restclient", 1, 0, "RestClient", "can not instantiate RestClient in qml");
    qmlRegisterUncreatableType<Deferred>("tech.strata.prt.restclient", 1, 0, "Deferred", "can not instantiate Deferred in qml");
    qmlRegisterSingletonType("tech.strata.AppInfo", 1, 0, "AppInfo", appVersionSingletonProvider);

    qmlRegisterUncreatableType<strata::FlasherConnector>("tech.strata.flasherConnector", 1, 0, "FlasherConnector", "can not instantiate FlasherConnector in qml");
    qRegisterMetaType<strata::FlasherConnector::Operation>();
    qRegisterMetaType<strata::FlasherConnector::State>();
    qRegisterMetaType<strata::FlasherConnector::Result>();

    engine.rootContext()->setContextProperty("prtModel", &prtModel_);

    QObject::connect(&engine, &QQmlApplicationEngine::warnings, &prtModel_, &PrtModel::handleQmlWarning);

    strata::SGCore::AppUi ui(engine, QUrl(QStringLiteral("qrc:/ErrorDialog.qml")));
    QObject::connect(
        &ui, &strata::SGCore::AppUi::uiFails, &app, []() { QCoreApplication::exit(EXIT_FAILURE); },
        Qt::QueuedConnection);

    ui.loadUrl(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
