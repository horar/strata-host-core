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

#include <PlatformInterface/core/CoreInterface.h>

#include "DocumentManager.h"

int main(int argc, char *argv[])
{
#if defined(Q_OS_WIN)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QApplication app(argc, argv);
    QQmlApplicationEngine engine;

    qmlRegisterType<CoreInterface>("tech.spyglass.CoreInterface",1,0,"CoreInterface");
    qmlRegisterType<DocumentManager>("tech.spyglass.DocumentManager", 1, 0, "DocumentManager");
    qmlRegisterType<Document>("tech.spyglass.Document", 1, 0, "Document");

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

// Only start HCS for release
#if (_WIN32 && QT_NO_DEBUG)
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

#if _WIN32 && QT_NO_DEBUG
    // Do some last minute clean-up; Terminate HCS
    // [prasanth]: Added delay because UI should send remote diconnect to HCS and then to
    // discovery service. Closing without delay drops the message
    Sleep(3000);
    qDebug() << "Killing HCS";
    hcsProcess->kill();
#endif
    return appResult;
}
