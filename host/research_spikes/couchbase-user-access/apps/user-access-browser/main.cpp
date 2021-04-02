#include <QApplication>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "UserAccessBrowser.h"

using namespace strata::Database;

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);
    QQmlApplicationEngine *engine = new QQmlApplicationEngine();

    qmlRegisterType<UserAccessBrowser>("com.onsemi", 1, 0, "UserAccessBrowser");
    UserAccessBrowser *userAccessBrowser = new UserAccessBrowser(engine);
    engine->rootContext()->setContextProperty ("userAccessBrowser", userAccessBrowser);

    engine->load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
