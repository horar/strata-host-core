#include <QApplication>
#include <QQmlApplicationEngine>

#include <QDebug>
#include <QDirIterator>
#include <QResource>

#include <QLibraryInfo>

int main(int argc, char* argv[])
{
    QString resourcePath;
#ifdef Q_OS_MACOS
    QDir applicationDir(QCoreApplication::applicationDirPath());
    applicationDir.cdUp();
    applicationDir.cdUp();
    applicationDir.cdUp();

    resourcePath = applicationDir.path();
#else
    resourcePath = QCoreApplication::applicationDirPath();
#endif

    const auto resources = {QStringLiteral("fonts.rcc"), QStringLiteral("theme.rcc"),
                            QStringLiteral("sgwidgets.rcc")};
    for (const auto& resourceName : resources) {
        qDebug() << "Loading '" << resourceName << "':"
                 << QResource::registerResource(
                        QString("%1/%2").arg(resourcePath).arg(resourceName));
    }

    qDebug() << "Source tree:";
    QDirIterator it(":", QDirIterator::Subdirectories);
    while (it.hasNext()) {
        qDebug() << it.next();
    }

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    // https://stackoverflow.com/questions/34099236/qtquick-chartview-qml-object-seg-faults-causes-qml-engine-segfault-during-load
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;
    engine.addImportPath(QStringLiteral("qrc:/"));

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
