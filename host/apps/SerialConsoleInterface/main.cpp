#include "BoardsController.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    engine.addImportPath("qrc:///");

    qmlRegisterType<BoardsController>("tech.spyglass.sci", 1, 0, "BoardsController");
    qmlRegisterSingletonType(QUrl("qrc:/fonts/Fonts.qml"), "fonts", 1, 0, "Fonts");

    std::unique_ptr<BoardsController> boardsMgr(new BoardsController());
    boardsMgr->initialize();
    engine.rootContext()->setContextProperty("boardsMgr", boardsMgr.get());

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
