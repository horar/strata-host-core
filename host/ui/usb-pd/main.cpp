#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtWebView/QtWebView>
#include "../../test/ui_binding_hcc/ImplementationInterfaceBinding/ImplementationInterfaceBinding.h"
#include <QtWebEngine>
#include <QtWidgets/QApplication>


int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    qmlRegisterType<ImplementationInterfaceBinding>("tech.spyglass.ImplementationInterfaceBinding",1,0,"ImplementationInterfaceBinding");

    QtWebEngine::initialize();
    QtWebView::initialize();

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
