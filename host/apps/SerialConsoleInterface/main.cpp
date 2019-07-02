#include <BoardsController.h>
#include "SciModel.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSettings>
#include <QResource>
#include <QDir>

#include <QtLoggerSetup.h>
#include "logging/LoggingQtCategories.h"

void loadResources() {
    QDir applicationDir(QCoreApplication::applicationDirPath());

    const auto resources = {
        QStringLiteral("component-fonts.rcc"),
        QStringLiteral("component-common.rcc"),
        QStringLiteral("component-sgwidgets.rcc")};

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
    QCoreApplication::setOrganizationName(QStringLiteral("ON Semiconductor"));

    QGuiApplication app(argc, argv);

    const QtLoggerSetup loggerInitialization(app);
    qCInfo(logCategorySci) << QStringLiteral("%1 v%2").arg(QCoreApplication::applicationName()).arg(QCoreApplication::applicationVersion());

    qmlRegisterType<SciModel>("tech.strata.sci", 1, 0, "SciModel");
    qmlRegisterUncreatableType<BoardsController>("tech.strata.sci", 1, 0, "BoardsController", "can not instantiate BoardsController in qml");

    loadResources();

    QQmlApplicationEngine engine;

    addImportPaths(&engine);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        qCCritical(logCategorySci) << "engine failed to load 'main' qml file; quitting...";
        return -1;
    }

    return app.exec();
}
