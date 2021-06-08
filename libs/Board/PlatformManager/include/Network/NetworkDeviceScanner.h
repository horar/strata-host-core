#pragma once

#include <DeviceScanner.h>
#include <Network/NetworkDevice.h>

#include <QUdpSocket>

// we need to set up udp socket etc...

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

private:
    bool addNetworkDevice(QHostAddress deviceAddress);

    std::unique_ptr<QUdpSocket> udpSocket_;
    static constexpr qint16 UDP_LISTEN_PORT{5146};
};
}  // namespace strata::device::scanner