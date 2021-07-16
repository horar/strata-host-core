#include <Tcp/TcpDeviceScanner.h>
#include "logging/LoggingQtCategories.h"

#include <QJsonDocument>
#include <QJsonObject>

namespace strata::device::scanner
{
TcpDeviceScanner::TcpDeviceScanner()
    : DeviceScanner(Device::Type::TcpDevice),
      udpSocket_(new QUdpSocket(this)),
      scanRunning_(false)
{
}

TcpDeviceScanner::~TcpDeviceScanner()
{
    if (udpSocket_->isOpen() || (discoveredDevices_.size() != 0)) {
        TcpDeviceScanner::deinit();
    }
}

void TcpDeviceScanner::init(quint32 flags)
{
    if (false == udpSocket_->bind(UDP_LISTEN_PORT, QUdpSocket::DefaultForPlatform)) {
        qCCritical(logCategoryDeviceScanner) << "Failed to bind UDP socket to" << UDP_LISTEN_PORT;
        return;
    }
    if ((flags & TcpDeviceScanner::DisableAutomaticScan) == 0) {
        startAutomaticScan();
    }
}

void TcpDeviceScanner::deinit()
{
    udpSocket_->close();
    disconnect(udpSocket_.get(), nullptr, this, nullptr);
    scanRunning_ = false;

    for (const auto &deviceId : discoveredDevices_) {
        emit deviceLost(deviceId);
    }
    discoveredDevices_.clear();
}

void TcpDeviceScanner::setProperties(quint32 flags) {
    if (flags & TcpDeviceScanner::DisableAutomaticScan) {
        stopAutomaticScan();
    }
}

void TcpDeviceScanner::unsetProperties(quint32 flags) {
    if (flags & TcpDeviceScanner::DisableAutomaticScan) {
        startAutomaticScan();
    }
}

void TcpDeviceScanner::startAutomaticScan()
{
    if (scanRunning_) {
        qCWarning(logCategoryDeviceScanner) << "Scanning for new devices is already running.";
    } else {
        connect(udpSocket_.get(), &QUdpSocket::readyRead, this,
                &TcpDeviceScanner::processPendingDatagrams);
        scanRunning_ = true;
    }
}

void TcpDeviceScanner::stopAutomaticScan()
{
    if (scanRunning_) {
        disconnect(udpSocket_.get(), nullptr, this, nullptr);
        scanRunning_ = false;
    } else {
        qCWarning(logCategoryDeviceScanner) << "Scanning for new devices is already stopped.";
    }
}

void TcpDeviceScanner::processPendingDatagrams()
{
    QByteArray buffer;
    QHostAddress clientAddress;

    while (true == udpSocket_->hasPendingDatagrams()) {
        buffer.resize(int(udpSocket_->pendingDatagramSize()));
        udpSocket_->readDatagram(buffer.data(), buffer.size(), &clientAddress);

        if (quint16 tcpPort; true == parseDatagram(buffer, tcpPort)) {
            if (std::find(discoveredDevices_.begin(), discoveredDevices_.end(),
                          createDeviceId(TcpDevice::createUniqueHash(clientAddress))) != discoveredDevices_.end()) {
                qCCritical(logCategoryDeviceScanner)
                    << "Tcp device" << clientAddress.toString() << "already discovered";
                return;
            }

            qCDebug(logCategoryDeviceScanner)
                << "Discovered new platfrom. IP:" << clientAddress.toString()
                << ", TCP port:" << tcpPort;
            addTcpDevice(clientAddress, tcpPort);
        }
    }
}

void TcpDeviceScanner::addTcpDevice(QHostAddress deviceAddress, quint16 tcpPort)
{
    DevicePtr device = std::make_shared<TcpDevice>(createDeviceId(TcpDevice::createUniqueHash(deviceAddress)), deviceAddress, tcpPort);
    platform::PlatformPtr platform = std::make_shared<platform::Platform>(device);

    connect(dynamic_cast<device::TcpDevice *>(device.get()), &TcpDevice::deviceDisconnected, this,
            &TcpDeviceScanner::deviceDisconnectedHandler);

    discoveredDevices_.push_back(device->deviceId());
    emit deviceDetected(platform);
}

void TcpDeviceScanner::deviceDisconnectedHandler()
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

bool TcpDeviceScanner::parseDatagram(const QByteArray &datagram, quint16 &tcpPort)
{
    // Refer to this page for the proposed messaging structure
    // https://confluence.onsemi.com/display/SPYG/Messaging+Structure+-+Proposal

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

    long port = datagramPayload["tcp_port"].toDouble();
    if (port < 1 || port > std::numeric_limits<quint16>::max()) {
        qCDebug(logCategoryDeviceScanner) << "Invalid port range.";
        return false;
    }

    tcpPort = port;
    return true;
}
}  // namespace strata::device::scanner
