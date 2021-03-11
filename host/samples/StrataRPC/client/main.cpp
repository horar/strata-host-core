#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "Client.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreated, &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl) QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);
    engine.load(url);

    std::unique_ptr<Client> client_(new Client());
    engine.rootContext()->setContextProperty("Client", client_.get());

    client_->init();
    client_->start();

    return app.exec();
}
