#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#endif

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtWebView/QtWebView>
#include <QtWebEngine>
#include <QtWidgets/QApplication>

#include "DocumentManager.h"
#include "ImplementationInterfaceBinding/ImplementationInterfaceBinding.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    qmlRegisterType<ImplementationInterfaceBinding>("tech.spyglass.ImplementationInterfaceBinding",1,0,"ImplementationInterfaceBinding");
    qmlRegisterType<Document>("tech.spyglass.Document", 1, 0, "Document");
    qmlRegisterType<DocumentManager>("tech.spyglass.DocumentManager", 1, 0, "DocumentManager");

    DocumentManager* documentManager = new DocumentManager();
    ImplementationInterfaceBinding *implementationInterfaceBinding = new ImplementationInterfaceBinding(static_cast<QObject *>(documentManager));
    
    QtWebEngine::initialize();
    QtWebView::initialize();

    QQmlApplicationEngine engine;

    engine.rootContext ()->setContextProperty ("implementationInterfaceBinding", implementationInterfaceBinding);
    engine.rootContext ()->setContextProperty ("documentManager", documentManager);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
