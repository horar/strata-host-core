#include "ClientConnector.h"
#include "logging/LoggingQtCategories.h"

#include <QString>

using namespace strata::strataRPC;

ClientConnector::~ClientConnector()
{
    disconnectClient();
}

bool ClientConnector::initializeConnector()
{
    using Connector = strata::connector::Connector;

    if (connector_) {
        qInfo(logCategoryStrataClientConnector) << "ZMQ connector already created.";
    } else {
        connector_ = Connector::getConnector(Connector::CONNECTOR_TYPE::DEALER);
    }

    connector_->setDealerID(dealerId_.toStdString());
    if (false == connectClient()) {
        qCCritical(logCategoryStrataClientConnector)
            << "Failed to open ClientConnector. Or Client already connected.";
        emit errorOccured(ClientConnectorError::FailedToConnect,
                          "Failed to open ClientConnector. Or Client already connected.");
        return false;
    }

    emit clientInitialized();
    emit clientConnected();
    return true;
}

bool ClientConnector::disconnectClient()
{
    qCDebug(logCategoryStrataClientConnector) << "Disconnecting client.";

    if (connector_ && true == connector_->close()) {
        if (readSocketNotifier_) {
            disconnect(readSocketNotifier_.get(), &QSocketNotifier::activated, this,
                       &ClientConnector::readNewMessages);
            readSocketNotifier_.reset();
        }
        emit clientConnected();
        return true;
    }

    qCCritical(logCategoryStrataClientConnector) << "Failed to disconnect client.";
    emit errorOccured(ClientConnectorError::FailedToDisconnect, "Failed to disconnect client.");
    return false;
}

bool ClientConnector::connectClient()
{
    if (!connector_) {
        qCCritical(logCategoryStrataClientConnector) << "Uninitialized connector.";
        emit errorOccured(ClientConnectorError::FailedToConnect, "Uninitialized connector.");
        return false;
    }

    if (true == connector_->isConnected()) {
        qCCritical(logCategoryStrataClientConnector) << "Client already connected.";
        emit errorOccured(ClientConnectorError::FailedToConnect, "Client already connected.");
        return false;
    }

    if (false == connector_->open(serverAddress_.toStdString())) {
        qCCritical(logCategoryStrataClientConnector) << "Failed to open ClientConnector.";
        emit errorOccured(ClientConnectorError::FailedToConnect, "Failed to open ClientConnector.");
        return false;
    }

    readSocketNotifier_ = std::make_unique<QSocketNotifier>(connector_->getFileDescriptor(),
                                                            QSocketNotifier::Type::Read, this);
    connect(readSocketNotifier_.get(), &QSocketNotifier::activated, this,
            &ClientConnector::readNewMessages);

    readMessages();

    emit clientConnected();
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
    for (;;) {
        if (connector_->read(message) == false) {
            break;
        }
        emit newMessageReceived(QByteArray::fromStdString(message));
    }
}

bool ClientConnector::sendMessage(const QByteArray &message)
{
    if (connector_) {
        if (false == connector_->isConnected()) {
            qCCritical(logCategoryStrataClientConnector)
                << "Failed to send message. Client is not connected.";
            emit errorOccured(ClientConnectorError::FailedToSend,
                              "Failed to send message. Client is not connected.");
            return false;
        }

        if (false == connector_->send(message.toStdString())) {
            qCCritical(logCategoryStrataClientConnector) << "Failed to send message.";
            emit errorOccured(ClientConnectorError::FailedToSend, "Failed to send message.");
            return false;
        }

    } else {
        qCCritical(logCategoryStrataClientConnector)
            << "Failed to send message. Connector is not initialized.";
        emit errorOccured(ClientConnectorError::FailedToSend,
                          "Failed to send message. Connector is not initialized.");

        return false;
    }

    return true;
}
