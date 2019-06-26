#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlComponent>
#include <QDebug>
#include "databaseinterface.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // Create new engine
    QQmlApplicationEngine *engine = new QQmlApplicationEngine();

    // Load main.qml
    const QUrl mainDir(QStringLiteral("qrc:/qml/main.qml"));
    engine->load(mainDir);
    QObject *mainComponent = engine->rootObjects()[0];

    // Make DatabaseInterface callable from QML
    qmlRegisterType<DatabaseInterface>("DI", 1, 0, "DatabaseInterface");
    DatabaseInterface *databaseInterface = new DatabaseInterface();
    engine->rootContext()->setContextProperty("databaseInterface",databaseInterface);

    // Store mainComponent in DatabaseInterface
    //databaseInterface->setMainComponent(mainComponent);

    QString JSON_resp = databaseInterface->getJSONResponse();

    QQmlProperty::write(mainComponent,"contentArray",JSON_resp);

    // Run the app
    return app.exec();
}
