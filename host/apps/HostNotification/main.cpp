#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>

#include "UserInterfaceBinding.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    qmlRegisterType<UserInterfaceBinding>("io.qt.examples.userinterfacebinding", 1, 0, "UserInterfaceBinding");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    return app.exec();
}
