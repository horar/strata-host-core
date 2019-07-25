#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlComponent>
#include <QObject>
#include <QDebug>
#include <QSettings>

#include "DatabaseImpl.h"
#include "WindowManager.h"

#include <QtLoggerSetup.h>
#include <QLoggingCategory>

#include <iostream>

int main(int argc, char *argv[])
{
    qputenv("QT_AUTO_SCREEN_SCALE_FACTOR", "1");
    qmlRegisterType<DatabaseImpl>("com.onsemi.couchbase", 1, 0, "Database");

    QSettings::setDefaultFormat(QSettings::IniFormat);
    QCoreApplication::setOrganizationName(QStringLiteral("ON Semiconductor"));

    QGuiApplication app(argc, argv);
    const QtLoggerSetup loggerInitialization(app);

    // Create new engine
    QQmlApplicationEngine *engine = new QQmlApplicationEngine();

    windowManage *manage = new windowManage(engine);
    engine->rootContext()->setContextProperty("manage", manage);
    manage->createNewWindow();

    // Run the app
    return app.exec();
}
