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

    const QUrl mainDir(QStringLiteral("qrc:/qml/MainWindow.qml"));
    engine->load(mainDir);

    // Run the app
    return app.exec();
}
