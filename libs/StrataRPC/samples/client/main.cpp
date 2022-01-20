/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
    QApplication::setOrganizationName("onsemi");
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

    // make sure that objects in context properties are declared before engine, to maintain proper order of destruction
    std::unique_ptr<Client> client_(new Client(clientId));

    QQmlApplicationEngine engine;

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
