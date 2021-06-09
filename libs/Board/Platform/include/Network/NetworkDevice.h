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
    NetworkDevice(QHostAddress deviceAddress, const QByteArray &deviceId, const QString &name);
    ~NetworkDevice() override;

    virtual bool open() override;
    virtual void close() override;
    virtual bool sendMessage(const QByteArray &message) override;
    virtual bool isConnected() const override;

signals:
    void deviceDisconnected();

private slots:
    void readMessages();
    void handleError(QAbstractSocket::SocketError socketError);
    void handleDeviceDiconnected();

private:
    socketPtr tcpSocket_;
    QHostAddress deviceAddress_;
    bool isConnected_;
    std::string readBuffer_;

    static constexpr qint64 TCP_PORT{24125};
    static constexpr qint64 TCP_WRITE_TIMEOUT{1000};
    static constexpr qint64 TCP_CONNECT_TIMEOUT{500};
    static constexpr unsigned READ_BUFFER_SIZE{4096};
};
}  // namespace strata::device