#include "Server.h"
#include "logging/LoggingQtCategories.h"

using namespace strata::strataRPC;

Server::Server(QObject *parent)
    : QObject(parent), strataServer_(new StrataServer(address_, true, this))
{
    strataServer_->registerHandler(
        "close_server", std::bind(&Server::closeServerHandler, this, std::placeholders::_1));

    strataServer_->registerHandler(
        "server_status", std::bind(&Server::serverStatusHandler, this, std::placeholders::_1));
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
    qCDebug(logCategoryStrataServerSample)
        << "###############################################################";
    qCDebug(logCategoryStrataServerSample) << "Error type:" << static_cast<int>(errorType);
    qCDebug(logCategoryStrataServerSample) << "Error message:" << errorMessage;
    qCDebug(logCategoryStrataServerSample)
        << "###############################################################";
}

void Server::closeServerHandler(const Message &message)
{
    strataServer_->notifyClient(message, QJsonObject{{"message", "server shutdown requested"}}, ResponseType::Response);
    qCInfo(logCategoryStrataServerSample) << "Closing Strata Server...";
    emit appDone(0);
}

void Server::serverStatusHandler(const strata::strataRPC::Message &message) 
{
    strataServer_->notifyClient(message, QJsonObject{{"status", "active"}}, ResponseType::Response);
}
