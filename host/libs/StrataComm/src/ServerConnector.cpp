#include "ServerConnector.h"
#include <QString>
#include "logging/LoggingQtCategories.h"

using namespace strata::strataComm;

ServerConnector::~ServerConnector()
{
    qCDebug(logCategoryStrataServerConnector) << "destroying the server";

    if (connector_) {
        connector_->close();
    }
}

bool ServerConnector::initilizeConnector()
{
    using Connector = strata::connector::Connector;
    connector_ = Connector::getConnector(Connector::CONNECTOR_TYPE::ROUTER);

    if (false == connector_->open(serverAddress_.toStdString())) {
        qCCritical(logCategoryStrataServerConnector) << "Failed to open ServerConnector.";
        return false;
    }

    readSocketNotifier_ =
        new QSocketNotifier(connector_->getFileDescriptor(), QSocketNotifier::Type::Read, this);
    connect(readSocketNotifier_, &QSocketNotifier::activated, this,
            &ServerConnector::readNewMessages);

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
        qCDebug(logCategoryStrataServerConnector)
            << "message received. Client ID:"
            << QByteArray::fromStdString(connector_->getDealerID()).toHex()
            << "Message:" << QByteArray::fromStdString(message);
        emit newMessageRecived(QByteArray::fromStdString(connector_->getDealerID()),
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
        qCDebug(logCategoryStrataServerConnector)
            << QByteArray::fromStdString(connector_->getDealerID());
        qCDebug(logCategoryStrataServerConnector) << QByteArray::fromStdString(message);
    }
}

bool ServerConnector::sendMessage(const QByteArray &clientId, const QByteArray &message)
{
    qCDebug(logCategoryStrataServerConnector)
        << "Sending message. Client ID:" << clientId.toHex() << "Message:" << message;

    if (connector_) {
        connector_->setDealerID(clientId.toStdString());

        // Based on zmq implementation, there is no straight forward way to verify if a client with
        // a specific client id is connected.
        if (false == connector_->send(message.toStdString())) {
            qCCritical(logCategoryStrataServerConnector)
                << "Failed to send message to client ID:" << clientId;
            return false;
        }
    } else {
        qCCritical(logCategoryStrataServerConnector)
            << "Failed to send message. Connector is not initialized.";
        return false;
    }
    return true;
}
