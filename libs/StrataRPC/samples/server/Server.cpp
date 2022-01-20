/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "Server.h"
#include "logging/LoggingQtCategories.h"

#include <QDateTime>

using namespace strata::strataRPC;

Server::Server(QObject *parent)
    : QObject(parent),
      strataServer_(std::make_shared<StrataServer>(address_, true, this)),
      serverTimeBroadcastTimer_(this),
      randomGraph_(new RandomGraph(strataServer_, this))
{
    strataServer_->registerHandler(
        "close_server", std::bind(&Server::closeServerHandler, this, std::placeholders::_1));

    strataServer_->registerHandler(
        "server_status", std::bind(&Server::serverStatusHandler, this, std::placeholders::_1));

    strataServer_->registerHandler("ping", [this](const Message &message) {
        strataServer_->notifyClient(message, QJsonObject(), ResponseType::Response);
    });
}

Server::~Server()
{
}

void Server::init()
{
    qCDebug(lcStrataServerSample) << "Initializing Strata Server.";
    strataServer_->initialize();
}

void Server::start()
{
    connect(strataServer_.get(), &StrataServer::errorOccurred, this, &Server::serverErrorHandler);

    serverTimeBroadcastTimer_.setInterval(std::chrono::seconds(10));
    connect(&serverTimeBroadcastTimer_, &QTimer::timeout, this, &Server::serverTimeBroadcast);
    serverTimeBroadcastTimer_.start();
}

void Server::serverErrorHandler(StrataServer::ServerError errorType, const QString &errorMessage)
{
    qCDebug(lcStrataServerSample).noquote() << QString(84, '#');
    qCDebug(lcStrataServerSample) << "Error type:" << errorType;
    qCDebug(lcStrataServerSample) << "Error message:" << errorMessage;
    qCDebug(lcStrataServerSample).noquote() << QString(84, '#');

    if (errorType == StrataServer::ServerError::FailedToInitializeServer) {
        qCCritical(lcStrataServerSample) << "Failed to initialize the server. Aborting...";
        emit appDone(-1);
    }
}

void Server::closeServerHandler(const Message &message)
{
    strataServer_->notifyClient(message, QJsonObject{{"message", "server shutdown requested"}},
                                ResponseType::Response);
    qCInfo(lcStrataServerSample) << "Closing Strata Server...";
    emit appDone(0);
}

void Server::serverStatusHandler(const strata::strataRPC::Message &message)
{
    strataServer_->notifyClient(message, QJsonObject{{"status", "active"}}, ResponseType::Response);
}

void Server::serverTimeBroadcast()
{
    auto currentTimeString = QDateTime::currentDateTime().toString("hh:mm:ss t");
    qCInfo(lcStrataServerSample) << "Broadcasting server time." << currentTimeString;

    strataServer_->notifyAllClients("server_time", QJsonObject{{"time", currentTimeString}});
}
