#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtWebView/QtWebView>
#include <UserInterfaceBinding.h>
#include <QtWebEngine>
#include <QtWidgets/QApplication>


int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    qmlRegisterType<UserInterfaceBinding>("tech.spyglass.userinterfacebinding",1,0,"UserInterfaceBinding");

    QtWebEngine::initialize();
    QtWebView::initialize();

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
