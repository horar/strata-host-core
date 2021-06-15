#include <Network/NetworkDeviceScanner.h>
#include "logging/LoggingQtCategories.h"

#include <QJsonDocument>
#include <QJsonObject>

namespace strata::device::scanner
{
NetworkDeviceScanner::NetworkDeviceScanner()
    : DeviceScanner(Device::Type::NetworkDevice), udpSocket_(new QUdpSocket(this))
{
}

NetworkDeviceScanner::~NetworkDeviceScanner()
{
    NetworkDeviceScanner::deinit();
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

        if (quint16 tcpPort; true == parseDatagram(buffer, tcpPort)) {
            if (std::find(discoveredDevices_.begin(), discoveredDevices_.end(),
                          NetworkDevice::createDeviceId(clientAddress)) !=
                discoveredDevices_.end()) {
                qCCritical(logCategoryDeviceScanner)
                    << "Network device" << clientAddress.toString() << "already discovered";
                return;
            }

            qCDebug(logCategoryDeviceScanner)
                << "Discovered new platfrom. IP:" << clientAddress.toString()
                << ", TCP port:" << tcpPort;
            addNetworkDevice(clientAddress, tcpPort);
        }
    }
}

bool NetworkDeviceScanner::addNetworkDevice(QHostAddress deviceAddress, quint16 tcpPort)
{
    DevicePtr device = std::make_shared<NetworkDevice>(deviceAddress, tcpPort);
    platform::PlatformPtr platform = std::make_shared<platform::Platform>(device);

    connect(dynamic_cast<device::NetworkDevice *>(device.get()), &NetworkDevice::deviceDisconnected,
            this, &NetworkDeviceScanner::deviceDisconnectedHandler);

    discoveredDevices_.push_back(device->deviceId());
    emit deviceDetected(platform);
    return true;
}

void NetworkDeviceScanner::deviceDisconnectedHandler()
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

bool NetworkDeviceScanner::parseDatagram(const QByteArray &datagram, quint16 &tcpPort)
{
    // {
    //     "notification": {
    //         "value": "broadcast"
    //         "payload": {
    //             "tcp_port": 24125
    //         }
    //     }
    // }

    QJsonParseError jsonParseError;
    QJsonDocument jsonDocument = QJsonDocument::fromJson(datagram, &jsonParseError);

    if (jsonParseError.error != QJsonParseError::NoError) {
        qCDebug(logCategoryDeviceScanner) << "Invalid UDP Datagram.";
        return false;
    }

    QJsonObject jsonObject = jsonDocument.object();

    if (false == jsonObject.contains("notification") ||
        false == jsonObject.value("notification").isObject()) {
        qCDebug(logCategoryDeviceScanner) << "Invalid UDP Datagram.";
        return false;
    }

    if (false == jsonObject["notification"].toObject().contains("payload") ||
        false == jsonObject["notification"].toObject().value("payload").isObject()) {
        qCDebug(logCategoryDeviceScanner) << "Invalid UDP Datagram.";
        return false;
    }

    QJsonObject datagramPayload = jsonObject["notification"].toObject().value("payload").toObject();
    if (false == datagramPayload.contains("tcp_port") ||
        false == datagramPayload["tcp_port"].isDouble()) {
        qCDebug(logCategoryDeviceScanner) << "Invalid UDP Datagram.";
        return false;
    }

    if (datagramPayload["tcp_port"].toDouble() < 1 ||
        datagramPayload["tcp_port"].toDouble() > std::numeric_limits<quint16>::max()) {
        qCDebug(logCategoryDeviceScanner) << "Invalid port range.";
        return false;
    }

    tcpPort = datagramPayload["tcp_port"].toDouble();
    return true;
}
}  // namespace strata::device::scanner