#include "Server.h"
#include "logging/LoggingQtCategories.h"

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
    qCDebug(logCategoryStrataServerSample) << "in Server init";
    if (false == strataServer_->initializeServer()) {
        return false;
    }
    return true;
}

void Server::start()
{
    qCDebug(logCategoryStrataServerSample) << "in Server start";
    connect(strataServer_.get(), &StrataServer::errorOccurred, this, &Server::serverErrorHandler);
}

void Server::serverErrorHandler(StrataServer::ServerError errorType, const QString &errorMessage)
{
    qCDebug(logCategoryStrataServerSample) << "###############################################################";
    qCDebug(logCategoryStrataServerSample) << "Error type:" << static_cast<int>(errorType);
    qCDebug(logCategoryStrataServerSample) << "Error message:" << errorMessage;
    qCDebug(logCategoryStrataServerSample) << "###############################################################";
}
