#include <Network/NetworkDevice.h>

#include "logging/LoggingQtCategories.h"

namespace strata::device
{
NetworkDevice::NetworkDevice(QHostAddress deviceAddress, quint16 tcpPort)
    : Device(createDeviceId(deviceAddress), deviceAddress.toString(), Type::NetworkDevice),
      tcpSocket_(new QTcpSocket(this)),
      deviceAddress_(deviceAddress),
      isConnected_(false),
      tcpPort_(tcpPort)
{
    readBuffer_.reserve(READ_BUFFER_SIZE);
}

NetworkDevice::~NetworkDevice()
{
    close();
}

bool NetworkDevice::open()
{
    qDebug(logCategoryDeviceNetwork).nospace()
        << this << "Connecting network device:" << deviceId_ << ", IP:" << deviceAddress_.toString()
        << " Port:" << tcpPort_;

    if (tcpSocket_->isOpen()) {
        qCDebug(logCategoryDeviceNetwork) << this << "TCP socket already open.";
        return true;
    }

    tcpSocket_->connectToHost(deviceAddress_, tcpPort_);

    if (false == tcpSocket_->waitForConnected(TCP_CONNECT_TIMEOUT)) {
        QString errorString(QStringLiteral("Connecting to platfrom timed-out."));
        qCDebug(logCategoryDeviceNetwork) << errorString;
        tcpSocket_->close();
        emit deviceError(ErrorCode::DeviceFailedToOpen, errorString);
        return false;
    }

    connect(tcpSocket_.get(), &QTcpSocket::readyRead, this, &NetworkDevice::readMessages);
    connect(tcpSocket_.get(), &QTcpSocket::disconnected, this,
            &NetworkDevice::deviceDiconnectedHandler);
    connect(tcpSocket_.get(), QOverload<QAbstractSocket::SocketError>::of(&QAbstractSocket::error),
            this, &NetworkDevice::handleError);
    return true;
}

void NetworkDevice::close()
{
    qCDebug(logCategoryDeviceNetwork)
        << this << "Disconnecting from network device:" << deviceId_
        << ", IP:" << deviceAddress_.toString() << " Port:" << tcpPort_;

    disconnect(tcpSocket_.get(), nullptr, this, nullptr);
    if (true == tcpSocket_->isOpen()) {
        tcpSocket_->close();
    }
}

bool NetworkDevice::sendMessage(const QByteArray &message)
{
    if (false == message.endsWith('\n')) {
        tcpSocket_->write(message + '\n');
    } else {
        tcpSocket_->write(message);
    }

    if (false == tcpSocket_->waitForBytesWritten(TCP_WRITE_TIMEOUT)) {
        QString errMsg(QStringLiteral("Cannot write whole data to device."));
        qCCritical(logCategoryDeviceNetwork) << this << errMsg;
        emit deviceError(ErrorCode::DeviceError, errMsg);
        return false;
    }

    emit messageSent(message);
    return true;
}

bool NetworkDevice::isConnected() const
{
    return tcpSocket_->state() == QTcpSocket::ConnectedState;
}

void NetworkDevice::resetReceiving()
{
    if (readBuffer_.empty() == false) {
        readBuffer_.clear();
        qCDebug(logCategoryDeviceSerial)
            << this << "Cleared internal buffer for reading of received messages.";
    }
}

void NetworkDevice::readMessages()
{
    // QTcpSocket::readyRead signal is emitted when there is data ready to read and not when a
    // complete message is received. As a result we need a buffer to hold the data until the
    // transmission is complete. Based on the protocol of messaging between host and platform, a
    // newline character is used as the end of message indicator.

    const QByteArray data = tcpSocket_->readAll();
    int from = 0;
    int end;
    while ((end = data.indexOf('\n', from)) > -1) {
        readBuffer_.append(data.data() + from, static_cast<size_t>(end - from));
        from = end + 1;
        emit messageReceived(QByteArray::fromStdString(readBuffer_));
        readBuffer_.clear();
    }

    if (from < data.size()) {  // message contains some data after '\n' (or has no '\n')
        readBuffer_.append(data.data() + from, static_cast<size_t>(data.size() - from));
    }
}

void NetworkDevice::handleError(QAbstractSocket::SocketError socketError)
{
    Q_UNUSED(socketError);
    emit deviceError(ErrorCode::DeviceError, tcpSocket_->errorString());
}

void NetworkDevice::deviceDiconnectedHandler()
{
    qCDebug(logCategoryDeviceNetwork)
        << "Disconnected from network device address" << deviceAddress_.toString();
    emit deviceDisconnected();
}

QByteArray NetworkDevice::createDeviceId(QHostAddress hostAddress)
{
    return QByteArray('n' + QByteArray::number(qHash(hostAddress.toString()), 16));
}
}  // namespace strata::device