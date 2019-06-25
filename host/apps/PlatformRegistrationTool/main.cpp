#include "PrtModel.h"
#include <BoardsController.h>

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml/QQmlContext>
#include <QSettings>
#include <QResource>
#include <QDir>

#include <QtLoggerSetup.h>
#include "logging/LoggingQtCategories.h"

void loadResources() {
    QDir applicationDir(QCoreApplication::applicationDirPath());

    const auto resources = {
        QStringLiteral("component-fonts.rcc"),
        QStringLiteral("component-common.rcc"),
        QStringLiteral("component-sgwidgets.rcc")};

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

    const QtLoggerSetup loggerInitialization(app);
    qCInfo(logCategoryPrt) << QStringLiteral("%1 v%2").arg(QCoreApplication::applicationName()).arg(QCoreApplication::applicationVersion());

    loadResources();

    QQmlApplicationEngine engine;

    addImportPaths(&engine);

    qmlRegisterType<PrtModel>("tech.strata.prt", 1, 0, "PrtModel");
    qmlRegisterUncreatableType<BoardsController>("tech.strata.sci", 1, 0, "BoardsController", "can not instantiate BoardsController in qml");

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
