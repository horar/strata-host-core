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
#ifdef Q_OS_WIN
#include <Shlwapi.h>
#include <ShlObj.h>
#endif

#include <PlatformInterface/core/CoreInterface.h>

#include <QtLoggerSetup.h>
#include "logging/LoggingQtCategories.h"

#include "DocumentManager.h"
#include "ResourceLoader.h"

int main(int argc, char *argv[])
{
#if defined(Q_OS_WIN)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QSettings::setDefaultFormat(QSettings::IniFormat);
    QCoreApplication::setOrganizationName(QStringLiteral("ON Semiconductor"));

    QApplication app(argc, argv);
    const QtLoggerSetup loggerInitialization(app);

    qCInfo(logCategoryStrataDevStudio) << QStringLiteral("================================================================================") ;
    qCInfo(logCategoryStrataDevStudio) << QStringLiteral("%1 v%2").arg(QCoreApplication::applicationName()).arg(QCoreApplication::applicationVersion());
    qCInfo(logCategoryStrataDevStudio) << QStringLiteral("================================================================================") ;

    ResourceLoader resourceLoader;

    qmlRegisterUncreatableType<CoreInterface>("tech.strata.CoreInterface",1,0,"CoreInterface", QStringLiteral("You can't instantiate CoreInterface in QML"));
    qmlRegisterUncreatableType<DocumentManager>("tech.strata.DocumentManager", 1, 0, "DocumentManager", QStringLiteral("You can't instantiate DocumentManager in QML"));
    qmlRegisterUncreatableType<Document>("tech.strata.Document", 1, 0, "Document", "You can't instantiate Document in QML");

    CoreInterface *coreInterface = new CoreInterface();
    DocumentManager* documentManager = new DocumentManager(coreInterface);
    //DataCollector* dataCollector = new DataCollector(coreInterface);

    QtWebEngine::initialize();
    QtWebView::initialize();

    QQmlApplicationEngine engine;
    QQmlFileSelector selector(&engine);

    engine.addImportPath(QStringLiteral("qrc:/"));

    engine.rootContext()->setContextProperty ("coreInterface", coreInterface);
    engine.rootContext()->setContextProperty ("documentManager", documentManager);

    //engine.rootContext ()->setContextProperty ("dataCollector", dataCollector);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        qCCritical(logCategoryStrataDevStudio) << "engine failed to load 'main' qml file; quitting...";
        engine.load(QUrl(QStringLiteral("qrc:/ErrorDialog.qml")));
        if (engine.rootObjects().isEmpty()) {
            qCCritical(logCategoryStrataDevStudio) << "hell froze - engine fails to load error dialog; aborting...";
            return -1;
        }

        return app.exec();
    }

    // Starting services this build?
    // [prasanth] : Important note: Start HCS before launching the UI
    // So the service callback works properly
#ifdef START_SERVICES

#ifdef Q_OS_WIN
#if WINDOWS_INSTALLER_BUILD
    const QString hcsPath{ QDir::cleanPath(QString("%1/HCS/hcs.exe").arg(app.applicationDirPath())) };
    QString hcsConfigPath;
    TCHAR programDataPath[MAX_PATH];
    if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMMON_APPDATA, NULL, 0, programDataPath))) {
        hcsConfigPath = QDir::cleanPath(QString("%1/ON Semiconductor/Strata Developer Studio/HCS/hcs.config").arg(programDataPath));
        qCInfo(logCategoryStrataDevStudio) << QStringLiteral("hcsConfigPath:") << hcsConfigPath ;
    }else{
        qCCritical(logCategoryStrataDevStudio) << "Failed to get ProgramData path using windows API call...";
    }
#else
    const QString hcsPath{ QDir::cleanPath(QString("%1/hcs.exe").arg(app.applicationDirPath())) };
    const QString hcsConfigPath{ QDir::cleanPath(QString("%1/../../apps/hcs2/files/conf/host_controller_service.config_template").arg(app.applicationDirPath()))};
#endif
#endif
#ifdef Q_OS_MACOS
    const QString hcsPath{ QDir::cleanPath(QString("%1/../../../hcs").arg(app.applicationDirPath())) };
    const QString hcsConfigPath{ QDir::cleanPath(QString("%1/../../../../../apps/hcs2/files/conf/host_controller_service.config_template").arg(app.applicationDirPath()))};
#endif
#ifdef Q_OS_LINUX
    const QString hcsPath{ QDir::cleanPath(QString("%1/hcs").arg(app.applicationDirPath())) };
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

#ifdef START_SERVICES // start services
#ifdef Q_OS_WIN // windows check to kill hcs3
    // [PV] : In windows, QProcess terminate will not send any close message to QT non GUI application
    // Waiting for 10s before kill, if user runs an instance of SDS immediately after closing, hcs3
    // will not be terminated and new hcs insatnce will start, leaving two instances of hcs.
    if (hcsProcess->state() == QProcess::Running) {
        qCDebug(logCategoryStrataDevStudio) << "killing HCS";
        hcsProcess->kill();
    }
#else
    if (hcsProcess->state() == QProcess::Running) {
        qCDebug(logCategoryStrataDevStudio) << "terminating HCS";
        hcsProcess->terminate();
        QThread::msleep(100);   //This needs to be here, otherwise 'waitForFinished' waits until timeout
        if (hcsProcess->waitForFinished(10000) == false) {
            qCDebug(logCategoryStrataDevStudio) << "termination failed, killing HCS";
            hcsProcess->kill();
            if (!hcsProcess->waitForFinished()) {
                qCWarning(logCategoryStrataDevStudio) << "Failed to kill HCS server";
            }
        }
    }
#endif // windows check to kill hcs3
#endif // start services

    return appResult;
}
