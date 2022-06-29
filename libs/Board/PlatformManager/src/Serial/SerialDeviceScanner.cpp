/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include <Serial/SerialDeviceScanner.h>
#include "logging/LoggingQtCategories.h"

#include <QSerialPortInfo>

namespace strata::device::scanner {

constexpr std::chrono::milliseconds SERIAL_DEVICE_SCAN_INTERVAL(1000);

SerialDeviceScanner::SerialDeviceScanner()
    : DeviceScanner(Device::Type::SerialDevice) {
    connect(&timer_, &QTimer::timeout, this, &SerialDeviceScanner::checkNewSerialDevices, Qt::QueuedConnection);
}

SerialDeviceScanner::~SerialDeviceScanner() {
    if (timer_.isActive() || (deviceIds_.size() != 0) || (pendingDeviceIds_.size() != 0)) {
        SerialDeviceScanner::deinit();
    }
}

void SerialDeviceScanner::init(quint32 flags) {
    if ((flags & SerialDeviceScanner::DisableAutomaticScan) == 0) {
        startAutomaticScan();
    }
}

void SerialDeviceScanner::deinit() {
    stopAutomaticScan();

    // disconnect signals from devices that are in the process of opening
    for (auto it = pendingDevices_.begin(); it != pendingDevices_.end(); ++it) {
        disconnect(it.value().get(), nullptr, this, nullptr);
    }

    SerialDeviceScanner::disconnectAllDevices();

    deviceIds_.clear();
    portNames_.clear();
    pendingDevices_.clear();
    pendingDeviceIds_.clear();
}

QList<QByteArray> SerialDeviceScanner::discoveredDevices() const {
    return deviceIds_.values();
}

QString SerialDeviceScanner::connectDevice(const QByteArray& deviceId) {
    QHash<QByteArray, QString>::const_iterator it = portNames_.constFind(deviceId);
    if (it == portNames_.constEnd()) {
        return QStringLiteral("No serial port is associated with device ID ") + deviceId;
    }

    DevicePtr device = std::make_shared<SerialDevice>(deviceId, it.value(), 0);

    pendingDeviceIds_.insert(device->deviceId());
    pendingDevices_.insert(device->deviceId(), device);

    connect(device.get(), &Device::opened, this, &SerialDeviceScanner::handleDeviceOpened);
    connect(device.get(), &Device::deviceError, this, &SerialDeviceScanner::handleDeviceError);

    qCDebug(lcDeviceScanner).nospace().noquote()
        << "Connecting serial device: ID: " << deviceId << ", name: '" << it.value() << "'";

    // open serial device, result is processed in 'handleDeviceOpened' and 'handleDeviceError' methods
    device->open();

    return "";
}

QString SerialDeviceScanner::disconnectDevice(const QByteArray& deviceId) {
    // we will keep the device in lists here in scanner
    if (deviceIds_.contains(deviceId) == false) {
        return QStringLiteral("Device not found");
    }

    emit deviceLost(deviceId);
    return "";
}

void SerialDeviceScanner::disconnectAllDevices() {
    // we will keep the devices in lists here in scanner
    for (const auto& deviceId: qAsConst(deviceIds_)) {
        emit deviceLost(deviceId);
    }
}

void SerialDeviceScanner::setProperties(quint32 flags) {
    if (flags & SerialDeviceScanner::DisableAutomaticScan) {
        stopAutomaticScan();
    }
}

void SerialDeviceScanner::unsetProperties(quint32 flags) {
    if (flags & SerialDeviceScanner::DisableAutomaticScan) {
        startAutomaticScan();
    }
}

void SerialDeviceScanner::startAutomaticScan() {
    if (timer_.isActive()) {
        qCDebug(lcDeviceScanner) << "Device scan is already running.";
    } else {
        qCDebug(lcDeviceScanner) << "Starting device scan.";
        timer_.start(SERIAL_DEVICE_SCAN_INTERVAL);
    }
}

void SerialDeviceScanner::stopAutomaticScan() {
    if (timer_.isActive()) {
        qCDebug(lcDeviceScanner) << "Stopping device scan.";
        timer_.stop();
    } else {
        qCDebug(lcDeviceScanner) << "Device scan is already stopped.";
    }
}

void SerialDeviceScanner::checkNewSerialDevices() {
#if defined(Q_OS_MACOS)
    const QString usbKeyword("usb");
    const QString cuKeyword("cu");
#elif defined(Q_OS_LINUX)
    // TODO: this code was not tested on Linux, test it
    const QString usbKeyword("USB");
#elif defined(Q_OS_WIN)
    const QString usbKeyword("COM");
#endif

    const auto serialPortInfos = QSerialPortInfo::availablePorts();
    QSet<QByteArray> detectedDeviceIds;
    QHash<QByteArray, QString> detectedPortNames;

    for (const QSerialPortInfo& serialPortInfo : serialPortInfos) {
        const QString& portName = serialPortInfo.portName();

        if (serialPortInfo.isNull()) {
            continue;
        }
        if (portName.contains(usbKeyword) == false) {
            continue;
        }
#ifdef Q_OS_MACOS
        if (portName.startsWith(cuKeyword) == false) {
            continue;
        }
#endif
        // device ID must be int because of integration with QML
        const QByteArray deviceId = createDeviceId(SerialDevice::createUniqueHash(portName));
        if (detectedDeviceIds.contains(deviceId)) {
            // Error: hash already exists!
            qCCritical(lcDeviceScanner).nospace().noquote()
                << "Cannot add device (hash conflict: " << deviceId << "): '" << portName << "'";
            continue;
        }
        detectedDeviceIds.insert(deviceId);
        detectedPortNames.insert(deviceId, portName);

        // qCDebug(lcDeviceScanner).nospace().noquote() << "Found serial device, ID: " << deviceId << ", name: '" << name << "'";
    }

    detectedDeviceIds.subtract(pendingDeviceIds_);  // remove devices that are in the process of opening

    QSet<QByteArray> removedDeviceIds = deviceIds_ - detectedDeviceIds;
    QSet<QByteArray> addedDeviceIds = detectedDeviceIds - deviceIds_;

    deviceIds_.intersect(detectedDeviceIds);  // remove all device IDs which was added or removed in this scan loop

    portNames_ = std::move(detectedPortNames); // must be called before connectDevice

    for (const auto& deviceId: qAsConst(removedDeviceIds)) {
        emit deviceLost(deviceId);
    }

    for (const auto& deviceId: qAsConst(addedDeviceIds)) {
        connectDevice(deviceId);
    }
}

void SerialDeviceScanner::handleDeviceOpened() {
    Device *device = qobject_cast<Device*>(QObject::sender());
    if (device == nullptr) {
        return;
    }
    deviceOpeningFinished(device->deviceId(), true);
}

void SerialDeviceScanner::handleDeviceError(Device::ErrorCode errCode, QString msg) {
    Q_UNUSED(errCode)
    Q_UNUSED(msg)

    Device *device = qobject_cast<Device*>(QObject::sender());
    if (device == nullptr) {
        return;
    }
    deviceOpeningFinished(device->deviceId(), false);
}

void SerialDeviceScanner::deviceOpeningFinished(const QByteArray& deviceId, bool success) {
    QHash<QByteArray, DevicePtr>::const_iterator it = pendingDevices_.constFind(deviceId);
    if (it == pendingDevices_.constEnd()) {
        return;
    }

    DevicePtr device = it.value();
    pendingDevices_.erase(it);
    pendingDeviceIds_.remove(deviceId);

    disconnect(device.get(), nullptr, this, nullptr);

    if (success) {
        platform::PlatformPtr platform = std::make_shared<platform::Platform>(device);
        // Add device ID into known device IDs.
        deviceIds_.insert(deviceId);

        qCInfo(lcDeviceScanner).nospace().noquote()
            << "Created new serial device: ID: " << deviceId << ", name: '" << device->deviceName() << "'";

        emit deviceDetected(platform);
    } else {
        // If serial port cannot be opened, remove it from list of known ports.
        // There will be another attempt to open it in next round.
        portNames_.remove(deviceId);

        qCInfo(lcDeviceScanner).nospace().noquote()
            << "Port for device: ID: " << deviceId << ", name: '" << device->deviceName()
            << "' cannot be open, it is probably held by another application.";
    }
}

}  // namespace
