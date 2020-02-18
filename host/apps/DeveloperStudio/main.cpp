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
#include <QSysInfo>
#ifdef Q_OS_WIN
#include <Shlwapi.h>
#include <ShlObj.h>
#endif

#include "StrataDeveloperStudioVersion.h"

#include <PlatformInterface/core/CoreInterface.h>

#include <QtLoggerSetup.h>
#include "logging/LoggingQtCategories.h"

#include "DocumentManager.h"
#include "ResourceLoader.h"

#include "timestamp.h"

void terminateAllRunningHcsInstances()    {

    // Set up the process object and connect it's stdin/out to print to the log
    QProcess TerminateHcs;
    QObject::connect(&TerminateHcs, &QProcess::readyReadStandardOutput, [&]() {
        const QString commandOutput{QString::fromLatin1(TerminateHcs.readAllStandardOutput())};
        for (const auto& line : commandOutput.split(QRegExp("\n|\r\n|\r"))) {
            qCDebug(logCategoryStrataDevStudio) << line;
        }
    } );
    QObject::connect(&TerminateHcs, &QProcess::readyReadStandardError, [&]() {
        const QString commandOutput{QString::fromLatin1(TerminateHcs.readAllStandardError())};
        for (const auto& line : commandOutput.split(QRegExp("\n|\r\n|\r"))) {
            qCCritical(logCategoryStrataDevStudio) << line;
        }
    });

#ifdef Q_OS_WIN
    TerminateHcs.start("taskkill /im hcs.exe /f", QIODevice::ReadOnly);
    TerminateHcs.waitForFinished();

    switch (TerminateHcs.exitCode()) {
        case 0:
            qCInfo(logCategoryStrataDevStudio) << QStringLiteral("Previous hcs instances were found and terminated successfully.");
            break;

        case 128:
            qCInfo(logCategoryStrataDevStudio) << QStringLiteral("No previous hcs instances were found.");
            break;

        default:
            qCInfo(logCategoryStrataDevStudio) << QStringLiteral("Failed to check for running hcs instances.");
            break;
    }
#endif
#ifdef Q_OS_MACOS
    TerminateHcs.start("pkill -9 hcs", QIODevice::ReadOnly);
    TerminateHcs.waitForFinished();

    switch (TerminateHcs.exitCode()) {
        case 0:
            qCInfo(logCategoryStrataDevStudio) << QStringLiteral("Previous hcs instances were found and terminated successfully.");
            break;

        case 1:
            qCInfo(logCategoryStrataDevStudio) << QStringLiteral("No previous hcs instances were found.");
            break;

        default:
            qCInfo(logCategoryStrataDevStudio) << QStringLiteral("Failed to check for running hcs instances.");
            break;
    }
#endif
}

int main(int argc, char *argv[])
{
#if defined(Q_OS_WIN)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    // [Faller] HACK: Temporary fix for https://bugreports.qt.io/browse/QTBUG-70228
    // [Carik]: this will be obsoleted once CS-123 is merged
    const auto chromiumFlags = qgetenv("QTWEBENGINE_CHROMIUM_FLAGS");
    if (!chromiumFlags.contains("disable-web-security")) {
        qputenv("QTWEBENGINE_CHROMIUM_FLAGS", chromiumFlags + " --disable-web-security");
    }

    QSettings::setDefaultFormat(QSettings::IniFormat);
    QGuiApplication::setApplicationDisplayName(QStringLiteral("ON Semiconductor: Strata Developer Studio"));
    QGuiApplication::setApplicationVersion(version);
    QCoreApplication::setOrganizationName(QStringLiteral("ON Semiconductor"));

#if QT_VERSION >= 0x051300
    QtWebEngine::initialize();
#endif

    QApplication app(argc, argv);
    app.setWindowIcon(QIcon(":/resources/icons/app/on-logo.png"));

    const QtLoggerSetup loggerInitialization(app);

#if QT_VERSION < 0x051300
    QtWebEngine::initialize();
#endif
    qCInfo(logCategoryStrataDevStudio) << QStringLiteral("================================================================================");
    qCInfo(logCategoryStrataDevStudio) << QStringLiteral("%1 %2").arg(QCoreApplication::applicationName()).arg(QCoreApplication::applicationVersion());
    qCInfo(logCategoryStrataDevStudio) << QStringLiteral("Build on %1 at %2").arg(buildTimestamp, buildOnHost);
    qCInfo(logCategoryStrataDevStudio) << QStringLiteral("--------------------------------------------------------------------------------");
    qCInfo(logCategoryStrataDevStudio) << QStringLiteral("Powered by Qt %1 (based on Qt %2)").arg(QString(qVersion()), qUtf8Printable(QT_VERSION_STR));
    qCInfo(logCategoryStrataDevStudio) << QStringLiteral("Running on %1").arg(QSysInfo::prettyProductName());
    qCInfo(logCategoryStrataDevStudio) << QStringLiteral("[arch: %1; kernel: %2 (%3); locale: %4]").arg(QSysInfo::currentCpuArchitecture(), QSysInfo::kernelType(), QSysInfo::kernelVersion(), QLocale::system().name());
    qCInfo(logCategoryStrataDevStudio) << QStringLiteral("================================================================================");

    // This is just a temporary fix until we have strata monitor ready.
    // Terminate all running instances of hcs as this will cause communication problems between the UI and the platforms.
    terminateAllRunningHcsInstances();

    ResourceLoader resourceLoader;

    qmlRegisterUncreatableType<CoreInterface>("tech.strata.CoreInterface",1,0,"CoreInterface", QStringLiteral("You can't instantiate CoreInterface in QML"));
    qmlRegisterUncreatableType<DocumentManager>("tech.strata.DocumentManager", 1, 0, "DocumentManager", QStringLiteral("You can't instantiate DocumentManager in QML"));
    qmlRegisterUncreatableType<DownloadDocumentListModel>("tech.strata.DownloadDocumentListModel", 1, 0, "DownloadDocumentListModel", "You can't instantiate DownloadDocumentListModel in QML");
    qmlRegisterUncreatableType<DocumentListModel>("tech.strata.DocumentListModel", 1, 0, "DocumentListModel", "You can't instantiate DocumentListModel in QML");


    CoreInterface *coreInterface = new CoreInterface();
    DocumentManager* documentManager = new DocumentManager(coreInterface);
    //DataCollector* dataCollector = new DataCollector(coreInterface);

    QQmlApplicationEngine engine;
    QQmlFileSelector selector(&engine);

    QDir applicationDir(QCoreApplication::applicationDirPath());
#ifdef Q_OS_MACOS
    applicationDir.cdUp();
    applicationDir.cdUp();
    applicationDir.cdUp();
#endif
    bool status = applicationDir.cd("imports");
    if (status == false) {
        qCCritical(logCategoryStrataDevStudio) << "failed to find import path.";
    }
    engine.addImportPath(applicationDir.path());

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
    const QString hcsConfigPath{ QDir::cleanPath(QString("%1/../../apps/hcs3/files/conf/%2").arg(app.applicationDirPath(), QStringLiteral(HCS_CONFIG)))};
#endif
#endif
#ifdef Q_OS_MACOS
    const QString hcsPath{ QDir::cleanPath(QString("%1/../../../hcs").arg(app.applicationDirPath())) };
    const QString hcsConfigPath{ QDir::cleanPath( QString("%1/../../../../../apps/hcs3/files/conf/%2").arg(app.applicationDirPath(), QStringLiteral(HCS_CONFIG)))};
#endif
#ifdef Q_OS_LINUX
    const QString hcsPath{ QDir::cleanPath(QString("%1/hcs").arg(app.applicationDirPath())) };
    const QString hcsConfigPath{ QDir::cleanPath(QString("%1/../../apps/hcs3/files/conf/host_controller_service.config").arg(app.applicationDirPath()))};
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
