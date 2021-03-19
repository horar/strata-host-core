#include "Server.h"

#include <QCoreApplication>
#include <QtCore>

int main(int argc, char* argv[])
{
    QCoreApplication::setApplicationName(QStringLiteral("strataRPC-server-sample"));
    QCoreApplication theApp(argc, argv);

    std::shared_ptr<Server> server_(new Server);
    if (!server_->init()) {
        return -1;
    }

    QObject::connect(server_.get(), &Server::appDone, &theApp, &QCoreApplication::exit);
    server_->start();
    return theApp.exec();
}
