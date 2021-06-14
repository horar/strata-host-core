#pragma once

#include <Device.h>
#include <QHostAddress>
#include <QTcpSocket>

namespace strata::device
{
class NetworkDevice : public Device
{
    Q_OBJECT
    Q_DISABLE_COPY(NetworkDevice)

public:
    typedef std::unique_ptr<QTcpSocket> socketPtr;

    /**
     * NetworkDevice constructor
     * @param deviceAddress IP address of the network device.
     * @param tcpPort TCP port of the network device.
     */
    NetworkDevice(QHostAddress deviceAddress, quint16 tcpPort);

    /**
     * NetworkDevice destructor.
     */
    ~NetworkDevice() override;

    /**
     * Open TCP socket.
     * @return true if port was opened, otherwise false
     */
    virtual bool open() override;

    /**
     * Close TCP socket.
     */
    virtual void close() override;

    /**
     * Send message to network device. Emits deviceError in case of failure.
     * @param data message to be written to device
     * @return true if message can be sent, otherwise false
     */
    virtual bool sendMessage(const QByteArray &message) override;

    /**
     * return the status of the TCP socket to the network device.
     * @return true if device is connected, otherwise false
     */
    virtual bool isConnected() const override;

    /**
     * Creates device ID based on it's IP address.
     * @return QByteArray of the generated device ID.
     */
    static QByteArray createDeviceId(QHostAddress hostAddress);

signals:
    void deviceDisconnected();

private slots:
    void readMessages();
    void handleError(QAbstractSocket::SocketError socketError);
    void deviceDiconnectedHandler();

private:
    socketPtr tcpSocket_;
    QHostAddress deviceAddress_;
    bool isConnected_;
    std::string readBuffer_;
    quint16 tcpPort_;

    static constexpr qint64 TCP_PORT{24125};
    static constexpr qint64 TCP_WRITE_TIMEOUT{500};
    static constexpr qint64 TCP_CONNECT_TIMEOUT{500};
    static constexpr unsigned READ_BUFFER_SIZE{4096};
};
}  // namespace strata::device