#pragma once

#include <DeviceScanner.h>
#include <Network/NetworkDevice.h>

#include <QHostAddress>
#include <QUdpSocket>

namespace strata::device::scanner
{
class NetworkDeviceScanner : public DeviceScanner
{
    Q_OBJECT;
    Q_DISABLE_COPY(NetworkDeviceScanner);

public:
    /**
     * NetworkDeviceScanner constructor
     */
    NetworkDeviceScanner();

    /**
     * NetworkDeviceScanner destructor
     */
    ~NetworkDeviceScanner();

    /**
     * Start scanning for new devices.
     */
    virtual void init() override;

    /**
     * Stop scanning for new devices. Will close all open devices.
     */
    virtual void deinit() override;

private slots:
    void processPendingDatagrams();
    void deviceDisconnectedHandler();

private:
    bool addNetworkDevice(QHostAddress deviceAddress, quint16 tcpPort);
    bool parseDatagram(const QByteArray &datagram, quint16 &tcpPort);

    std::unique_ptr<QUdpSocket> udpSocket_;
    QList<QByteArray> discoveredDevices_;

    static constexpr qint16 UDP_LISTEN_PORT{5146};
};
}  // namespace strata::device::scanner