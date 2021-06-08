#include <Network/NetworkDeviceScanner.h>
#include "logging/LoggingQtCategories.h"

#include <QHostAddress>

namespace strata::device::scanner
{
NetworkDeviceScanner::NetworkDeviceScanner()
    : DeviceScanner(Device::Type::NetworkDevice), udpSocket_(new QUdpSocket(this))
{
}

NetworkDeviceScanner::~NetworkDeviceScanner()
{
    udpSocket_->close();
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
    udpSocket_->close();
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
            qCDebug(logCategoryDeviceScanner)
                << "Discovered new platfrom. IP:" << clientAddress.toString();
            // emit newNetworkPlatformDiscovered(clientAddress);
            addNetworkDevice(clientAddress);
        }
    }
}

bool NetworkDeviceScanner::addNetworkDevice(QHostAddress deviceAddress)
{
    // TODO: create a list of online devices.

    DevicePtr device = std::make_shared<NetworkDevice>(
        deviceAddress, deviceAddress.toString().toUtf8(), deviceAddress.toString());
    platform::PlatformPtr platform = std::make_shared<platform::Platform>(device);
    emit deviceDetected(platform);
    return true;
}

}  // namespace strata::device::scanner