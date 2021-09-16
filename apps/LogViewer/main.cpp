/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "LogModel.h"
#include "FileModel.h"

#include "Version.h"

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

#include <QtLoggerSetup.h>
#include "logging/LoggingQtCategories.h"


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

        qCInfo(logCategoryLogViewer)
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
        qCCritical(logCategoryLogViewer) << "Failed to find import path.";
    }
    engine->addImportPath(applicationDir.path());
    engine->addImportPath("qrc:///");
}

int main(int argc, char *argv[]) {
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QSettings::setDefaultFormat(QSettings::IniFormat);
    QCoreApplication::setOrganizationName(QStringLiteral("ON Semiconductor"));
    QGuiApplication::setApplicationVersion(AppInfo::version.data());

    QGuiApplication app(argc, argv);
    app.setWindowIcon(QIcon(":/images/lv-logo.png"));

    const strata::loggers::QtLoggerSetup loggerInitialization(app);

    QCommandLineParser parser;
    parser.setApplicationDescription(
        QStringLiteral("Log Viewer \n\n"
                       "Tool, useful for loading, parsing and filtering log files."));
    parser.addPositionalArgument(QStringLiteral("<file>"),
                            QObject::tr("Specifies list of Strata log files to be loaded."));
    parser.addVersionOption();
    parser.addHelpOption();
    parser.process(app);

    qCInfo(logCategoryLogViewer) << QStringLiteral("%1 v%2").arg(QCoreApplication::applicationName()).arg(QCoreApplication::applicationVersion());

    QQmlApplicationEngine engine;

    qmlRegisterType<LogModel>("tech.strata.logviewer.models", 1, 0, "LogModel");
    qmlRegisterType<FileModel>("tech.strata.logviewer.models", 1, 0, "FileModel");

    loadResources();
    addImportPaths(&engine);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    if (engine.rootObjects().isEmpty()) {
        qCCritical(logCategoryLogViewer) << "root object is empty";
        return -1;
    }
    return app.exec();
}
