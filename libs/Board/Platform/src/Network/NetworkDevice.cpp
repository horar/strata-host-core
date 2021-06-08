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
    // set up the tcp socket.
    connect(tcpSocket_.get(), &QTcpSocket::readyRead, this, &NetworkDevice::readMessages);
    connect(tcpSocket_.get(), &QTcpSocket::connected, this, &NetworkDevice::handleDeviceConnected);
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
        // emit deviceError(ErrorCode::SendMessageError, errMsg);
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
    QByteArray buffer = tcpSocket_->readAll();
    emit messageReceived(buffer);
}

void NetworkDevice::handleError(QAbstractSocket::SocketError socketError)
{
}

void NetworkDevice::handleWriteToDevice(QByteArray data)
{
}

void NetworkDevice::handleDeviceConnected()
{
}

void NetworkDevice::handleDeviceDiconnected()
{
}
}  // namespace strata::device