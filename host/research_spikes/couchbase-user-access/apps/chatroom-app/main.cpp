#include <QApplication>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "CouchChat.h"

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);
    QQmlApplicationEngine *engine = new QQmlApplicationEngine();

    qmlRegisterType<CouchChat>("com.onsemi", 1, 0, "CouchChat");
    CouchChat *couchChat = new CouchChat(engine);
    engine->rootContext()->setContextProperty ("couchChat", couchChat);

    engine->load(QUrl(QStringLiteral("qrc:/qml/main.qml")));

    return app.exec();
}
