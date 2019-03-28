#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#endif

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtWebView/QtWebView>
#include <QtWebEngine>
#include <QtWidgets/QApplication>
#include <QtQml/QQmlContext>
#include <QtQuick/QQuickView>
#include <QtQml/QQmlEngine>
#include <QtCore/QDir>
#include "QtDebug"
#include <QProcess>
#include <QSettings>

#include <PlatformInterface/core/CoreInterface.h>

#include <QtLoggerSetup.h>
#include "logging/LoggingQtCategories.h"

#include "DocumentManager.h"

int main(int argc, char *argv[])
{
#if defined(Q_OS_WIN)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    // [Faller] HACK: Temporary fix for https://bugreports.qt.io/browse/QTBUG-70228
    const auto chromiumFlags = qgetenv("QTWEBENGINE_CHROMIUM_FLAGS");
    if (!chromiumFlags.contains("disable-web-security")) {
        qputenv("QTWEBENGINE_CHROMIUM_FLAGS", chromiumFlags + " --disable-web-security");
    }

    QSettings::setDefaultFormat(QSettings::IniFormat);
    QCoreApplication::setOrganizationName(QStringLiteral("On Semiconductor"));

    QApplication app(argc, argv);
    const QtLoggerSetup loggerInitialization(app);
    qCInfo(logCategoryStrataDevStudio) << QStringLiteral("================================================================================") ;
    qCInfo(logCategoryStrataDevStudio) << QStringLiteral("%1 v%2").arg(QCoreApplication::applicationName()).arg(QCoreApplication::applicationVersion());
    qCInfo(logCategoryStrataDevStudio) << QStringLiteral("================================================================================") ;

    qmlRegisterUncreatableType<CoreInterface>("tech.spyglass.CoreInterface",1,0,"CoreInterface", QStringLiteral("You can't instantiate CoreInterface in QML"));
    qmlRegisterUncreatableType<DocumentManager>("tech.spyglass.DocumentManager", 1, 0, "DocumentManager", QStringLiteral("You can't instantiate DocumentManager in QML"));
    qmlRegisterUncreatableType<Document>("tech.spyglass.Document", 1, 0, "Document", "You can't instantiate Document in QML");
    qmlRegisterSingletonType(QUrl("qrc:/fonts/Fonts.qml"), "Fonts", 1, 0, "Fonts");

    CoreInterface *coreInterface = new CoreInterface();
    DocumentManager* documentManager = new DocumentManager(coreInterface);
    //DataCollector* dataCollector = new DataCollector(coreInterface);

    QtWebEngine::initialize();
    QtWebView::initialize();

    QQmlApplicationEngine engine;
    engine.addImportPath(QStringLiteral("qrc:/"));

    engine.rootContext()->setContextProperty ("coreInterface", coreInterface);
    engine.rootContext()->setContextProperty ("documentManager", documentManager);

    //engine.rootContext ()->setContextProperty ("dataCollector", dataCollector);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    // Starting services this build?
    // [prasanth] : Important note: Start HCS before launching the UI
    // So the service callback works properly
#ifdef START_SERVICES

#ifdef Q_OS_WIN
    const QString hcsPath{ QDir::cleanPath(QString("%1/hcs2.exe").arg(app.applicationDirPath())) };
    const QString hcsConfigPath{ QDir::cleanPath(QString("%1/../../apps/hcs2/files/conf/host_controller_service.config").arg(app.applicationDirPath()))};
#endif
#ifdef Q_OS_MACOS
    const QString hcsPath{ QDir::cleanPath(QString("%1/../../../hcs2").arg(app.applicationDirPath())) };
    const QString hcsConfigPath{ QDir::cleanPath(QString("%1/../../../../../apps/hcs2/files/conf/host_controller_service.config_template").arg(app.applicationDirPath()))};
#endif
#ifdef Q_OS_LINUX
    const QString hcsPath{ QDir::cleanPath(QString("%1/hcs2").arg(app.applicationDirPath())) };
    const QString hcsConfigPath{ QDir::cleanPath(QString("%1/../../apps/hcs2/files/conf/host_controller_service.config").arg(app.applicationDirPath()))};
#endif

    // Start HCS before handling events for Qt
    auto hcsProcess{std::make_unique<QProcess>(nullptr)};
    if (QFile::exists(hcsPath)) {
        qCDebug(logCategoryStrataDevStudio) << "Starting HCS: " << hcsPath << "(" << hcsConfigPath << ")";

        QStringList arguments;
        arguments << "-f" << hcsConfigPath;

        // XXX: [LC] temporary solutions until Strata Monitor takeover 'hcs' service management
        QObject::connect(hcsProcess.get(), &QProcess::readyReadStandardOutput, [&]() {
            const QString hscMsg{QString::fromLatin1(hcsProcess->readAllStandardOutput())};
            for (const auto& line : hscMsg.split(QRegExp("\n|\r\n|\r"))) {
                qCDebug(logCategoryHcs) << line;
            }
        } );
        QObject::connect(hcsProcess.get(), &QProcess::readyReadStandardError, [&]() {
            const QString hscMsg{QString::fromLatin1(hcsProcess->readAllStandardError())};
            for (const auto& line : hscMsg.split(QRegExp("\n|\r\n|\r"))) {
                qCCritical(logCategoryHcs) << line;
            }
        });
        // XXX: [LC] end

        hcsProcess->start(hcsPath, arguments, QIODevice::ReadWrite);
        if (!hcsProcess->waitForStarted()) {
            qCWarning(logCategoryStrataDevStudio) << "Process does not started yet (state:" << hcsProcess->state() << ")";
        }
        qCInfo(logCategoryStrataDevStudio) << "HCS started";
    } else {
        qCCritical(logCategoryStrataDevStudio) << "Failed to start HCS: does not exist";
    }
#endif

    int appResult = app.exec();

#ifdef START_SERVICES
    if (hcsProcess->state() == QProcess::Running) {
        qCDebug(logCategoryStrataDevStudio) << "terminating HCS";
        hcsProcess->terminate();
        if (!hcsProcess->waitForFinished()) {
            qCDebug(logCategoryStrataDevStudio) << "termination failed, killing HCS";
            hcsProcess->kill();
            if (!hcsProcess->waitForFinished()) {
                qCWarning(logCategoryStrataDevStudio) << "Failed to kill HCS server";
            }
        }
    }
#endif

    return appResult;
}
