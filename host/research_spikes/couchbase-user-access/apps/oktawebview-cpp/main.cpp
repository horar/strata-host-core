#include <QApplication>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "OktaWebviewCpp.h"

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);
    QQmlApplicationEngine *engine = new QQmlApplicationEngine();

    qmlRegisterType<OktaWebviewCpp>("strata.example.OktaWebviewCpp", 1, 0, "OktaWebviewCpp");
    OktaWebviewCpp *oktaWebviewCpp = new OktaWebviewCpp(engine);
    engine->rootContext()->setContextProperty ("oktaWebviewCpp", oktaWebviewCpp);

    engine->load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
