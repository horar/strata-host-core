#include "Server.h"
#include <QDebug>

using namespace strata::strataRPC;

Server::Server(QObject *parent)
    : QObject(parent), strataServer_(new StrataServer(address_, true, this))
{
}

Server::~Server()
{
}

bool Server::init()
{
    qDebug() << "in Server init";
    if (false == strataServer_->initializeServer()) {
        return false;
    }
    return true;
}

void Server::start()
{
    qDebug() << "in Server start";
    // connect signals.
    connect(strataServer_.get(), &StrataServer::errorOccurred, this, &Server::serverErrorHandler);
}

void Server::serverErrorHandler(StrataServer::ServerError errorType,
                                const QString &errorMessage)
{
    qDebug() << "###############################################################";
    qDebug() << "Error type:" << static_cast<int>(errorType);
    qDebug() << "Error message:" << errorMessage;
    qDebug() << "###############################################################";
}
