/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "LogModel.h"
#include "FileModel.h"

#include "Version.h"
#include "Timestamp.h"

#include <QCommandLineParser>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QSettings>
#include <QResource>
#include <QDir>
#include <QDebug>
#include <QVariant>
#include <QQuickView>
#include <QQmlContext>
#include <QQmlFileSelector>
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

        qCInfo(lcLogViewer)
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
        qCCritical(lcLogViewer) << "Failed to find import path.";
    }
    engine->addImportPath(applicationDir.path());
    engine->addImportPath("qrc:///");
}

void addSupportedPlugins(QQmlFileSelector *selector)
{
    QStringList supportedPlugins{QString(std::string(AppInfo::supportedPlugins_).c_str()).split(QChar(':'))};
    supportedPlugins.removeAll(QString(""));

    if (supportedPlugins.empty() == false) {
        qInfo(lcLogViewer) << "Supported plugins:" << supportedPlugins.join(", ");
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
                qCWarning(lcLogViewer) << QStringLiteral("Resource file for '%1' plugin does not exist.").arg(pluginName);
                continue;
            }
            qCDebug(lcLogViewer) << QStringLiteral("Loading '%1: %2'").arg(resourceFile, QResource::registerResource(resourceFile));
        }
    }
}

int main(int argc, char *argv[]) {
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QSettings::setDefaultFormat(QSettings::IniFormat);
    QCoreApplication::setOrganizationName(QStringLiteral("onsemi"));
    QGuiApplication::setApplicationVersion(AppInfo::version.data());

    QGuiApplication app(argc, argv);
    app.setWindowIcon(QIcon(":/images/lv-logo.png"));

    const QtLoggerSetup loggerInitialization(app);

    QCommandLineParser parser;
    parser.setApplicationDescription(
        QStringLiteral("Log Viewer \n\n"
                       "Tool, useful for loading, parsing and filtering log files."));
    parser.addPositionalArgument(QStringLiteral("<file>"),
                            QObject::tr("Specifies list of Strata log files to be loaded."));
    parser.addVersionOption();
    parser.addHelpOption();
    parser.process(app);

    qCInfo(lcLogViewer) << QString(logConsts::LOGLINE_LENGTH, logConsts::LOGLINE_CHAR_MAJOR);
    qCInfo(lcLogViewer) << QString("%1 %2").arg(QCoreApplication::applicationName(), QCoreApplication::applicationVersion());
    qCInfo(lcLogViewer) << QString("Build on %1 at %2").arg(Timestamp::buildTimestamp.data(), Timestamp::buildOnHost.data());
    qCInfo(lcLogViewer) << QString(logConsts::LOGLINE_LENGTH, logConsts::LOGLINE_CHAR_MINOR);
    qCInfo(lcLogViewer) << QString("Powered by Qt %1 (based on Qt %2)").arg(QString(qVersion()), qUtf8Printable(QT_VERSION_STR));

#if defined(Q_OS_WIN)
    QVersionNumber kernelVersion = QVersionNumber::fromString(QSysInfo::kernelVersion());
    if ((kernelVersion.majorVersion() == 10) &&
        (kernelVersion.minorVersion() == 0) &&
        (kernelVersion.microVersion() >= 21996)) {
        qCInfo(lcLogViewer).nospace() << "Running on Windows 11 (" << kernelVersion.majorVersion() << "." << kernelVersion.minorVersion() << ")";
    } else {
        qCInfo(lcLogViewer) << QString("Running on %1").arg(QSysInfo::prettyProductName());
    }
#else
    qCInfo(lcLogViewer) << QString("Running on %1").arg(QSysInfo::prettyProductName());
#endif

    qCInfo(lcLogViewer) << QString("[arch: %1; kernel: %2 (%3); locale: %4]").arg(QSysInfo::currentCpuArchitecture(), QSysInfo::kernelType(), QSysInfo::kernelVersion(), QLocale::system().name());
    qCInfo(lcLogViewer) << QString(logConsts::LOGLINE_LENGTH, logConsts::LOGLINE_CHAR_MAJOR);

    loadResources();

    LogModel logModel_;

    QQmlApplicationEngine engine;
    QQmlFileSelector selector(&engine);

    qmlRegisterUncreatableType<LogModel>("tech.strata.logviewer.models", 1, 0, "LogModel", "You can't instantiate LogModel in QML");
    qmlRegisterType<FileModel>("tech.strata.logviewer.models", 1, 0, "FileModel");
    qmlRegisterSingletonType("tech.strata.AppInfo", 1, 0, "AppInfo", appVersionSingletonProvider);

    addSupportedPlugins(&selector);
    addImportPaths(&engine);

    engine.rootContext()->setContextProperty("logModel", &logModel_);

    QObject::connect(&engine, &QQmlApplicationEngine::warnings, &logModel_, &LogModel::handleQmlWarning);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    if (engine.rootObjects().isEmpty()) {
        qCCritical(lcLogViewer) << "root object is empty";
        return -1;
    }
    return app.exec();
}
