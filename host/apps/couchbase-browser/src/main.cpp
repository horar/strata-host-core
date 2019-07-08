#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlComponent>
#include <QDebug>
#include "qmlbridge.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // Create new engine
    QQmlApplicationEngine *engine = new QQmlApplicationEngine();

    // Create new component for making multiple windows
    const QUrl mainDir(QStringLiteral("qrc:/qml/main.qml"));
    QQmlComponent *component = new QQmlComponent(&(*engine),mainDir);

    // Make DatabaseInterface callable from QML
    qmlRegisterType<QMLBridge>("DI", 1, 0, "QMLBridge");
    QMLBridge *qmlBridge = new QMLBridge();
    engine->rootContext()->setContextProperty("qmlBridge",qmlBridge);

    // Store engine and component in QMLBridge
    qmlBridge->init(engine, component);

    // Run the app
    return app.exec();
}
