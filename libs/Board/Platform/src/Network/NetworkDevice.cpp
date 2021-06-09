#include <Network/NetworkDevice.h>

#include "logging/LoggingQtCategories.h"

namespace strata::device
{
NetworkDevice::NetworkDevice(QHostAddress deviceAddress, const QByteArray &deviceId,
                             const QString &name)
    : Device(deviceId, name, Type::NetworkDevice),
      tcpSocket_(new QTcpSocket(this)),
      deviceAddress_(deviceAddress),
      isConnected_(false)
{
    readBuffer_.reserve(READ_BUFFER_SIZE);

    // set up the tcp socket.
    connect(tcpSocket_.get(), &QTcpSocket::readyRead, this, &NetworkDevice::readMessages);
    connect(tcpSocket_.get(), &QTcpSocket::disconnected, this,
            &NetworkDevice::handleDeviceDiconnected);
    connect(tcpSocket_.get(), QOverload<QAbstractSocket::SocketError>::of(&QAbstractSocket::error),
            this, &NetworkDevice::handleError);
}

NetworkDevice::~NetworkDevice()
{
    close();
}

bool NetworkDevice::open()
{
    qDebug(logCategoryDeviceNetwork).nospace()
        << this << "Connecting to network device 0x" << hex << deviceId()
        << ", IP: " << deviceAddress_ << " Port: " << dec << TCP_PORT;

    if (tcpSocket_->isOpen()) {
        qCDebug(logCategoryDeviceNetwork) << this << "TCP socket already open.";
        return true;
    }

    tcpSocket_->connectToHost(deviceAddress_, TCP_PORT);
    qDebug(logCategoryDeviceNetwork).nospace()
        << this << "Connecting to network device 0x" << hex << deviceId() << ", Requested.";

    if (false == tcpSocket_->waitForConnected(TCP_CONNECT_TIMEOUT)) {
        qCDebug(logCategoryDeviceNetwork) << "connecting to platfrom timed-out.";
        return false;
    }

    return true;
}

void NetworkDevice::close()
{
    qCDebug(logCategoryDeviceNetwork)
        << this << "Disconnecting from network device 0x" << hex << deviceId()
        << ", IP: " << deviceAddress_.toString() << " Port: " << dec << TCP_PORT;
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

        qCDebug(logCategoryDeviceNetwork)
            << this << ": received message: " << QString::fromStdString(readBuffer_);
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

void NetworkDevice::handleDeviceDiconnected()
{
    qCDebug(logCategoryDeviceNetwork)
        << "Disconnected from network device address" << deviceAddress_.toString();
    emit deviceDisconnected();
    // emit deviceError(ErrorCode::DeviceDisconnected, "Network device disconnected.");
}
}  // namespace strata::device