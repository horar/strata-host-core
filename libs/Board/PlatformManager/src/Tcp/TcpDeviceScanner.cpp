/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
    if (udpSocket_->isOpen() || (discoveredDevices_.isEmpty() == false)) {
        TcpDeviceScanner::deinit();
    }
}

void TcpDeviceScanner::init(quint32 flags)
{
    Q_UNUSED(flags);

    connect(udpSocket_.get(), &QUdpSocket::readyRead, 
            this, &TcpDeviceScanner::processPendingDatagrams);

    discoveryTimer_.setInterval(DISCOVERY_TIMEOUT);
    discoveryTimer_.setSingleShot(true);
    connect(&discoveryTimer_, &QTimer::timeout, this, &TcpDeviceScanner::discoveryFinishedHandler);
}

void TcpDeviceScanner::deinit()
{
    udpSocket_->close();
    disconnect(udpSocket_.get(), nullptr, this, nullptr);
    scanRunning_ = false;

    TcpDeviceScanner::disconnectAllDevices();
}

QList<QByteArray> TcpDeviceScanner::discoveredDevices() const
{
    QList<QByteArray> discoveredDeviceIds;
    for(const auto &tcpDeviceInfo : discoveredDevices_) {
        discoveredDeviceIds.push_back(tcpDeviceInfo.deviceId);
    }
    return discoveredDeviceIds;
}

const QList<TcpDeviceInfo> TcpDeviceScanner::discoveredTcpDevices() const
{
    return discoveredDevices_;
}

QString TcpDeviceScanner::connectDevice(const QByteArray &deviceId)
{
    auto it = std::find_if(discoveredDevices_.begin(), discoveredDevices_.end(),
                           [&deviceId](const TcpDeviceInfo &tcpDeviceInfo) {
                               return tcpDeviceInfo.deviceId == deviceId;
                           });

    if (it == discoveredDevices_.end()) {
        QString errorMessage(QStringLiteral("Device ID not found in discovered devices list"));
        qCCritical(logCategoryDeviceScanner) << errorMessage;
        return errorMessage;
    }

    DevicePtr device = std::make_shared<TcpDevice>(it->deviceId, it->deviceIpAddress, it->port);
    platform::PlatformPtr platform = std::make_shared<platform::Platform>(device);

    createdDevices_.insert(it->deviceId, *it);
    emit deviceDetected(platform);

    return QString();
}

QString TcpDeviceScanner::disconnectDevice(const QByteArray &deviceId)
{
    if (false == createdDevices_.contains(deviceId)) {
        return "Device not found";
    }

    createdDevices_.remove(deviceId);

    emit deviceLost(deviceId);
    return QString();
}

void TcpDeviceScanner::disconnectAllDevices() {
    for (const auto &tcpDeviceInfo : qAsConst(discoveredDevices_)) {
        emit deviceLost(tcpDeviceInfo.deviceId);
    }
    discoveredDevices_.clear();
}

void TcpDeviceScanner::startDiscovery()
{
    if (scanRunning_) {
        qCDebug(logCategoryDeviceScanner) << "Scanning for new devices is already running.";
    } else {
        if (false == udpSocket_->bind(UDP_LISTEN_PORT, QUdpSocket::DefaultForPlatform)) {
            qCCritical(logCategoryDeviceScanner).nospace().noquote()
                << "Failed to bind UDP socket to port " << UDP_LISTEN_PORT << ": "
                << udpSocket_->errorString();
            return;
        }

        discoveredDevices_.clear();

        scanRunning_ = true;
        discoveryTimer_.start();
        qCDebug(logCategoryDeviceScanner) << "TcpDevice discovery started...";
    }
}

void TcpDeviceScanner::stopDiscovery()
{
    if (scanRunning_) {
        udpSocket_->disconnectFromHost();
        scanRunning_ = false;
        emit discoveryFinished();
    } else {
        qCDebug(logCategoryDeviceScanner) << "Scanning for new devices is already stopped.";
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
            auto it = std::find_if(discoveredDevices_.begin(), discoveredDevices_.end(),
                                   [&clientAddress](TcpDeviceInfo &tcpDeviceInfo) {
                                       return tcpDeviceInfo.deviceIpAddress == clientAddress;
                                   });

            if (it != discoveredDevices_.end()) {
                qCDebug(logCategoryDeviceScanner) << "Device already discovered";
                continue;
            }

            discoveredDevices_.push_back(
                {createDeviceId(TcpDevice::createUniqueHash(clientAddress)),
                 clientAddress.toString(), clientAddress, tcpPort});

            qCDebug(logCategoryDeviceScanner).noquote().nospace()
                << "Discovered new platfrom. IP: " << clientAddress.toString()
                << ", TCP port: " << tcpPort;
        }
    }
}

bool TcpDeviceScanner::parseDatagram(const QByteArray &datagram, quint16 &tcpPort)
{
    // Refer to this page for the proposed messaging structure
    // https://confluence.onsemi.com/display/SPYG/Messaging+Structure+-+Proposal

    QJsonParseError jsonParseError;
    const QJsonDocument jsonDocument = QJsonDocument::fromJson(datagram, &jsonParseError);

    if (jsonParseError.error != QJsonParseError::NoError) {
        qCDebug(logCategoryDeviceScanner) << "Invalid UDP Datagram.";
        return false;
    }

    // The returned QJsonValue is QJsonValue::Undefined if the key does not exist.
    const QJsonValue notification = jsonDocument.object().value("notification");
    if (false == notification.isObject()) {
        qCDebug(logCategoryDeviceScanner) << "Invalid UDP Datagram.";
        return false;
    }

    const QJsonValue payload = notification.toObject().value("payload");
    if (false == payload.isObject()) {
        qCDebug(logCategoryDeviceScanner) << "Invalid UDP Datagram.";
        return false;
    }

    const QJsonObject datagramPayload = payload.toObject();
    auto tcpPortIter = datagramPayload.constFind("tcp_port");
    if (tcpPortIter == datagramPayload.constEnd() || false == tcpPortIter->isDouble()) {
        qCDebug(logCategoryDeviceScanner) << "Invalid UDP Datagram.";
        return false;
    }

    const long port = static_cast<long>(tcpPortIter->toDouble());
    if (port < 1 || port > std::numeric_limits<quint16>::max()) {
        qCDebug(logCategoryDeviceScanner) << "Invalid port range.";
        return false;
    }

    tcpPort = static_cast<quint16>(port);
    return true;
}

void TcpDeviceScanner::discoveryFinishedHandler()
{
    qCDebug(logCategoryDeviceScanner) << "TcpDevice discovery Finished";
    stopDiscovery();
}
}  // namespace strata::device::scanner
