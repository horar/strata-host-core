#include <QDir>
#include <QFile>
#include <QGuiApplication>
#include <QProcess>
#include <QQmlApplicationEngine>
#include <QtQml/QQmlContext>

#include "SgJLinkConnector.h"
#include "PrtModel.h"
#include "SgSortFilterProxyModel.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setOrganizationName(QStringLiteral("ON Semiconductor"));
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QSettings::setDefaultFormat(QSettings::IniFormat);

    QGuiApplication app(argc, argv);

    const QtLoggerSetup loggerInitialization(app);
    qCInfo(logCategoryPrt) << QStringLiteral("%1 v%2").arg(QCoreApplication::applicationName()).arg(QCoreApplication::applicationVersion());

    QQmlApplicationEngine engine;

    qmlRegisterType<PrtModel>("tech.strata.prt", 1, 0, "PrtModel");
    qmlRegisterType<SgJLinkConnector>("tech.strata.prt", 1, 0, "SgJLinkConnector");
    qmlRegisterType<SgSortFilterProxyModel>("tech.strata.prt", 1, 0, "SgSortFilterProxyModel");

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
