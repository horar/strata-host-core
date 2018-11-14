#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QtWebEngine>


int main(int argc, char *argv[])
{
    // [Faller] HACK: Temporary fix for https://bugreports.qt.io/browse/QTBUG-70228
    const auto chromiumFlags = qgetenv("QTWEBENGINE_CHROMIUM_FLAGS");
    if (!chromiumFlags.contains("disable-web-security")) {
        qputenv("QTWEBENGINE_CHROMIUM_FLAGS", chromiumFlags + " --disable-web-security");
    }

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QtWebEngine::initialize();

    QQmlApplicationEngine engine;

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
