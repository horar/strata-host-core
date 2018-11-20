#include "PlatformController.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    engine.addImportPath("qrc:///");

    qmlRegisterType<PlatformController>("tech.spyglass.sci", 1, 0, "PlatformController");
    qmlRegisterSingletonType(QUrl("qrc:/fonts/Fonts.qml"), "fonts", 1, 0, "Fonts");

    PlatformController *platformController = new PlatformController();
    engine.rootContext ()->setContextProperty ("platformController", platformController);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
