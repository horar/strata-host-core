/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QHostAddress>
#include <QTcpSocket>

#include <Device.h>

namespace strata::device
{
class TcpDevice : public Device
{
    Q_OBJECT
    Q_DISABLE_COPY(TcpDevice)

public:
    typedef std::unique_ptr<QTcpSocket> socketPtr;

    /**
     * TcpDevice constructor
     * @param deviceAddress IP address of the tcp device.
     * @param tcpPort Open tcp port of the device.
     */
    TcpDevice(const QByteArray& deviceId, QHostAddress deviceAddress, quint16 tcpPort);

    /**
     * TcpDevice destructor.
     */
    ~TcpDevice() override;

    /**
     * Open TCP socket.
     * Emits opened() on success or deviceError() on failure.
     */
    virtual void open() override;

    /**
     * Close TCP socket.
     */
    virtual void close() override;

    /**
     * Send message asynchronously to tcp device. Emits messageSent.
     * @param data message to be written to device
     * @return serial number of the sent message
     */
    virtual unsigned sendMessage(const QByteArray &message) override;

    /**
     * return the status of the tcp device.
     * @return true if device is connected, otherwise false
     */
    virtual bool isConnected() const override;

    /**
     * Reset receiving messages from device (clear internal buffers, etc.).
     */
    virtual void resetReceiving() override;

    /**
     * Creates unique hash for the device, based on it's IP address.
     * Will be used to generate device ID.
     * @param hostAddress address of the connected device.
     * @return unique hash bytes.
     */
    static QByteArray createUniqueHash(QHostAddress hostAddress);

signals:
    void deviceDisconnected();

private slots:
    void readMessages();
    void handleError(QAbstractSocket::SocketError socketError);
    void deviceDiconnectedHandler();
    void deviceOpenedHandler();

private:
    socketPtr tcpSocket_;
    QHostAddress deviceAddress_;
    bool isConnected_;
    std::string readBuffer_;
    quint16 tcpPort_;

    static constexpr qint64 TCP_WRITE_TIMEOUT{500};
    static constexpr qint64 TCP_CONNECT_TIMEOUT{500};
    static constexpr unsigned READ_BUFFER_SIZE{4096};
};
}  // namespace strata::device
