#include <Network/NetworkDeviceScanner.h>
#include "logging/LoggingQtCategories.h"

namespace strata::device::scanner
{
NetworkDeviceScanner::NetworkDeviceScanner()
    : DeviceScanner(Device::Type::NetworkDevice), udpSocket_(new QUdpSocket(this))
{
}

NetworkDeviceScanner::~NetworkDeviceScanner()
{
    deinit();
}

void NetworkDeviceScanner::init()
{
    if (false == udpSocket_->bind(UDP_LISTEN_PORT, QUdpSocket::DefaultForPlatform)) {
        qCCritical(logCategoryDeviceScanner) << "Failed to bind UDP socket to" << UDP_LISTEN_PORT;
        return;
    }
    connect(udpSocket_.get(), &QUdpSocket::readyRead, this,
            &NetworkDeviceScanner::processPendingDatagrams);
}

void NetworkDeviceScanner::deinit()
{
    for (const auto &deviceId : discoveredDevices_) {
        emit deviceLost(deviceId);
    }
    discoveredDevices_.clear();

    udpSocket_->close();
    disconnect(udpSocket_.get(), nullptr, this, nullptr);
}

void NetworkDeviceScanner::processPendingDatagrams()
{
    QByteArray buffer;
    QHostAddress clientAddress;

    while (true == udpSocket_->hasPendingDatagrams()) {
        buffer.resize(int(udpSocket_->pendingDatagramSize()));
        udpSocket_->readDatagram(buffer.data(), buffer.size(), &clientAddress);

        qCDebug(logCategoryDeviceScanner)
            << "Datagram contents:" << buffer << "host" << clientAddress;
        if (buffer == "strata client") {
            if (std::find(discoveredDevices_.begin(), discoveredDevices_.end(),
                          NetworkDevice::createDeviceId(clientAddress)) !=
                discoveredDevices_.end()) {
                qCCritical(logCategoryDeviceScanner)
                    << "Network device" << clientAddress.toString() << "already discovered";
                return;
            }

            qCDebug(logCategoryDeviceScanner)
                << "Discovered new platfrom. IP:" << clientAddress.toString();
            addNetworkDevice(clientAddress);
        }
    }
}

bool NetworkDeviceScanner::addNetworkDevice(QHostAddress deviceAddress)
{
    DevicePtr device = std::make_shared<NetworkDevice>(deviceAddress);
    platform::PlatformPtr platform = std::make_shared<platform::Platform>(device);

    connect(dynamic_cast<device::NetworkDevice *>(device.get()), &NetworkDevice::deviceDisconnected,
            this, &NetworkDeviceScanner::handleDeviceDisconnected);

    discoveredDevices_.push_back(device->deviceId());
    emit deviceDetected(platform);
    return true;
}

void NetworkDeviceScanner::handleDeviceDisconnected()
{
    qCDebug(logCategoryDeviceScanner) << "device disconnected. removing from the list.";
    Device *device = qobject_cast<Device *>(QObject::sender());
    if (device == nullptr) {
        qCWarning(logCategoryDeviceScanner) << "cannot cast sender to device object";
        return;
    }
    QByteArray deviceId = device->deviceId();

    const auto it =
        std::find(discoveredDevices_.begin(), discoveredDevices_.end(), device->deviceId());
    if (it != discoveredDevices_.end()) {
        discoveredDevices_.erase(it);
    }

    qCDebug(logCategoryDeviceScanner) << "device lost" << deviceId;
    emit deviceLost(deviceId);
}
}  // namespace strata::device::scanner