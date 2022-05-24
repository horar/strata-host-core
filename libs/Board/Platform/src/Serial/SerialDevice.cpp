/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include <Serial/SerialDevice.h>
#include "SerialPortWorker.h"

#include "logging/LoggingQtCategories.h"

namespace strata::device {

bool SerialDevice::portErrorUnregistered_ = true;

SerialDevice::SerialDevice(const QByteArray& deviceId, const QString& name, int openRetries)
    : Device(deviceId, name, Type::SerialDevice),
      connected_(false)
{
    using serial::SerialPortWorker;

    if (portErrorUnregistered_) {
        qRegisterMetaType<strata::device::serial::PortError>();
        portErrorUnregistered_ = false;
    }

    serialPortWorker_ = new SerialPortWorker(name, openRetries);
    serialPortWorker_->moveToThread(&workerThread_);

    connect(&workerThread_, &QThread::finished, serialPortWorker_, &QObject::deleteLater);

    connect(this, &SerialDevice::openPort, serialPortWorker_, &SerialPortWorker::openPort);
    connect(this, &SerialDevice::closePort, serialPortWorker_, &SerialPortWorker::closePort);
    connect(this, &SerialDevice::writeData, serialPortWorker_, &SerialPortWorker::writeData);
    connect(this, &SerialDevice::clearReadBuffer, serialPortWorker_, &SerialPortWorker::clearReadBuffer);

    connect(serialPortWorker_, &SerialPortWorker::portOpened, this, &SerialDevice::handlePortOpened);
    connect(serialPortWorker_, &SerialPortWorker::portClosed, this, &SerialDevice::handlePortClosed);
    connect(serialPortWorker_, &SerialPortWorker::dataWritten, this, &SerialDevice::handleDataWritten);
    connect(serialPortWorker_, &SerialPortWorker::messageObtained, this, &SerialDevice::handleMessageObtained);
    connect(serialPortWorker_, &SerialPortWorker::portError, this, &SerialDevice::handlePortError);

    workerThread_.start();
}

SerialDevice::~SerialDevice()
{
    disconnect(serialPortWorker_, nullptr, this, nullptr);

    workerThread_.quit();
    workerThread_.wait();

    qCDebug(lcDeviceSerial).nospace().noquote()
        << "Deleted serial device, ID: " <<  deviceId_
        << ", unique ID: 0x" << hex << reinterpret_cast<quintptr>(this);
}

void SerialDevice::open()
{
    emit openPort(QPrivateSignal());
}

void SerialDevice::close()
{
    emit closePort(QPrivateSignal());
}

QByteArray SerialDevice::createUniqueHash(const QString& portName)
{
    return QByteArray(QByteArray::number(qHash(portName), 16));
}

unsigned SerialDevice::sendMessage(const QByteArray& data)
{
    // Data cannot be written to serial port from another thread as
    // in which this SerialDevice object was created. Otherwise error
    // "QSocketNotifier: Socket notifiers cannot be enabled or disabled from another thread" occurs.

    unsigned msgNum = Device::nextMessageNumber();

    emit writeData(data, msgNum, QPrivateSignal());

    return msgNum;
}

bool SerialDevice::isConnected() const
{
    return connected_;
}

void SerialDevice::resetReceiving()
{
    emit clearReadBuffer(QPrivateSignal());
}

void SerialDevice::handlePortOpened(bool opened)
{
    connected_ = opened;
    if (opened) {
        emit Device::opened();
    }
}

void SerialDevice::handlePortClosed()
{
    connected_ = false;
}

void SerialDevice::handleDataWritten(QByteArray data, unsigned messageNumber, QString error)
{
    if (error.isEmpty() == false) {
        qCCritical(lcDeviceSerial) << this << error;
    }
    emit messageSent(data, messageNumber, error);
}

void SerialDevice::handleMessageObtained(QByteArray message)
{
    emit messageReceived(message);
}

void SerialDevice::handlePortError(serial::PortError errorCode, QString errorMessage)
{
    using serial::PortError;

    qCWarning(lcDeviceSerial) << this << errorMessage;

    switch (errorCode) {
    case PortError::FailedToOpen :
        emit deviceError(ErrorCode::DeviceFailedToOpen, errorMessage);
        break;
    case PortError::FailedToOpenGoingToRetry :
        emit deviceError(ErrorCode::DeviceFailedToOpenGoingToRetry, errorMessage);
        break;
    case PortError::Disconnected :
        emit deviceError(ErrorCode::DeviceDisconnected, errorMessage);
        break;
    case PortError::Error :
        emit deviceError(ErrorCode::DeviceError, errorMessage);
        break;
    }
}

}  // namespace
