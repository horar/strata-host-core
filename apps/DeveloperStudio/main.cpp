/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtWebView/QtWebView>
#include <QtWebEngine>
#include <QtWidgets/QApplication>
#include <QtQml/QQmlContext>
#include <QtQuick/QQuickView>
#include <QtQml/QQmlEngine>
#include <QtCore/QDir>
#include "QtDebug"
#include <QProcess>
#include <QSettings>
#include <QSysInfo>
#include <QSslSocket>

#include <PlatformInterface/core/CoreInterface.h>
#include <StrataRPC/StrataClient.h>
#include <SGCore/AppUi.h>

#include "Version.h"
#include "Timestamp.h"

#include "logging/LoggingQtCategories.h"

#include <QtLoggerConstants.h>
#include <QtLoggerSetup.h>

#include "SDSModel.h"
#include "DocumentManager.h"
#include "FileDownloader.h"
#include "ResourceLoader.h"
#include "CoreUpdate.h"
#include "SGQrcTreeModel.h"
#include "SGQrcTreeNode.h"
#include "SGFileTabModel.h"
#include "SGNewControlView.h"
#include "HcsNode.h"
#include "RunGuard.h"
#include "FirmwareUpdater.h"
#include "PlatformInterfaceGenerator.h"
#ifdef APPS_FEATURE_BLE
#include "BleDeviceModel.h"
#endif // APPS_FEATURE_BLE
#include "VisualEditorUndoStack.h"
#include "PlatformOperation.h"

#include "config/AppConfig.h"

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

void addImportPaths(QQmlApplicationEngine *engine)
{
    QDir applicationDir(QCoreApplication::applicationDirPath());

#ifdef Q_OS_MACOS
    applicationDir.cdUp();
    applicationDir.cdUp();
    applicationDir.cdUp();
#endif

    bool status = applicationDir.cd("imports");
    if (status == false) {
        qCCritical(lcDevStudio) << "failed to find import path.";
    }

    engine->addImportPath(applicationDir.path());

    engine->addImportPath("qrc:///");
}

void addSupportedPlugins(QQmlFileSelector *selector)
{
    QStringList supportedPlugins{QString(std::string(AppInfo::supportedPlugins_).c_str()).split(QChar(':'))};
    supportedPlugins.removeAll(QString(""));

    if (supportedPlugins.empty() == false) {
        qCDebug(lcDevStudio) << "Supported plugins:" << supportedPlugins.join(", ");
        selector->setExtraSelectors(supportedPlugins);
    }
}

int main(int argc, char *argv[])
{
#if defined(Q_OS_WIN)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    // [Faller] HACK: Temporary fix for https://bugreports.qt.io/browse/QTBUG-70228
    // [Carik]: this will be obsoleted once CS-123 is merged
    const auto chromiumFlags = qgetenv("QTWEBENGINE_CHROMIUM_FLAGS");
    if (!chromiumFlags.contains("disable-web-security")) {
        qputenv("QTWEBENGINE_CHROMIUM_FLAGS", chromiumFlags + " --disable-web-security");
    }

    QSettings::setDefaultFormat(QSettings::IniFormat);
    QGuiApplication::setApplicationDisplayName(QStringLiteral("onsemi: Strata Developer Studio"));
    QGuiApplication::setApplicationVersion(AppInfo::version.data());
    QCoreApplication::setOrganizationName(QStringLiteral("onsemi"));

#if (QT_VERSION >= QT_VERSION_CHECK(5, 13, 0))
    QtWebEngine::initialize();
#endif

    QApplication app(argc, argv);
    app.setWindowIcon(QIcon(":/resources/icons/app/on-logo.png"));

    const QtLoggerSetup loggerInitialization(app);

    QCommandLineParser parser;
    parser.setApplicationDescription(
        QStringLiteral("Strata Developer Studio\n\n"
                       "A cloud-connected development platform that provides a seamless,"
                       "personalized and secure environment for engineers to evaluate and design "
                       "with onsemi technologies."));
    parser.addOption({{QStringLiteral("f")},
                      QObject::tr("Optional configuration <filename>"),
                      QObject::tr("filename"),
                      QDir(QCoreApplication::applicationDirPath()).filePath("sds.config")});
    parser.addVersionOption();
    parser.addHelpOption();
    parser.process(app);

#if (QT_VERSION < QT_VERSION_CHECK(5, 13, 0))
    QtWebEngine::initialize();
#endif
    qCInfo(lcDevStudio) << QString(logConsts::LOGLINE_LENGTH, logConsts::LOGLINE_CHAR_MAJOR);
    qCInfo(lcDevStudio) << QString("%1 %2").arg(QCoreApplication::applicationName(), QCoreApplication::applicationVersion());
    qCInfo(lcDevStudio) << QString("Build on %1 at %2").arg(Timestamp::buildTimestamp.data(), Timestamp::buildOnHost.data());
    qCInfo(lcDevStudio) << QString(logConsts::LOGLINE_LENGTH, logConsts::LOGLINE_CHAR_MINOR);
    qCInfo(lcDevStudio) << QString("Powered by Qt %1 (based on Qt %2)").arg(QString(qVersion()), qUtf8Printable(QT_VERSION_STR));

#if defined(Q_OS_WIN)
    QVersionNumber kernelVersion = QVersionNumber::fromString(QSysInfo::kernelVersion());
    if ((kernelVersion.majorVersion() == 10) &&
        (kernelVersion.minorVersion() == 0) &&
        (kernelVersion.microVersion() >= 21996)) {
        qCInfo(lcDevStudio).nospace() << "Running on Windows 11 (" << kernelVersion.majorVersion() << "." << kernelVersion.minorVersion() << ")";
    } else {
        qCInfo(lcDevStudio) << QString("Running on %1").arg(QSysInfo::prettyProductName());
    }
#else
    qCInfo(lcDevStudio) << QString("Running on %1").arg(QSysInfo::prettyProductName());
#endif

    if (QSslSocket::supportsSsl()) {
        qCInfo(lcDevStudio) << QString("Using SSL %1 (based on SSL %2)").arg(QSslSocket::sslLibraryVersionString(), QSslSocket::sslLibraryBuildVersionString());
    } else {
        qCCritical(lcDevStudio) << QString("No SSL support!!");
    }
    qCInfo(lcDevStudio) << QString("[arch: %1; kernel: %2 (%3); locale: %4]").arg(QSysInfo::currentCpuArchitecture(), QSysInfo::kernelType(), QSysInfo::kernelVersion(), QLocale::system().name());
    qCInfo(lcDevStudio) << QString(logConsts::LOGLINE_LENGTH, logConsts::LOGLINE_CHAR_MAJOR);

    const QString configFilePath{parser.value(QStringLiteral("f"))};
    strata::sds::config::AppConfig cfg(configFilePath);
    if (cfg.parse() == false) {
        return EXIT_FAILURE;
    }

    RunGuard appGuard{QStringLiteral("tech.strata.sds:%1").arg(cfg.hcsDealerAddresss().port())};
    if (appGuard.tryToRun() == false) {
        qCCritical(lcDevStudio) << QStringLiteral("Another instance of Developer Studio is already running.");
        return EXIT_FAILURE;
    }

    // make sure that objects in context properties are declared before engine, to maintain proper order of destruction
    std::unique_ptr<SDSModel> sdsModel{std::make_unique<SDSModel>(cfg.hcsDealerAddresss(), configFilePath)};
    if (sdsModel->urls() == nullptr) {
        return EXIT_FAILURE;
    }

    qmlRegisterUncreatableType<ResourceLoader>("tech.strata.ResourceLoader", 1, 0, "ResourceLoader", "You can't instantiate ResourceLoader in QML");
    qmlRegisterUncreatableType<FileDownloader>("tech.strata.FileDownloader", 1, 0, "FileDownloader", QStringLiteral("You can't instantiate FileDownloader in QML"));
    qmlRegisterUncreatableType<CoreInterface>("tech.strata.CoreInterface",1,0,"CoreInterface", QStringLiteral("You can't instantiate CoreInterface in QML"));
    qmlRegisterUncreatableType<DocumentManager>("tech.strata.DocumentManager", 1, 0, "DocumentManager", QStringLiteral("You can't instantiate DocumentManager in QML"));
    qmlRegisterUncreatableType<DownloadDocumentListModel>("tech.strata.DownloadDocumentListModel", 1, 0, "DownloadDocumentListModel", "You can't instantiate DownloadDocumentListModel in QML");
    qmlRegisterUncreatableType<DocumentListModel>("tech.strata.DocumentListModel", 1, 0, "DocumentListModel", "You can't instantiate DocumentListModel in QML");
    qmlRegisterUncreatableType<ClassDocuments>("tech.strata.ClassDocuments", 1, 0, "ClassDocuments", "You can't instantiate ClassDocuments in QML");
    qmlRegisterType<SGFileTabModel>("tech.strata.SGFileTabModel", 1, 0, "SGFileTabModel");
    qmlRegisterUncreatableType<SGQrcTreeNode, 1>("tech.strata.SGQrcTreeModel",1,0,"SGTreeNode", "You can't instantiate SGTreeNode in QML");
    qmlRegisterType<SGQrcTreeModel>("tech.strata.SGQrcTreeModel", 1, 0, "SGQrcTreeModel");
    qmlRegisterUncreatableType<strata::sds::config::UrlConfig>("tech.strata.UrlConfig",1,0,"UrlConfig", "You can't instantiate UrlConfig in QML");
    qmlRegisterUncreatableType<strata::loggers::QtLogger>("tech.strata.QtLogger",1,0,"QtLogger", "You can't instantiate QtLogger in QML");
    qmlRegisterUncreatableType<SGNewControlView>("tech.strata.SGNewControlView",1,0,"SGNewControlView", "You can't instantiate SGNewControlView in QML");
    qmlRegisterUncreatableType<PlatformInterfaceGenerator>("tech.strata.PlatformInterfaceGenerator", 1, 0, "PlatformInterfaceGenerator", "You can't instantiate PlatformInterfaceGenerator in QML");
    qmlRegisterUncreatableType<SDSModel>("tech.strata.SDSModel", 1, 0, "SDSModel", "You can't instantiate SDSModel in QML");
    qmlRegisterUncreatableType<VisualEditorUndoStack>("tech.strata.VisualEditorUndoStack", 1, 0, "VisualEditorUndoStack", "You can't instantiate VisualEditorUndoStack in QML");
    qmlRegisterUncreatableType<CoreUpdate>("tech.strata.CoreUpdate", 1, 0, "CoreUpdate", "You can't instantiate CoreUpdate in QML");
#ifdef APPS_FEATURE_BLE
    qmlRegisterUncreatableType<BleDeviceModel>("tech.strata.BleDeviceModel", 1, 0, "BleDeviceModel", "You can't instantiate BleDeviceModel in QML");
#endif // APPS_FEATURE_BLE
    qmlRegisterUncreatableType<FirmwareUpdater>("tech.strata.FirmwareUpdater", 1, 0, "FirmwareUpdater", "You can't instantiate FirmwareUpdater in QML");
    qmlRegisterUncreatableType<strata::strataRPC::StrataClient>("tech.strata.StrataClient", 1, 0, "StrataClient", QStringLiteral("You can't instantiate StrataClient in QML"));
    qmlRegisterUncreatableType<PlatformOperation>("tech.strata.PlatformOperation", 1, 0, "PlatformOperation", "You can't instantiate PlatformOperation in QML");
    qmlRegisterInterface<strata::strataRPC::DeferredReply>("DeferredReply");
    qmlRegisterSingletonType("tech.strata.AppInfo", 1, 0, "AppInfo", appVersionSingletonProvider);

    qmlRegisterUncreatableMetaObject(
                strata::strataRPC::staticMetaObject,
                "tech.strata.StrataRpc",
                1, 0,
                "StrataRPC",
                "You can't instantiate StrataRPC in QML");

    std::unique_ptr<CoreUpdate> coreUpdate{std::make_unique<CoreUpdate>()};

    // [LC] QTBUG-85137 - doesn't reconnect on Linux; fixed in further 5.12/5.15 releases
    QObject::connect(&app, &QGuiApplication::aboutToQuit,
                     sdsModel.get(), &SDSModel::shutdownService/*, Qt::QueuedConnection*/);

    QObject::connect(coreUpdate.get(), &CoreUpdate::applicationTerminationRequested,
                     sdsModel.get(), &SDSModel::shutdownService/*, Qt::QueuedConnection*/);

    QQmlApplicationEngine engine;
    QQmlFileSelector selector(&engine);

    addSupportedPlugins(&selector);
    addImportPaths(&engine);

    engine.rootContext()->setContextProperty ("sdsModel", sdsModel.get());

    /* deprecated context property, use sdsModel.coreInterface instead */
    engine.rootContext()->setContextProperty ("coreInterface", sdsModel->coreInterface());

    engine.rootContext()->setContextProperty ("coreUpdate", coreUpdate.get());

#ifdef APPS_FEATURE_BLE
    engine.rootContext()->setContextProperty ("APPS_FEATURE_BLE", QVariant(APPS_FEATURE_BLE));
#endif // APPS_FEATURE_BLE

    strata::SGCore::AppUi ui(engine, QUrl(QStringLiteral("qrc:/ErrorDialog.qml")));
    QObject::connect(
        &ui, &strata::SGCore::AppUi::uiFails, &app, []() { QCoreApplication::exit(EXIT_FAILURE); },
        Qt::QueuedConnection);

    QObject::connect(&engine, &QQmlApplicationEngine::warnings, sdsModel.get(), &SDSModel::handleQmlWarning);

    // Starting services this build?
#ifdef START_SERVICES
    QObject::connect(
        &ui, &strata::SGCore::AppUi::uiLoaded, &app,
        [&sdsModel]() {
            bool started = sdsModel->startHcs();
            qCDebug(lcDevStudioHcs) << "hcs started =" << started;
        },
        Qt::QueuedConnection);
#endif
    ui.loadUrl(QUrl(QStringLiteral("qrc:/main.qml")));

    int appResult = app.exec();
    // LC: process remaining events i.e. submit remaining events (created by external close request)
    QCoreApplication::processEvents();

#ifdef START_SERVICES
    /* HCS has to be killed silently so qml is not updated as main event loop
     * is not running anymore */
    sdsModel->killHcsSilently = true;

    bool killed = sdsModel->killHcs();
    qCDebug(lcDevStudioHcs) << "hcs killed =" << killed;
#endif

    return appResult;
}
