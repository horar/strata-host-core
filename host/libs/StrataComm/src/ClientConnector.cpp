#include "ClientConnector.h"
#include <QString>
#include "logging/LoggingQtCategories.h"

using namespace strata::strataComm;

ClientConnector::~ClientConnector() {
    qCDebug(logCategoryStrataClientConnector) << "destroying the client";
    connector_->close();
}

bool ClientConnector::initilize() {
    using Connector = strata::connector::Connector;
    connector_ = Connector::getConnector(Connector::CONNECTOR_TYPE::DEALER);
    connector_->setDealerID(dealerId_);
    
    if (false == connector_->open(serverAddress_)) {
        qCCritical(logCategoryStrataClientConnector) << "Failed to open ClientConnector.";
        return false;
    }

    readSocketNotifier_ = new QSocketNotifier(connector_->getFileDescriptor(), QSocketNotifier::Type::Read, this);
    connect(readSocketNotifier_, &QSocketNotifier::activated, this, &ClientConnector::readNewMessages);

    readMessages();

    return true;
}

void ClientConnector::readNewMessages(/*int socket*/) {
    qCDebug(logCategoryStrataClientConnector) << "message received.";
    readSocketNotifier_->setEnabled(false);
    readMessages();
    readSocketNotifier_->setEnabled(true);
}

void ClientConnector::readMessages() {
    std::string message;
    for(;;) {
        // if (connector_->read(message, strata::connector::ReadMode::BLOCKING) == false) {
        if (connector_->read(message) == false) {
            break;
        }
        qCDebug(logCategoryStrataClientConnector) << QString::fromStdString(message);
        emit newMessageRecived(QString::fromStdString(message));
    }
}

void ClientConnector::sendMessage(const QString &message) {
    qCDebug(logCategoryStrataClientConnector) << "Sending message. Message:" << message;

    if (false == connector_->send(message.toStdString())) {
        qCCritical(logCategoryStrataClientConnector) << "Failed to send message";
    }
}
