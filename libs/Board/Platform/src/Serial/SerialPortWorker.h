/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <string>
#include <memory>

#include <QObject>
#include <QString>
#include <QByteArray>
#include <QSerialPort>
#include <QTimer>

namespace strata::device::serial {

Q_NAMESPACE

/**
 * PortError enum used in 'portError(...)' signal
 */
enum class PortError : short {
    FailedToOpen,
    FailedToOpenGoingToRetry,
    Disconnected,
    Error,
};
Q_ENUM_NS(PortError)

class SerialPortWorker : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SerialPortWorker)

public:
    /**
     * SerialPortWorker constructor
     * @param portName serial port name
     * @param openRetries count of retries if opening port fails; default = 0, unlimited = -1 (negative number)
     */
    SerialPortWorker(const QString& portName, int openRetries);

    /**
     * SerialPortWorker destructor
     */
    ~SerialPortWorker();

public slots:
    /**
     * Open serial port.
     * Emits 'portOpened(...)' and also 'portError(...)' in case if some error occures.
     */
    void openPort();

    /**
     * Close serial port.
     * Emits 'portClosed()'.
     */
    void closePort();

    /**
     * Writes data to serial port.
     * Emits 'dataWritten(...)'.
     * @param data data for writting to port
     * @param messageNumber number of message written to port
     */
    void writeData(QByteArray data, unsigned messageNumber);

    /**
     * Clears internal buffer for reading from serial port (drops any data (parts of message) from it).
     */
    void clearReadBuffer();

signals:
    /**
     * Emitted when serial port opening finish.
     * @param success true if serial port was opened successfully, false otherwise
     */
    void portOpened(bool success);

    /**
     * Emitted when serial port closing finish.
     */
    void portClosed();

    /**
     * Emitted when data was written to serial port or some problem occured and data cannot be written.
     * @param data writen data to serial port
     * @param messageNumber serial number of the sent message
     * @param error error string if data cannot be written, empty (null) when everything is OK
     */
    void dataWritten(QByteArray data, unsigned messageNumber, QString error);

    /**
     * Emitted when whole Strata message was read from serial port.
     * @param message Strata message read from serial port
     */
    void messageObtained(QByteArray message);

    /**
     * Emitted when some error occures on serial port.
     * @param errorCode error code from 'PortError' enum
     * @param errorMessage error description
     */
    void portError(strata::device::serial::PortError errorCode, QString errorMessage);

private slots:
    void readData();
    void handleError(QSerialPort::SerialPortError error);

private:
    void init();
    std::unique_ptr<QSerialPort> serialPort_;
    std::string readBuffer_;  // std::string keeps allocated memory after clear(), this is why read_buffer_ is std::string

    bool initialized_;

    const QString portName_;
    QTimer openRetryTimer_;
    const int openRetries_;
    int remainingRetries_;
};

}  // namespace
