/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#ifndef SERIAL_DEVICE_H
#define SERIAL_DEVICE_H

#include <Device.h>

#include <QThread>

namespace strata::device {

namespace serial {
enum class PortError : short;
class SerialPortWorker;
}

class SerialDevice : public Device
{
    Q_OBJECT
    Q_DISABLE_COPY(SerialDevice)

public:
    /**
     * SerialDevice constructor
     * @param deviceId device ID
     * @param name device name
     * @param openRetries count of retries if 'open()' fails; default = 0, unlimited = -1 (negative number)
     */
    SerialDevice(const QByteArray& deviceId, const QString& name, int openRetries = 0);

    /**
     * SerialDevice destructor
     */
    ~SerialDevice() override;

    /**
     * Open serial port.
     * Emits opened() on success or deviceError(DeviceFailedToOpen, ...) on failure.
     */
    virtual void open() override;

    /**
     * Close serial port.
     */
    virtual void close() override;

    /**
     * Creates unique hash for serial device, based on port name.
     * Will be used to generate device ID.
     * @param portName system name of serial port.
     * @return unique hash.
     */
    static QByteArray createUniqueHash(const QString& portName);

    /**
     * Send message to serial device. Emits messageSent.
     * @param data message to be written to device
     * @return serial number of the sent message
     */
    virtual unsigned sendMessage(const QByteArray& data) override;

    /**
     * Check if serial device is connected (communication with it is possible - device
     * is plugged to computer and serial port is open).
     * @return true if device is connected, otherwise false
     */
    virtual bool isConnected() const override;

    /**
     * Reset receiving messages from device - clear internal buffer
     * for receiving from serial port (drop any data (parts of message) from it).
     */
    virtual void resetReceiving() override;

signals:
    void openPort(QPrivateSignal);
    void closePort(QPrivateSignal);
    void writeData(QByteArray data, unsigned messageNumber, QPrivateSignal);
    void clearReadBuffer(QPrivateSignal);

private slots:
    void handlePortOpened(bool opened);
    void handlePortClosed();
    void handleDataWritten(QByteArray data, unsigned messageNumber, QString error);
    void handleMessageObtained(QByteArray message);
    void handlePortError(strata::device::serial::PortError errorCode, QString errorMessage);

private:
    QThread workerThread_;
    serial::SerialPortWorker *serialPortWorker_;

    bool connected_;
    static bool portErrorUnregistered_;
};

}  // namespace

#endif
