#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlComponent>
#include <QDebug>
#include "DatabaseImpl.h"

int main(int argc, char *argv[])
{
    qmlRegisterType<DatabaseImpl>("com.onsemi.couchbase", 1, 0, "Database");

    QGuiApplication app(argc, argv);

    // Create new engine
    QQmlApplicationEngine *engine = new QQmlApplicationEngine();

    // Create new component for making multiple windows
    const QUrl mainDir(QStringLiteral("qrc:/qml/main.qml"));
    QQmlComponent *component = new QQmlComponent(&(*engine),mainDir);

    // Make DatabaseInterface callable from QML

    engine->load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    //Database *database = new Database();
    //engine->rootContext()->setContextProperty("database",database);

    // Store engine and component in QMLBridge
    //database->init(engine, component);

    // Run the app
    return app.exec();
}
