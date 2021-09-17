#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtWidgets/QApplication>
#include <QQmlContext>
#include <QSettings>
#include <QResource>
#include <QDir>
#include <QIcon>
#include <QtLoggerSetup.h>
#include "logging/LoggingQtCategories.h"
#include "Version.h"

void loadResources() {
    QDir applicationDir(QCoreApplication::applicationDirPath());

    const auto resources = {
        QStringLiteral("component-fonts.rcc"),
        QStringLiteral("component-common.rcc"),
        QStringLiteral("component-sgwidgets.rcc"),
        QStringLiteral("component-theme.rcc")
    };


#ifdef Q_OS_MACOS
    applicationDir.cdUp();
    applicationDir.cdUp();
    applicationDir.cdUp();
#endif

    for (const auto& resourceName : resources) {
        QString resourcePath = applicationDir.filePath(resourceName);

        qCInfo(logCategoryWg)
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
        qCCritical(logCategoryWg) << "failed to find import path.";
    }

    engine->addImportPath(applicationDir.path());

    engine->addImportPath("qrc:///");
}

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QSettings::setDefaultFormat(QSettings::IniFormat);
    QCoreApplication::setOrganizationName(QStringLiteral("onsemi"));
    QGuiApplication::setApplicationVersion(AppInfo::version.data());

    QApplication app(argc, argv);
    app.setWindowIcon(QIcon(":/images/wg-logo.svg"));

    const strata::loggers::QtLoggerSetup loggerInitialization(app);
    qCInfo(logCategoryWg) << QStringLiteral("%1 %2").arg(QCoreApplication::applicationName()).arg(QCoreApplication::applicationVersion());

    loadResources();

    QQmlApplicationEngine engine;

    addImportPaths(&engine);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        qCCritical(logCategoryWg) << "engine failed to load 'main' qml file; quitting...";
        return -1;
    }

    return app.exec();
}
