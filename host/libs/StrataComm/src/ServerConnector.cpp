#include "ServerConnector.h"
#include <QString>
#include "logging/LoggingQtCategories.h"

using namespace strata::strataComm;

ServerConnector::~ServerConnector(){
    qCDebug(logCategoryStrataServerConnector) << "destroying the server";
    connector_->close();
}

bool ServerConnector::initilize() {
    using Connector = strata::connector::Connector;
    connector_ = Connector::getConnector(Connector::CONNECTOR_TYPE::ROUTER);

    if (false == connector_->open(serverAddress_)) {
        qCCritical(logCategoryStrataServerConnector) << "Failed to open ServerConnector.";
        return false;
    }

    readSocketNotifier_ = new QSocketNotifier(connector_->getFileDescriptor(), QSocketNotifier::Type::Read, this);
    connect(readSocketNotifier_, &QSocketNotifier::activated, this, &ServerConnector::readNewMessages);

    return true;
}

void ServerConnector::readNewMessages(int socket) {
    readSocketNotifier_->setEnabled(false);
    std::string message;
    for(;;) {
        if (connector_->read(message) == false) {
            break;
        }
        qCDebug(logCategoryStrataServerConnector) << "message received. Client ID:" << QByteArray::fromStdString(connector_->getDealerID()).toHex() << "Message:" << QString::fromStdString(message);
        emit newMessageRecived(QByteArray::fromStdString(connector_->getDealerID()), QString::fromStdString(message));
    }
    readSocketNotifier_->setEnabled(true);
}

void ServerConnector::readMessages() {
    std::string message;
    for(;;) {
        if (connector_->read(message) == false) {
            break;
        }
        qCDebug(logCategoryStrataServerConnector) << QString::fromStdString(connector_->getDealerID());
        qCDebug(logCategoryStrataServerConnector) << QString::fromStdString(message);
    }
}

void ServerConnector::sendMessage(const QByteArray &clientId, const QString &message) {
    qCDebug(logCategoryStrataServerConnector) << "Sending message. Client ID:" << clientId.toHex() << "Message:" << message;
    
    // interesting design in connector. Assumes there is only one "dealer". i.e. one and only one client.
    connector_->setDealerID(clientId.toStdString());
    if (false == connector_->send(message.toStdString())) {
        qCCritical(logCategoryStrataServerConnector) << "Failed to send message to client ID:" << clientId;
    }
}
