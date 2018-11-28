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

#include <PlatformInterface/core/CoreInterface.h>

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

    QApplication app(argc, argv);
    QQmlApplicationEngine engine;

    qmlRegisterType<CoreInterface>("tech.spyglass.CoreInterface",1,0,"CoreInterface");
    qmlRegisterType<DocumentManager>("tech.spyglass.DocumentManager", 1, 0, "DocumentManager");
    qmlRegisterType<Document>("tech.spyglass.Document", 1, 0, "Document");
    qmlRegisterSingletonType(QUrl("qrc:/fonts/Fonts.qml"), "Fonts", 1, 0, "Fonts");

    CoreInterface *coreInterface = new CoreInterface();
    DocumentManager* documentManager = new DocumentManager(coreInterface);
    //DataCollector* dataCollector = new DataCollector(coreInterface);

    QtWebEngine::initialize();
    QtWebView::initialize();

    engine.rootContext ()->setContextProperty ("coreInterface", coreInterface);
    engine.rootContext ()->setContextProperty ("documentManager", documentManager);

    //engine.rootContext ()->setContextProperty ("dataCollector", dataCollector);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    // Starting services this build?
    // [prasanth] : Important note: Start HCS before launching the UI
    // So the service callback works properly
    #define START_SERVICES
    #ifdef START_SERVICES

        #ifdef Q_OS_WIN
        // We are at the build folder as root
        #define HOST_ROOT_PATH      (app.applicationDirPath())
        #define HCS_PATH            HOST_ROOT_PATH + "/HCS/HCS.exe"
        #define HCS_CONFIG_PATH     HOST_ROOT_PATH + "/HCS/host_controller_service.config"
        #endif

        #ifdef Q_OS_MACOS
        // We are pretty deep in the directory. Ex. ui/build-xxx-Release/spyglass.app/Contents/MacOs
        #define HOST_ROOT_PATH      (app.applicationDirPath() + "/../../../../../")
        #define HCS_PATH            HOST_ROOT_PATH + "build/apps/hcs2/hcs2"
        #define HCS_CONFIG_PATH     HOST_ROOT_PATH + "apps/hcs2/files/conf/host_controller_service.config_template"
        #endif

        #ifdef Q_OS_LINUX
        // We are at the build folder
        #define HOST_ROOT_PATH      (app.applicationDirPath() + "/../../")
        #define HCS_PATH            HOST_ROOT_PATH + "HostControllerService/build/hcs"
        #define HCS_CONFIG_PATH     HOST_ROOT_PATH + "HostControllerService/files/conf/host_controller_service.config"
        #endif

        /* This is the same across all platforms
        */

        // Ensure HCS exists
        QFileInfo hcs_file(HCS_PATH);
        bool hcs_started = false;

        // Create a QProcess
        QProcess *hcsProcess = new QProcess(nullptr);

        if(hcs_file.exists()) {
            hcs_started = true;

            // Start HCS before handling events for QT
            qDebug() << "Starting HCS: " << HCS_PATH;
            QString hcsPath = HCS_PATH;

            // Argument list for HCS
            QStringList arguments;
            arguments << "-f" << HCS_CONFIG_PATH;

            // Start HCS
        //    hcsProcess->setProcessChannelMode(QProcess::ForwardedChannels);
            hcsProcess->start(hcsPath,arguments, QIODevice::ReadWrite);
        }
        else {
            hcs_started = false;
            qDebug() << "Failed to start HCS: Does not exist";
        }

    #endif
    // Call QT and stay here until the application quits.
    int appResult = app.exec();

#ifdef START_SERVICES
    if (hcs_started) {
        // Do some last minute clean-up; Terminate HCS
        qDebug() << "Killing HCS";
        hcsProcess->kill();
    }
#endif

    return appResult;
}
