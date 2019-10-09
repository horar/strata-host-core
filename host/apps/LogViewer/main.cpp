#include "LogModel.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QSettings>
#include <QResource>
#include <QDir>
#include <QDebug>
#include <QVariant>
#include <QQuickView>
#include <QQmlContext>


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

        qInfo() << "Loading"
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
        qCritical() << "Failed to find import path.";
    }
    engine->addImportPath(applicationDir.path());
    engine->addImportPath("qrc:///");
}

int main(int argc, char *argv[]) {
    QCoreApplication::setOrganizationName(QStringLiteral("ON Semiconductor"));
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QSettings::setDefaultFormat(QSettings::IniFormat);
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    qmlRegisterType<LogModel>("tech.strata.logviewer.models", 1, 0, "LogModel");
    loadResources();
    addImportPaths(&engine);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    if (engine.rootObjects().isEmpty()) {
        qCritical() << "root object is empty";
        return -1;
    }
    return app.exec();
}
