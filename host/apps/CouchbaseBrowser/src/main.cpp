#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlComponent>
#include <QObject>
#include <QDebug>

#include "DatabaseImpl.h"
#include "WindowManager.h"

#include <QtLoggerSetup.h>
#include <QLoggingCategory>

#include <iostream>

int main(int argc, char *argv[])
{
    qmlRegisterType<DatabaseImpl>("com.onsemi.couchbase", 1, 0, "Database");

    QGuiApplication app(argc, argv);

    // Create new engine
    QQmlApplicationEngine *engine = new QQmlApplicationEngine();

    windowManage *manage = new windowManage(engine);
    engine->rootContext()->setContextProperty("manage", manage);
    manage->createNewWindow();

    const QtLoggerSetup loggerInitialization(app);
//    QLoggingCategory cb_browser("cb_browser");


    // Run the app
    return app.exec();
}
