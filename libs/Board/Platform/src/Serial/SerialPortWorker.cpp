/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "SerialPortWorker.h"
#include "SerialDeviceConstants.h"

#include "logging/LoggingQtCategories.h"

namespace strata::device::serial {

SerialPortWorker::SerialPortWorker(const QString& portName, int openRetries)
    : serialPort_(nullptr),
      initialized_(false),
      portName_(portName),
      openRetries_(openRetries),
      remainingRetries_(openRetries_)
{
    openRetryTimer_.setSingleShot(true);
    openRetryTimer_.setInterval(SERIAL_DEVICE_OPEN_RETRY_INTERVAL);
    connect(&openRetryTimer_, &QTimer::timeout, this, &SerialPortWorker::openPort);
}

SerialPortWorker::~SerialPortWorker()
{
    if (openRetryTimer_.isActive()) {
        openRetryTimer_.stop();
    }
    serialPort_.reset();
}

void SerialPortWorker::init()
{
    readBuffer_.reserve(READ_BUFFER_SIZE);

    serialPort_ = std::make_unique<QSerialPort>(portName_);

    serialPort_->setBaudRate(QSerialPort::Baud115200);
    serialPort_->setDataBits(QSerialPort::Data8);
    serialPort_->setParity(QSerialPort::NoParity);
    serialPort_->setStopBits(QSerialPort::OneStop);
    serialPort_->setFlowControl(QSerialPort::NoFlowControl);

    connect(serialPort_.get(), &QSerialPort::errorOccurred, this, &SerialPortWorker::handleError);
    connect(serialPort_.get(), &QSerialPort::readyRead, this, &SerialPortWorker::readData);
}

void SerialPortWorker::openPort()
{
    if (initialized_ == false) {
        init();
        initialized_ = true;
    }

    bool serialPortOpened = false;

    if (serialPort_->isOpen()) {
        if ((serialPort_->openMode() & QIODevice::ReadWrite) == QIODevice::ReadWrite) {
            serialPortOpened = true;
        } else {
            serialPort_->close();
        }
    }

    if (serialPortOpened == false) {
        qCDebug(lcDeviceSerial).noquote().nospace() << "Opening serial port '" << portName_ << "'.";
        if (serialPort_->open(QIODevice::ReadWrite)) {
            // clear() should be called right after open()
            serialPort_->clear(QSerialPort::AllDirections);
            clearReadBuffer();
            serialPortOpened = true;
            qCDebug(lcDeviceSerial).noquote().nospace() << "Serial port '" << portName_ << "' opened.";
            remainingRetries_ = openRetries_;  // set retries count for next attempt to open serial port
        }
        // if 'open' fails 'QSerialPort::errorOccurred' signal is emitted
    }
    // There is no need to emit 'portError(PortError::FailedToOpen)' when 'serialPortOpened'
    // is 'false' because this error signal is already emmited from 'handleError()' method.

    emit portOpened(serialPortOpened);
}

void SerialPortWorker::closePort()
{
    if (openRetryTimer_.isActive()) {
        openRetryTimer_.stop();
    }
    if (serialPort_->isOpen()) {
        serialPort_->close();
    }
    emit portClosed();
}

void SerialPortWorker::writeData(QByteArray data, unsigned messageNumber)
{
    if (serialPort_->write(data) == data.size()) {
        emit dataWritten(data, messageNumber, QString());
    } else {
        emit dataWritten(data, messageNumber, QStringLiteral("Cannot write whole data to device."));
    }
}

void SerialPortWorker::clearReadBuffer()
{
    if (readBuffer_.empty() == false) {
        readBuffer_.clear();
        qCDebug(lcDeviceSerial).nospace().noquote() << "Serial port '" << portName_
            << "': cleared internal buffer for reading of received messages.";
    }
}

void SerialPortWorker::readData()
{
    const QByteArray data = serialPort_->readAll();

    // messages from Strata boards ends with new line character
    int from = 0;
    int end;
    while ((end = data.indexOf('\n', from)) > -1) {
        ++end;
        readBuffer_.append(data.data() + from, static_cast<size_t>(end - from));
        from = end;

        // qCDebug(lcDeviceSerial).noquote().nospace() << "Received message ('" << portName_ << "'): '" << QString::fromStdString(readBuffer_) << '\'';
        emit messageObtained(QByteArray::fromStdString(readBuffer_));
        readBuffer_.clear();
        // std::string keeps allocated memory after clear(), this is why read_buffer_ is std::string
    }

    if (from < data.size()) {  // message contains some data after '\n' (or has no '\n')
        readBuffer_.append(data.data() + from, static_cast<size_t>(data.size() - from));
    }
}

void SerialPortWorker::handleError(QSerialPort::SerialPortError error)
{
    // https://doc.qt.io/qt-5/qserialport.html#SerialPortError-enum
    if (error == QSerialPort::NoError) {
        return;  // Do not emit error signal if there is no error.
    }

    const QString errMsg = "Serial port '" + portName_ + "' error (" + QString::number(error) + "): " + serialPort_->errorString() + '.';
    switch (error) {
    case QSerialPort::PermissionError :
        // QSerialPort::open() has failed.
        qCInfo(lcDeviceSerial).noquote().nospace() << errMsg << " Unable to open serial port.";
        if (remainingRetries_ == 0) {
            emit portError(PortError::FailedToOpen, serialPort_->errorString());
            remainingRetries_ = openRetries_;  // set retries count for next attempt to open port
        } else {
            if (remainingRetries_ > 0) {  // negative number (-1) = unlimited count of retries
                --remainingRetries_;
            }
            qCInfo(lcDeviceSerial).noquote().nospace() << "Another attempt to open the serial port '"
                << portName_ << "' will be in " << SERIAL_DEVICE_OPEN_RETRY_INTERVAL.count() << " ms.";
            openRetryTimer_.start();
            emit portError(PortError::FailedToOpenGoingToRetry, serialPort_->errorString());
        }
        break;
    case QSerialPort::ResourceError :
        // An I/O error occurred when a resource becomes unavailable, e.g. when the device is unexpectedly removed from the system.
        qCInfo(lcDeviceSerial).noquote().nospace() << errMsg << " (Probably unexpectedly disconnected device.)";
        emit portError(PortError::Disconnected, serialPort_->errorString());
        break;
    default :
        qCWarning(lcDeviceSerial).noquote().nospace() << errMsg;
        emit portError(PortError::Error, serialPort_->errorString());
        break;
    }
}

}  // namespace
