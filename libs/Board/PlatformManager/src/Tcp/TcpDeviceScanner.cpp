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
    if (false == udpSocket_->bind(UDP_LISTEN_PORT, QUdpSocket::DefaultForPlatform)) {
        qCCritical(logCategoryDeviceScanner).nospace().noquote()
            << "Failed to bind UDP socket to port " << UDP_LISTEN_PORT << ": "
            << udpSocket_->errorString();
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

    for (const auto &deviceId : qAsConst(discoveredDevices_)) {
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
        qCDebug(logCategoryDeviceScanner) << "Scanning for new devices is already running.";
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
            if (discoveredDevices_.contains(createDeviceId(TcpDevice::createUniqueHash(clientAddress)))) {
                qCCritical(logCategoryDeviceScanner).noquote()
                    << "Tcp device" << clientAddress.toString() << "already discovered";
                return;
            }

            qCDebug(logCategoryDeviceScanner).noquote().nospace()
                << "Discovered new platfrom. IP: " << clientAddress.toString()
                << ", TCP port: " << tcpPort;
            addTcpDevice(clientAddress, tcpPort);
        }
    }
}

void TcpDeviceScanner::addTcpDevice(QHostAddress deviceAddress, quint16 tcpPort)
{
    DevicePtr device = std::make_shared<TcpDevice>(createDeviceId(TcpDevice::createUniqueHash(deviceAddress)), deviceAddress, tcpPort);
    platform::PlatformPtr platform = std::make_shared<platform::Platform>(device);

    connect(platform.get(), &platform::Platform::deviceError, this, &TcpDeviceScanner::deviceErrorHandler);

    discoveredDevices_.insert(platform->deviceId());
    emit deviceDetected(platform);
}

void TcpDeviceScanner::deviceErrorHandler(Device::ErrorCode error, QString errorString)
{
    Q_UNUSED(errorString)

    platform::Platform *platform = qobject_cast<platform::Platform*>(QObject::sender());
    if (platform == nullptr) {
        qCWarning(logCategoryDeviceScanner) << "Cannot cast sender to platform object";
        return;
    }

    if (error == Device::ErrorCode::DeviceDisconnected ||
        error == Device::ErrorCode::DeviceError) {
        // loss is reported after error is processed in Platform
        QByteArray deviceId = platform->deviceId();
        auto it = discoveredDevices_.find(deviceId);
        if (it != discoveredDevices_.end()) {
            discoveredDevices_.erase(it);
        }

        QTimer::singleShot(0, this, [this, deviceId](){
            qCDebug(logCategoryDeviceScanner).noquote() << "Device loss is about to be reported for" << deviceId;
            emit deviceLost(deviceId);
        });
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
}  // namespace strata::device::scanner
