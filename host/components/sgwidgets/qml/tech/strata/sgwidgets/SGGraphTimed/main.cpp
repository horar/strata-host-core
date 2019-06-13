#include <QApplication>
#include <QQmlApplicationEngine>

#include <QDebug>
#include <QResource>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);

    const auto resources = {QStringLiteral("component-fonts.rcc"), QStringLiteral("component-theme.rcc"),
                            QStringLiteral("component-sgwidgets.rcc")};
    const auto resourcePath = QCoreApplication::applicationDirPath();
    for (const auto &resourceName : resources) {
        qDebug() << "Loading '" << resourceName << "':"
                 << QResource::registerResource(
                        QString("%1/%2").arg(resourcePath).arg(resourceName));
    }

    QQmlApplicationEngine engine;
    engine.addImportPath(QStringLiteral("qrc:/"));

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreated, &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl) QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
