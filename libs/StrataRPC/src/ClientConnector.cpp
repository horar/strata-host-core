#include "ClientConnector.h"
#include "logging/LoggingQtCategories.h"

#include <QString>

using namespace strata::strataRPC;

ClientConnector::~ClientConnector()
{
    disconnect();
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
        qInfo(logCategoryStrataClientConnector) << "ZMQ connector already created.";
    } else {
        connector_ = Connector::getConnector(Connector::CONNECTOR_TYPE::DEALER);
    }

    connector_->setDealerID(dealerId_.toStdString());
    if (false == connect()) {
        qCCritical(logCategoryStrataClientConnector)
            << "Failed to open ClientConnector. Or Client already connected.";
        return false;
    }

    QObject::connect(this, &ClientConnector::messageAvailable, this,
                     &ClientConnector::readNewMessages, Qt::QueuedConnection);

    emit initialized();
    return true;
}

bool ClientConnector::disconnect()
{
    qCDebug(logCategoryStrataClientConnector) << "Disconnecting client.";

    if (connector_ && true == connector_->close()) {
        if (readSocketNotifier_) {
            QObject::disconnect(readSocketNotifier_.get(), &QSocketNotifier::activated, this,
                                &ClientConnector::readNewMessages);
            readSocketNotifier_.reset();
        }
        emit disconnected();
        return true;
    }

    QString errorMessage(QStringLiteral("Failed to disconnect client."));
    qCCritical(logCategoryStrataClientConnector) << errorMessage;
    emit errorOccurred(ClientConnectorError::FailedToDisconnect, errorMessage);
    return false;
}

bool ClientConnector::connect()
{
    if (!connector_) {
        QString errorMessage(QStringLiteral("Uninitialized connector."));
        qCCritical(logCategoryStrataClientConnector) << errorMessage;
        emit errorOccurred(ClientConnectorError::FailedToConnect, errorMessage);
        return false;
    }

    if (true == connector_->isConnected()) {
        QString errorMessage(QStringLiteral("Client already connected."));
        qCCritical(logCategoryStrataClientConnector) << errorMessage;
        emit errorOccurred(ClientConnectorError::FailedToConnect, errorMessage);
        return false;
    }

    if (false == connector_->open(serverAddress_.toStdString())) {
        QString errorMessage(QStringLiteral("Failed to open ClientConnector."));
        qCCritical(logCategoryStrataClientConnector) << errorMessage;
        emit errorOccurred(ClientConnectorError::FailedToConnect, errorMessage);
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
    while (true == connector_->read(message)) {
        emit messageReceived(QByteArray::fromStdString(message));
    }
}

bool ClientConnector::sendMessage(const QByteArray &message)
{
    if (!connector_) {
        QString errorMessage(
            QStringLiteral("Failed to send message. Connector is not initialized."));
        qCCritical(logCategoryStrataClientConnector) << errorMessage;
        emit errorOccurred(ClientConnectorError::FailedToSend, errorMessage);
        return false;
    }

    if (false == connector_->isConnected()) {
        QString errorMessage(QStringLiteral("Failed to send message. Client is not connected."));
        qCCritical(logCategoryStrataClientConnector) << errorMessage;
        emit errorOccurred(ClientConnectorError::FailedToSend, errorMessage);
        return false;
    }

    if (false == connector_->send(message.toStdString())) {
        QString errorMessage(QStringLiteral("Failed to send message."));
        qCCritical(logCategoryStrataClientConnector) << errorMessage;
        emit errorOccurred(ClientConnectorError::FailedToSend, errorMessage);
        return false;
    }

    if (true == connector_->hasReadEvent()) {
        emit messageAvailable();
    }

    return true;
}
