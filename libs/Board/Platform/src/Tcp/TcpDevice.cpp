/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include <Tcp/TcpDevice.h>

#include "logging/LoggingQtCategories.h"

namespace strata::device
{
TcpDevice::TcpDevice(const QByteArray& deviceId, QHostAddress deviceAddress, quint16 tcpPort)
    : Device(deviceId, deviceAddress.toString(), Type::TcpDevice),
      tcpSocket_(new QTcpSocket(this)),
      deviceAddress_(deviceAddress),
      isConnected_(false),
      tcpPort_(tcpPort)
{
    readBuffer_.reserve(READ_BUFFER_SIZE);
}

TcpDevice::~TcpDevice()
{
    TcpDevice::close();
}

void TcpDevice::open()
{
    qDebug(logCategoryDeviceTcp).nospace()
        << this << "Connecting TCP device:" << deviceId_ << ", IP:" << deviceAddress_.toString()
        << " Port:" << tcpPort_;

    if (tcpSocket_->isOpen()) {
        qCDebug(logCategoryDeviceTcp) << this << "TCP socket already open.";
        return;
    }

    connect(tcpSocket_.get(), &QTcpSocket::connected, this, &TcpDevice::deviceOpenedHandler);
    connect(tcpSocket_.get(), &QTcpSocket::readyRead, this, &TcpDevice::readMessages);
    connect(tcpSocket_.get(), &QTcpSocket::disconnected, this,
            &TcpDevice::deviceDiconnectedHandler);
    connect(tcpSocket_.get(), QOverload<QAbstractSocket::SocketError>::of(&QAbstractSocket::error),
            this, &TcpDevice::handleError);

    tcpSocket_->connectToHost(deviceAddress_, tcpPort_);
}

void TcpDevice::close()
{
    disconnect(tcpSocket_.get(), nullptr, this, nullptr);
    if (true == tcpSocket_->isOpen()) {
        qCDebug(logCategoryDeviceTcp) << this << "Disconnecting from tcp device:" << deviceId_
                                      << ", IP:" << deviceAddress_.toString() << " Port:" << tcpPort_;
        tcpSocket_->close();
    }
}

unsigned TcpDevice::sendMessage(const QByteArray &message)
{
    unsigned msgNum = Device::nextMessageNumber();

    if (tcpSocket_->write(message) != message.size() || false == tcpSocket_->flush()) {
        QString errMsg(QStringLiteral("Cannot write whole data to device."));
        qCCritical(logCategoryDeviceTcp) << this << errMsg;
        emit messageSent(message, msgNum, errMsg);
    } else {
        emit messageSent(message, msgNum, QString());
    }

    return msgNum;
}

bool TcpDevice::isConnected() const
{
    return tcpSocket_->state() == QTcpSocket::ConnectedState;
}

void TcpDevice::resetReceiving()
{
    if (readBuffer_.empty() == false) {
        readBuffer_.clear();
        qCDebug(logCategoryDeviceSerial)
            << this << "Cleared internal buffer for reading of received messages.";
    }
}

void TcpDevice::readMessages()
{
    // QTcpSocket::readyRead signal is emitted when there is data ready to read and not when a
    // complete message is received. As a result we need a buffer to hold the data until the
    // transmission is complete. Based on the protocol of messaging between host and platform, a
    // newline character is used as the end of message indicator.

    const QByteArray data = tcpSocket_->readAll();
    int begin = 0;
    int end;
    while ((end = data.indexOf('\n', begin)) > -1) {
        ++end;
        readBuffer_.append(data.data() + begin, static_cast<size_t>(end - begin));
        begin = end;
        emit messageReceived(QByteArray::fromStdString(readBuffer_));
        readBuffer_.clear();
    }

    if (begin < data.size()) {  // message contains some data after '\n' (or has no '\n')
        readBuffer_.append(data.data() + begin, static_cast<size_t>(data.size() - begin));
    }
}

void TcpDevice::handleError(QAbstractSocket::SocketError socketError)
{
    Q_UNUSED(socketError);
    emit deviceError(ErrorCode::DeviceError, tcpSocket_->errorString());
}

void TcpDevice::deviceDiconnectedHandler()
{
    qCDebug(logCategoryDeviceTcp) << "Disconnected from tcp device address"
                                  << deviceAddress_.toString();
    emit deviceError(ErrorCode::DeviceDisconnected, "");
}

void TcpDevice::deviceOpenedHandler()
{
    qCDebug(logCategoryDeviceTcp) << "Connected to tcp device address" << deviceAddress_.toString();
    emit Device::opened();
}

QByteArray TcpDevice::createUniqueHash(QHostAddress hostAddress)
{
    return QByteArray(QByteArray::number(qHash(hostAddress.toString()), 16));
}
}  // namespace strata::device
