#include "Server.h"

#include <QtLoggerSetup.h>
#include <QCoreApplication>
#include <QSettings>
#include <QtCore>

int main(int argc, char* argv[])
{
    QCoreApplication::setApplicationName(QStringLiteral("strataRPC Server Sample"));
    QCoreApplication::setOrganizationName(QStringLiteral("ON Semiconductor"));
    QCoreApplication theApp(argc, argv);

    QSettings::setDefaultFormat(QSettings::IniFormat);

    const strata::loggers::QtLoggerSetup loggerInitialization(theApp);

    std::shared_ptr<Server> server_(new Server);
    QObject::connect(server_.get(), &Server::appDone, &theApp, &QCoreApplication::exit);

    server_->init();
    server_->start();

    return theApp.exec();
}
