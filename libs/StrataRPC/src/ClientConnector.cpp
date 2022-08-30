/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "ClientConnector.h"
#include "logging/LoggingQtCategories.h"

#include <QString>

using namespace strata::strataRPC;

ClientConnector::~ClientConnector()
{
    if (isConnected()) {
        disconnect();
    }
}

bool ClientConnector::isConnected() const
{
    if (connector_) {
        return connector_->isConnected();
    }
    return false;
}

bool ClientConnector::initialize()
{
    using Connector = strata::connector::Connector;

    if (connector_) {
        qCInfo(lcStrataClientConnector) << "ZMQ connector already created.";
    } else {
        connector_ = Connector::getConnector(Connector::CONNECTOR_TYPE::DEALER);
    }

    connector_->setDealerID(dealerId_.toStdString());
    if (connect() == false) {
        return false;
    }

    QObject::connect(this, &ClientConnector::messagesQueued, this,
                     &ClientConnector::readNewMessages, Qt::QueuedConnection);

    emit initialized();
    return true;
}

bool ClientConnector::disconnect()
{
    qCDebug(lcStrataClientConnector) << "Disconnecting client.";

    if (connector_ && connector_->close()) {
        if (readSocketNotifier_) {
            QObject::disconnect(readSocketNotifier_.get(), &QSocketNotifier::activated, this,
                                &ClientConnector::readNewMessages);
            readSocketNotifier_.reset();
        }
        emit disconnected();
        return true;
    }

    qCCritical(lcStrataClientConnector) << "Failed to disconnect client.";
    emit errorOccurred(RpcErrorCode::DisconnectionError);
    return false;
}

bool ClientConnector::connect()
{
    QString errorMessage;
    if (nullptr == connector_) {
        errorMessage = "connector not initialized";
    } else if (connector_->isConnected()) {
        errorMessage = "connector already connected";
    } else if (connector_->open(serverAddress_.toStdString()) == false) {
        errorMessage = "cannot open connector";
    }

    if (errorMessage.isEmpty() == false) {
        qCCritical(lcStrataClientConnector) << errorMessage;
        emit errorOccurred(RpcErrorCode::ConnectionError);
        return false;
    }

    readSocketNotifier_ = std::make_unique<QSocketNotifier>(connector_->getFileDescriptor(),
                                                            QSocketNotifier::Type::Read, this);
    QObject::connect(readSocketNotifier_.get(), &QSocketNotifier::activated, this,
                     &ClientConnector::readNewMessages);

    readMessages();

    emit connected();
    return true;
}

void ClientConnector::readNewMessages(/*int socket*/)
{
    readSocketNotifier_->setEnabled(false);
    readMessages();
    readSocketNotifier_->setEnabled(true);
}

void ClientConnector::readMessages()
{
    std::string message;
    while (connector_->read(message)) {
        emit messageReceived(QByteArray::fromStdString(message));
    }
}

bool ClientConnector::sendMessage(const QByteArray &message)
{
    QString errorMessage;

    if (nullptr == connector_) {
        errorMessage = "connector is not initialized";
    } else if (false == connector_->isConnected()) {
        errorMessage = "connector is not connected";
    } else if (false == connector_->send(message.toStdString())) {
        errorMessage = "failed to send message";
    }

    if (errorMessage.isEmpty() == false) {
        qCCritical(lcStrataClientConnector) << errorMessage;
        emit errorOccurred(RpcErrorCode::TransportError);
        return false;
    }

    if (connector_->hasReadEvent()) {
        emit messagesQueued(QPrivateSignal());
    }

    return true;
}
