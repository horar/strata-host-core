#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>

#include "ImplementationInterfaceBinding/ImplementationInterfaceBinding.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    qmlRegisterType<ImplementationInterfaceBinding>("io.qt.ImplementationInterfaceBinding", 1, 0, "ImplementationInterfaceBinding");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    return app.exec();
}
