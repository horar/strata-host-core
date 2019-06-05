#include "BoardsController.h"
#include "SciModel.h"
#include "SgUtilsCpp.h"
#include "SgJLinkConnector.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSettings>

#include <QtLoggerSetup.h>
#include "logging/LoggingQtCategories.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QSettings::setDefaultFormat(QSettings::IniFormat);
    QCoreApplication::setOrganizationName(QStringLiteral("ON Semiconductor"));

    QGuiApplication app(argc, argv);

    const QtLoggerSetup loggerInitialization(app);
    qCInfo(logCategorySci) << QStringLiteral("%1 v%2").arg(QCoreApplication::applicationName()).arg(QCoreApplication::applicationVersion());

    qmlRegisterSingletonType(QUrl("qrc:/fonts/Fonts.qml"), "tech.strata.fonts", 1, 0, "Fonts");
    qmlRegisterSingletonType<SgUtilsCpp>("tech.strata.utils", 1, 0,"SgUtilsCpp", sgUtilsCppSingletonProvider);
    qmlRegisterType<SciModel>("tech.strata.sci", 1, 0, "SciModel");
    qmlRegisterUncreatableType<BoardsController>("tech.strata.sci", 1, 0, "BoardsController", "can not instantiate BoardsController in qml");
    qmlRegisterUncreatableType<SgJLinkConnector>("tech.strata.sci", 1, 0, "SgJLinkConnector", "can not instantiate SgJLinkConnector in qml");

    QQmlApplicationEngine engine;
    engine.addImportPath("qrc:///");

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        qCCritical(logCategorySci) << "engine failed to load 'main' qml file; quitting...";
        return -1;
    }

    return app.exec();
}
