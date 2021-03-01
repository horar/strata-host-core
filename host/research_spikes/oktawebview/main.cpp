#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtWebEngine>
#include <QQmlEngine>

#include "pkcegenerator.h"
#include "urlquery.h"
#include "url.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);
    QtWebEngine::initialize();
    QQmlApplicationEngine engine;

    qmlRegisterType<PKCEGenerator>("strata.example.PKCEGenerator", 1, 0, "PKCEGenerator");
    qmlRegisterType<UrlQuery>("strata.example.UrlQuery", 1, 0, "UrlQuery");
    qmlRegisterType<url>("strata.example.Url", 1, 0, "Url");

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
