#include <BoardsController.h>
#include "SciModel.h"
#include "SciDatabaseConnector.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSettings>
#include <QResource>
#include <QDir>
#include <QtWebEngine>

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
    QtWebEngine::initialize();

    const QtLoggerSetup loggerInitialization(app);
    qCInfo(logCategorySci) << QStringLiteral("%1 v%2").arg(QCoreApplication::applicationName()).arg(QCoreApplication::applicationVersion());

    qmlRegisterUncreatableType<SciModel>("tech.strata.sci", 1, 0, "SciModel", "can not instantiate SciModel in qml");
    qmlRegisterUncreatableType<BoardsController>("tech.strata.sci", 1, 0, "BoardsController", "can not instantiate BoardsController in qml");
    qmlRegisterUncreatableType<SciDatabaseConnector>("tech.strata.sci", 1, 0, "DatabaseConnector", "can not instantiate DatabaseConnector in qml");

    qmlRegisterSingletonType(QUrl("qrc:/SciSettings.qml"), "tech.strata.sci", 1, 0, "Settings");

    loadResources();

    QQmlApplicationEngine engine;

    addImportPaths(&engine);

    SciModel sciModel_;
    engine.rootContext()->setContextProperty("sciModel", &sciModel_);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        qCCritical(logCategorySci) << "engine failed to load 'main' qml file; quitting...";
        return -1;
    }

    return app.exec();
}
