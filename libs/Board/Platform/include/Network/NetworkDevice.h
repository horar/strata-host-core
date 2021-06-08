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

private slots:
    void readMessages();
    void handleError(QAbstractSocket::SocketError socketError);
    void handleWriteToDevice(QByteArray data);
    void handleDeviceConnected();
    void handleDeviceDiconnected();

private:
    socketPtr tcpSocket_;
    QHostAddress deviceAddress_;
    bool isConnected_;
    static constexpr qint64 TCP_PORT{24125};
    static constexpr qint64 TCP_WRITE_TIMEOUT{1000};
};
}  // namespace strata::device