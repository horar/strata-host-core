#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlComponent>
#include <QDebug>
#include "Database.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // Create new engine
    QQmlApplicationEngine *engine = new QQmlApplicationEngine();

    // Create new component for making multiple windows
    const QUrl mainDir(QStringLiteral("qrc:/qml/main.qml"));
    QQmlComponent *component = new QQmlComponent(&(*engine),mainDir);

    // Make DatabaseInterface callable from QML
    //qmlRegisterType<Database>("Database", 1, 0, "Database");
    Database *database = new Database();
    engine->rootContext()->setContextProperty("database",database);

    // Store engine and component in QMLBridge
    database->init(engine, component);

    // Run the app
    return app.exec();
}
