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
#include "HostControllerClient.hpp"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    qmlRegisterType<ImplementationInterfaceBinding>("tech.spyglass.ImplementationInterfaceBinding",1,0,"ImplementationInterfaceBinding");
    qmlRegisterType<Document>("tech.spyglass.Document", 1, 0, "Document");
    qmlRegisterType<DocumentManager>("tech.spyglass.DocumentManager", 1, 0, "DocumentManager");
    qmlRegisterType<DataCollector>("tech.spyglass.DataCollector",1,0,"DataCollector");

    // all communications to Host Controller Service go through singleton Host Controller Client
    HCC::HostControllerClient * host_controller_client = HCC::HostControllerClient::getInstance();

    // various control modules
    DocumentManager* documentManager = new DocumentManager(host_controller_client);
    ImplementationInterfaceBinding *implementationInterfaceBinding = new ImplementationInterfaceBinding(documentManager,
                                                                                                        host_controller_client);
    DataCollector* dataCollector = new DataCollector();
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

// Only start HCS for release
#ifdef _WIN32 && QT_NO_DEBUG
    // Start HCS before handling events for QT
    qDebug() << "Starting HCS";
    QString hcsPath = "HCS/HCS.exe";

    // Argument list for HCS; Path depends on if we are
    QStringList arguments;
    arguments << "-f" << "HCS/host_controller_service.config";

    // Create a QProcess
    QProcess *hcsProcess = new QProcess(nullptr);
    hcsProcess->setStandardOutputFile("hcs_output.log");
    hcsProcess->setStandardErrorFile("hcs_error.log");
    hcsProcess->setWorkingDirectory(app.applicationDirPath());
    hcsProcess->start(hcsPath,arguments);
#endif

    // Call QT and stay here until the application quits.
    int appResult = app.exec();

#ifdef _WIN32 && QT_NO_DEBUG
    // Do some last minute clean-up; Terminate HCS
    qDebug() << "Killing HCS";
    hcsProcess->kill();
#endif

    host_controller_client->closeConnection();

    return appResult;
}
