#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <QDebug>
#include <QResource>

int main(int argc, char* argv[])
{
    qDebug() << "LOAD:" << QResource::registerResource(QStringLiteral("../../../fonts.rcc"));

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    engine.addImportPath(QStringLiteral("qrc:/"));

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
