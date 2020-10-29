#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QJSEngine>
#include <QQmlEngine>
#include <QDebug>
#include <QDir>
#include <QUrl>
#include <QIcon>
#include <QResource>

#include "SGUtilsCpp.h"
#include "Version.h"
#include "PlatformInterfaceGenerator.h"

void loadResources() {
    QDir applicationDir(QCoreApplication::applicationDirPath());

    const auto resources = {
        QStringLiteral("component-sgwidgets.rcc")
    };

#ifdef Q_OS_MACOS
    applicationDir.cdUp();
    applicationDir.cdUp();
    applicationDir.cdUp();
#endif

    for (const auto& resourceName : resources) {
        QString resourcePath = applicationDir.filePath(resourceName);

        qInfo()
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
        qCritical() << "failed to find import path.";
    }

    engine->addImportPath(applicationDir.path());

    engine->addImportPath("qrc:///");
}

int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication::setOrganizationName(QStringLiteral("ON Semiconductor"));
    QGuiApplication::setApplicationVersion(AppInfo::version.data());

    QGuiApplication app(argc, argv);
    app.setWindowIcon(QIcon(":/resources/icons/app/on-logo.png"));

    loadResources();

    QQmlApplicationEngine engine;

    addImportPaths(&engine);

    PlatformInterfaceGenerator generator;
    engine.rootContext()->setContextProperty("generator", &generator);

    qmlRegisterUncreatableType<PlatformInterfaceGenerator>("tech.strata.PlatformInterfaceGenerator", 1, 0, "PlatformInterfaceGenerator", "You can't instantiate PlatformInterfaceGenerator in QML");

    qmlRegisterSingletonType<SGUtilsCpp>("tech.strata.SGUtilsCpp", 1, 0,"SGUtilsCpp", [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject* {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)

        SGUtilsCpp *utils = new SGUtilsCpp();
        return utils;
    });

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        qCritical() << "engine failed to load 'main' qml file; quitting...";
        return -1;
    }

    return app.exec();
}
