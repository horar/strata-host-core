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
#include "QtOpenGL"
#include <QGLContext>
#include <QProcess>

#include "DocumentManager.h"
#include "DataCollector.h"
#include "ImplementationInterfaceBinding/ImplementationInterfaceBinding.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    qmlRegisterType<ImplementationInterfaceBinding>("tech.spyglass.ImplementationInterfaceBinding",1,0,"ImplementationInterfaceBinding");
    qmlRegisterType<Document>("tech.spyglass.Document", 1, 0, "Document");
    qmlRegisterType<DocumentManager>("tech.spyglass.DocumentManager", 1, 0, "DocumentManager");
    qmlRegisterType<DataCollector>("tech.spyglass.DataCollector",1,0,"DataCollector");
    ImplementationInterfaceBinding *implementationInterfaceBinding = new ImplementationInterfaceBinding();

    DocumentManager* documentManager = new DocumentManager(implementationInterfaceBinding);
    DataCollector* dataCollector = new DataCollector(implementationInterfaceBinding);
    QtWebEngine::initialize();
    QtWebView::initialize();

    QQmlApplicationEngine engine;
    engine.rootContext ()->setContextProperty ("implementationInterfaceBinding", implementationInterfaceBinding);
    engine.rootContext ()->setContextProperty ("documentManager", documentManager);
    engine.rootContext ()->setContextProperty ("dataCollector", dataCollector);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

// Starting services this build?
#ifdef START_SERVICES

    #ifdef Q_OS_WIN
    // We are at the build folder as root
    #define HOST_ROOT_PATH      (app.applicationDirPath())
    #define HCS_PATH            HOST_ROOT_PATH + "HCS/HCS.exe"
    #define HCS_CONFIG_PATH     HOST_ROOT_PATH + "HCS/host_controller_service.config"
    #endif

    #ifdef Q_OS_MACOS
    // We are pretty deep in the directory. Ex. ui/build-xxx-Release/spyglass.app/Contents/MacOs
    #define HOST_ROOT_PATH      (app.applicationDirPath() + "/../../../../../")
    #define HCS_PATH            HOST_ROOT_PATH + "HostControllerService/build/hcs"
    #define HCS_CONFIG_PATH     HOST_ROOT_PATH + "HostControllerService/files/conf/host_controller_service.config"
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
        hcsProcess->setStandardOutputFile("hcs_output.log");
        hcsProcess->setStandardErrorFile("hcs_error.log");
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
