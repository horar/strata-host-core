#include "UpdateWatchdog.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSettings>

int main(int argc, char *argv[])
{
    QSettings::setDefaultFormat(QSettings::IniFormat);
    QGuiApplication::setApplicationName(QStringLiteral("rs-Strata-update"));
    QGuiApplication::setOrganizationName(QStringLiteral("ON Semiconductor"));
    //QGuiApplication::setOrganizationDomain("tech.spyglass.strata");
#if defined(Q_OS_WIN)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);

    qmlRegisterUncreatableType<UpdateWatchdog>("tech.spyglass.strata", 1, 0, "UpdateWatchdog", "U can't create instance of UpdateWatchdog in QML!!");
    UpdateWatchdog updateWatchdog;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty ("updateWatchdog", &updateWatchdog);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
