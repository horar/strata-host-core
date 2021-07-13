#pragma once

#include <DeviceScanner.h>
#include <Tcp/TcpDevice.h>

#include <QHostAddress>
#include <QUdpSocket>

namespace strata::device::scanner
{
class TcpDeviceScanner : public DeviceScanner
{
    Q_OBJECT;
    Q_DISABLE_COPY(TcpDeviceScanner);

public:
    /**
     * TcpDeviceScanner constructor
     */
    TcpDeviceScanner();

    /**
     * TcpDeviceScanner destructor
     */
    ~TcpDeviceScanner();

    /**
     * Initialize scanner.
     */
    virtual void init() override;

    /**
     * Deinitialize scanner and stop scanning for new devices. Will close all open devices.
     */
    virtual void deinit() override;

    /**
     * Start an automatic scan of new devices.
     */
    virtual void startAutomaticScan();

    /**
     * Stop an automatic scan of new devices.
     */
    virtual void stopAutomaticScan();

private slots:
    void processPendingDatagrams();
    void deviceDisconnectedHandler();

private:
    void addTcpDevice(QHostAddress deviceAddress, quint16 tcpPort);
    bool parseDatagram(const QByteArray &datagram, quint16 &tcpPort);

    std::unique_ptr<QUdpSocket> udpSocket_;
    QList<QByteArray> discoveredDevices_;

    bool scanRunning_;

    static constexpr qint16 UDP_LISTEN_PORT{5146};
};
}  // namespace strata::device::scanner
