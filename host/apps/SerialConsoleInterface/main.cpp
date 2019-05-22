#include "BoardsController.h"
#include "SciModel.h"
#include "SgUtilsCpp.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setOrganizationName(QStringLiteral("ON Semiconductor"));

    QGuiApplication app(argc, argv);

    qmlRegisterSingletonType(QUrl("qrc:/fonts/Fonts.qml"), "tech.strata.fonts", 1, 0, "Fonts");
    qmlRegisterSingletonType<SgUtilsCpp>("tech.strata.utils", 1, 0,"SgUtilsCpp", sgUtilsCppSingletonProvider);
    qmlRegisterType<SciModel>("tech.strata.sci", 1, 0, "SciModel");
    qmlRegisterUncreatableType<BoardsController>("tech.strata.sci", 1, 0, "BoardsController", "can not instantiate BoardsController in qml");

    QQmlApplicationEngine engine;
    engine.addImportPath("qrc:///");

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
