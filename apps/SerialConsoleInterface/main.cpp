/*
 * Copyright (c) 2018-2021 onsemi.
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

#include "Version.h"
#include "Timestamp.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSettings>
#include <QResource>
#include <QDir>
#include <QtWebEngine>

#include <QtLoggerConstants.h>
#include <QtLoggerSetup.h>

#include "logging/LoggingQtCategories.h"

using strata::loggers::QtLoggerSetup;

namespace constants = strata::loggers::contants;

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

        qCInfo(logCategorySci)
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
        qCCritical(logCategorySci) << "failed to find import path.";
    }

    engine->addImportPath(applicationDir.path());

    engine->addImportPath("qrc:///");
}

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QSettings::setDefaultFormat(QSettings::IniFormat);
    QCoreApplication::setOrganizationName(QStringLiteral("onsemi"));
    QGuiApplication::setApplicationVersion(AppInfo::version.data());

    QGuiApplication app(argc, argv);
    app.setWindowIcon(QIcon(":/images/sci-logo.svg"));

    QtWebEngine::initialize();

    const QtLoggerSetup loggerInitialization(app);
    qCInfo(logCategorySci) << QString(constants::LOGLINE_LENGTH, constants::LOGLINE_CHAR_MAJOR);
    qCInfo(logCategorySci) << QString("%1 %2").arg(QCoreApplication::applicationName(), QCoreApplication::applicationVersion());
    qCInfo(logCategorySci) << QString("Build on %1 at %2").arg(Timestamp::buildTimestamp.data(), Timestamp::buildOnHost.data());
    qCInfo(logCategorySci) << QString(constants::LOGLINE_LENGTH, constants::LOGLINE_CHAR_MINOR);
    qCInfo(logCategorySci) << QString("Powered by Qt %1 (based on Qt %2)").arg(QString(qVersion()), qUtf8Printable(QT_VERSION_STR));
    qCInfo(logCategorySci) << QString("Running on %1").arg(QSysInfo::prettyProductName());
    if (QSslSocket::supportsSsl()) {
        qCInfo(logCategorySci) << QString("Using SSL %1 (based on SSL %2)").arg(QSslSocket::sslLibraryVersionString(), QSslSocket::sslLibraryBuildVersionString());
    } else {
        qCCritical(logCategorySci) << QString("No SSL support!!");
    }
    qCInfo(logCategorySci) << QString("[arch: %1; kernel: %2 (%3); locale: %4]").arg(QSysInfo::currentCpuArchitecture(), QSysInfo::kernelType(), QSysInfo::kernelVersion(), QLocale::system().name());
    qCInfo(logCategorySci) << QString(constants::LOGLINE_LENGTH, constants::LOGLINE_CHAR_MAJOR);

    qmlRegisterUncreatableType<SciModel>("tech.strata.sci", 1, 0, "SciModel", "cannot instantiate SciModel in qml");
    qmlRegisterUncreatableType<SciPlatformModel>("tech.strata.sci", 1, 0, "SciPlatformModel", "cannot instantiate SciPlatformModel in qml");
    qmlRegisterUncreatableType<SciPlatform>("tech.strata.sci", 1, 0, "SciPlatform", "cannot instantiate SciPlatform in qml");
    qmlRegisterUncreatableType<SciScrollbackModel>("tech.strata.sci", 1, 0, "SciScrollbackModel", "cannot instantiate SciScrollbackModel in qml");
    qmlRegisterUncreatableType<SciCommandHistoryModel>("tech.strata.sci", 1, 0, "SciCommandHistoryModel", "cannot instantiate SciCommandHistoryModel in qml");
    qmlRegisterUncreatableType<SciFilterSuggestionModel>("tech.strata.sci", 1, 0, "SciFilterSuggestionModel", "cannot instantiate SciFilterSuggestionModel in qml");
    qmlRegisterUncreatableType<SciFilterScrollbackModel>("tech.strata.sci", 1, 0, "SciFilterScrollbackModel", "cannot instantiate SciFilterScrollbackModel in qml");
    qmlRegisterUncreatableType<SciSearchScrollbackModel>("tech.strata.sci", 1, 0, "SciSearchScrollbackModel", "cannot instantiate SciSearchScrollbackModel in qml");
    qmlRegisterUncreatableType<strata::PlatformManager>("tech.strata.sci", 1, 0, "PlatformManager", "can not instantiate PlatformManager in qml");
    qmlRegisterUncreatableType<SciMockDeviceModel>("tech.strata.sci", 1, 0, "SciMockDeviceModel", "cannot instantiate SciMockDeviceModel in qml");
    qmlRegisterUncreatableType<SciMockCommandModel>("tech.strata.sci", 1, 0, "SciMockCommandModel", "cannot instantiate SciMockCommandModel in qml");
    qmlRegisterUncreatableType<SciMockResponseModel>("tech.strata.sci", 1, 0, "SciMockResponseModel", "cannot instantiate SciMockResponseModel in qml");
    qmlRegisterUncreatableType<SciMockVersionModel>("tech.strata.sci", 1, 0, "SciMockVersionModel", "cannot instantiate SciMockVersionModel in qml");

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

    loadResources();

    // make sure that objects in context properties are declared before engine, to maintain proper order of destruction
    SciModel sciModel_;

    QQmlApplicationEngine engine;

    addImportPaths(&engine);

    engine.rootContext()->setContextProperty("sciModel", &sciModel_);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        qCCritical(logCategorySci) << "engine failed to load 'main' qml file; quitting...";
        return -1;
    }

    return app.exec();
}
