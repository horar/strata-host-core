#pragma once

#include <DeviceScanner.h>
#include <Network/NetworkDevice.h>

#include <QHash>
#include <QHostAddress>
#include <QTimer>
#include <QUdpSocket>

namespace strata::device::scanner
{
class NetworkDeviceScanner : public DeviceScanner
{
    Q_OBJECT;
    Q_DISABLE_COPY(NetworkDeviceScanner);

public:
    NetworkDeviceScanner();
    ~NetworkDeviceScanner();
    virtual void init() override;
    virtual void deinit() override;

private slots:
    void processPendingDatagrams();
    void handleDeviceDisconnected();

private:
    bool addNetworkDevice(QHostAddress deviceAddress);

    std::unique_ptr<QUdpSocket> udpSocket_;
    QList<QByteArray> discoveredDevices_;  // make this a list of device ids?
    static constexpr qint16 UDP_LISTEN_PORT{5146};
    static constexpr qint16 SCAN_TIMER{5000};
};
}  // namespace strata::device::scanner