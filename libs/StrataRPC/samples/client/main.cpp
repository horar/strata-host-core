#include "Client.h"

#include <QtLoggerSetup.h>
#include <QCommandLineParser>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSettings>
#include <QtWidgets/QApplication>

int main(int argc, char *argv[])
{
    QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication::setApplicationName(QStringLiteral("strataRPC Client Sample"));
    QApplication::setOrganizationName("ON Semiconductor");
    QApplication app(argc, argv);

    QSettings::setDefaultFormat(QSettings::IniFormat);

    const strata::loggers::QtLoggerSetup loggerInitialization(app);

    QCommandLineParser parser;
    parser.addHelpOption();
    QCommandLineOption clientIdOption(QStringList() << "i"
                                                    << "client-id",
                                      QObject::tr("zmq client id"), QObject::tr("clientId"));
    parser.addOption(clientIdOption);
    parser.process(app);

    QString clientId = "";

    if (true == parser.isSet("i")) {
        clientId = parser.value("i");
    }

    QQmlApplicationEngine engine;
    std::unique_ptr<Client> client_(new Client(clientId));
    engine.rootContext()->setContextProperty("Client", client_.get());

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreated, &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl) QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);
    engine.load(url);

    client_->init();
    client_->start();

    return app.exec();
}
