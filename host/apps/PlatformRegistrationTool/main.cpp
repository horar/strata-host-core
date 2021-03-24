#include "PrtModel.h"
#include <PlatformManager.h>

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml/QQmlContext>
#include <QSettings>
#include <QResource>
#include <QDir>
#include <QIcon>

#include <QtLoggerSetup.h>
#include "logging/LoggingQtCategories.h"

void loadResources() {
    QDir applicationDir(QCoreApplication::applicationDirPath());

    const auto resources = {
        QStringLiteral("component-fonts.rcc"),
        QStringLiteral("component-common.rcc"),
        QStringLiteral("component-sgwidgets.rcc"),
        QStringLiteral("component-theme.rcc")};

#ifdef Q_OS_MACOS
    applicationDir.cdUp();
    applicationDir.cdUp();
    applicationDir.cdUp();
#endif

    for (const auto& resourceName : resources) {
        QString resourcePath = applicationDir.filePath(resourceName);

        qCInfo(logCategoryPrt)
                << "Loading"
                << resourceName << ":"
                << QResource::registerResource(resourcePath);
    }
}

void addImportPaths(QQmlApplicationEngine *engine) {
    QDir applicationDir(QCoreApplication::applicationDirPath());

#ifdef Q_OS_MACOS
    applicationDir.cdUp();
    applicationDir.cdUp();
    applicationDir.cdUp();
#endif

    bool status = applicationDir.cd("imports");
    if (status == false) {
        qCCritical(logCategoryPrt) << "failed to find import path.";
    }

    engine->addImportPath(applicationDir.path());

    engine->addImportPath("qrc:///");
}

int main(int argc, char *argv[])
{
    QCoreApplication::setOrganizationName(QStringLiteral("ON Semiconductor"));
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QSettings::setDefaultFormat(QSettings::IniFormat);

    QGuiApplication app(argc, argv);
    app.setWindowIcon(QIcon(":/images/prt-logo.svg"));

    const strata::loggers::QtLoggerSetup loggerInitialization(app);
    qCInfo(logCategoryPrt) << QStringLiteral("%1 v%2").arg(QCoreApplication::applicationName()).arg(QCoreApplication::applicationVersion());

    loadResources();

    QQmlApplicationEngine engine;

    addImportPaths(&engine);

    qmlRegisterType<PrtModel>("tech.strata.prt", 1, 0, "PrtModel");
    qmlRegisterUncreatableType<strata::BoardManager>("tech.strata.sci", 1, 0, "BoardManager", "can not instantiate BoardManager in qml");
    qmlRegisterUncreatableType<Authenticator>("tech.strata.prt.authenticator", 1, 0, "Authenticator", "can not instantiate Authenticator in qml");
    qmlRegisterUncreatableType<RestClient>("tech.strata.prt.restclient", 1, 0, "RestClient", "can not instantiate RestClient in qml");
    qmlRegisterUncreatableType<Deferred>("tech.strata.prt.restclient", 1, 0, "Deferred", "can not instantiate Deferred in qml");

    qmlRegisterUncreatableType<strata::FlasherConnector>("tech.strata.flasherConnector", 1, 0, "FlasherConnector", "can not instantiate FlasherConnector in qml");
    qRegisterMetaType<strata::FlasherConnector::Operation>();
    qRegisterMetaType<strata::FlasherConnector::State>();
    qRegisterMetaType<strata::FlasherConnector::Result>();

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
