/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "ServerConnector.h"
#include "logging/LoggingQtCategories.h"

#include <QString>
#include <QThread>

using namespace strata::strataRPC;

ServerConnector::~ServerConnector()
{
    if (connector_) {
        connector_->close();
    }
}

bool ServerConnector::initialize()
{
    using Connector = strata::connector::Connector;

    if (connector_) {
        qCInfo(lcStrataClientConnector) << "ZMQ connector already created.";
    } else {
        connector_ = Connector::getConnector(Connector::CONNECTOR_TYPE::ROUTER);
    }

    if (false == connector_->open(serverAddress_.toStdString())) {
        qCCritical(lcStrataClientConnector) << "Failed to open ServerConnector";
        emit errorOccurred(strata::strataRPC::ServerInitialializationError);
        return false;
    }

    readSocketNotifier_ =
        new QSocketNotifier(connector_->getFileDescriptor(), QSocketNotifier::Type::Read, this);
    connect(readSocketNotifier_, &QSocketNotifier::activated, this,
            &ServerConnector::readNewMessages);

    QObject::connect(this, &ServerConnector::messagesQueued, this,
                     &ServerConnector::readNewMessages, Qt::QueuedConnection);

    emit initialized();
    return true;
}

void ServerConnector::readNewMessages(/*int socket*/)
{
    readSocketNotifier_->setEnabled(false);
    std::string message;
    while (connector_->read(message)) {
        qCDebug(lcStrataServerConnector).nospace().noquote()
            << "message received. ClientID: 0x"
            << QByteArray::fromStdString(connector_->getDealerID()).toHex() << ", Message: '"
            << QByteArray::fromStdString(message) << "'";
        emit messageReceived(QByteArray::fromStdString(connector_->getDealerID()),
                             QByteArray::fromStdString(message));
    }
    readSocketNotifier_->setEnabled(true);
}

void ServerConnector::readMessages()
{
    std::string message;
    for (;;) {
        if (connector_->read(message) == false) {
            break;
        }
    }
}

bool ServerConnector::sendMessage(const QByteArray &clientId, const QByteArray &message)
{
    qCDebug(lcStrataServerConnector).nospace().noquote()
        << "Sending message. ClientID: 0x" << clientId.toHex() << ", Message: '" << message << "'";

    if (nullptr == connector_) {
        qCCritical(lcStrataClientConnector) << "Failed to send message. Connector is not initialized.";
        emit errorOccurred(strata::strataRPC::TransportError);
        return false;
    }

    // Based on zmq implementation, there is no straight forward way to verify if a client with
    // a specific client id is connected.
    connector_->setDealerID(clientId.toStdString());

    if (false == connector_->send(message.toStdString())) {
        qCCritical(lcStrataClientConnector).noquote().nospace()
            << "Failed to send message to client. ClientID 0x:" << clientId.toHex();
        emit errorOccurred(strata::strataRPC::TransportError);
        return false;
    }

    if (connector_->hasReadEvent()) {
        emit messagesQueued(QPrivateSignal());
    }

    return true;
}
