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

bool ServerConnector::initializeConnector()
{
    using Connector = strata::connector::Connector;

    if (connector_) {
        qInfo(logCategoryStrataClientConnector) << "ZMQ connector already created.";
    } else {
        connector_ = Connector::getConnector(Connector::CONNECTOR_TYPE::ROUTER);
    }

    if (false == connector_->open(serverAddress_.toStdString())) {
        qCCritical(logCategoryStrataServerConnector) << "Failed to open ServerConnector.";
        emit errorOccred(ServerConnectorError::FailedToInitialize,
                         "Failed to open ServerConnector.");
        return false;
    }

    readSocketNotifier_ =
        new QSocketNotifier(connector_->getFileDescriptor(), QSocketNotifier::Type::Read, this);
    connect(readSocketNotifier_, &QSocketNotifier::activated, this,
            &ServerConnector::readNewMessages);

    emit serverInitialized();
    return true;
}

void ServerConnector::readNewMessages(/*int socket*/)
{
    readSocketNotifier_->setEnabled(false);
    std::string message;
    for (;;) {
        if (connector_->read(message) == false) {
            break;
        }
        qCDebug(logCategoryStrataServerConnector).nospace().noquote()
            << "message received. Client ID: 0x"
            << QByteArray::fromStdString(connector_->getDealerID()).toHex() << ", Message: '"
            << QByteArray::fromStdString(message) << "'";
        emit newMessageReceived(QByteArray::fromStdString(connector_->getDealerID()),
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
    qCDebug(logCategoryStrataServerConnector).nospace().noquote()
        << "Sending message. Client ID: 0x" << clientId.toHex() << ", Message: '" << message << "'";

    if (connector_) {
        connector_->setDealerID(clientId.toStdString());

        // Based on zmq implementation, there is no straight forward way to verify if a client with
        // a specific client id is connected.
        if (false == connector_->send(message.toStdString())) {
            qCCritical(logCategoryStrataServerConnector)
                << "Failed to send message to client ID:" << clientId;
            emit errorOccred(ServerConnectorError::FailedToSend,
                             "Failed to send message to client");
            return false;
        }
    } else {
        qCCritical(logCategoryStrataServerConnector)
            << "Failed to send message. Connector is not initialized.";
        emit errorOccred(ServerConnectorError::FailedToSend,
                         "Failed to send message. Connector is not initialized.");
        return false;
    }
    return true;
}
