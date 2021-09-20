#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlComponent>
#include <QObject>
#include <QDebug>
#include <QSettings>
#include <QtLoggerSetup.h>
#include <QLoggingCategory>
#include <QResource>
#include <QDir>

#include "DatabaseImpl.h"
#include "WindowManager.h"

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
        qDebug() << QResource::registerResource(resourcePath);
    }
}

int main(int argc, char *argv[])
{

    qputenv("QT_AUTO_SCREEN_SCALE_FACTOR", "1");
    qmlRegisterType<DatabaseImpl>("com.onsemi.couchbase", 1, 0, "Database");

    QSettings::setDefaultFormat(QSettings::IniFormat);
    QCoreApplication::setOrganizationName(QStringLiteral("onsemi"));

    QGuiApplication app(argc, argv);
    const strata::loggers::QtLoggerSetup loggerInitialization(app);

    loadResources();

    // Create new engine
    QQmlApplicationEngine *engine = new QQmlApplicationEngine();

    engine->addImportPath("qrc:///");

    WindowManager *manage = new WindowManager(engine);
    engine->rootContext()->setContextProperty("manage", manage);
    manage->createNewWindow();

    // Run the app
    return app.exec();
}
