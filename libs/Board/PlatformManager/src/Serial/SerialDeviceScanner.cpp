/*
 * Copyright (c) 2018-2021 onsemi.
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
    if (timer_.isActive() || (deviceIds_.size() != 0)) {
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

    SerialDeviceScanner::disconnectAllDevices();

    deviceIds_.clear();
    portNames_.clear();
}

QList<QByteArray> SerialDeviceScanner::discoveredDevices() const {
    return deviceIds_.values();
}

QString SerialDeviceScanner::connectDevice(const QByteArray& deviceId) {
    // 1. construct the serial device
    // 2. emit signal

    const QString name = portNames_.value(deviceId);

    SerialDevice::SerialPortPtr serialPort = SerialDevice::establishPort(name);

    if (serialPort == nullptr) {
        qCInfo(lcDeviceScanner).nospace().noquote()
            << "Port for device: ID: " << deviceId << ", name: '" << name
            << "' cannot be open, it is probably held by another application.";
        return "Unable to open Serial Port";
    }

    DevicePtr device = std::make_shared<SerialDevice>(deviceId, name, std::move(serialPort), -1);
    platform::PlatformPtr platform = std::make_shared<platform::Platform>(device);

    qCInfo(lcDeviceScanner).nospace().noquote()
        << "Created new serial device: ID: " << deviceId << ", name: '" << name << "'";

    emit deviceDetected(platform);

    return "";
}

QString SerialDeviceScanner::disconnectDevice(const QByteArray& deviceId) {
    // we will keep the device in lists here in scanner
    if (deviceIds_.contains(deviceId) == false) {
        return "Device not found";
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

    QSet<QByteArray> addedDeviceIds, removedDeviceIds;
    computeListDiff(deviceIds_, detectedDeviceIds, addedDeviceIds, removedDeviceIds);

    portNames_ = std::move(detectedPortNames); // must be called before connectDevice

    for (const auto& deviceId: qAsConst(removedDeviceIds)) {
        emit deviceLost(deviceId);
    }

    for (const auto& deviceId: qAsConst(addedDeviceIds)) {
        if (connectDevice(deviceId).isEmpty() == false) {
            // If serial port cannot be opened (for example it is hold by another application),
            // remove it from list of known ports. There will be another attempt to open it in next round.
            detectedDeviceIds.remove(deviceId);
            auto iter = portNames_.find(deviceId);
            if (iter != portNames_.end())
                portNames_.erase(iter);
        }
    }

    deviceIds_ = std::move(detectedDeviceIds); // must be called after connectDevice
}

void SerialDeviceScanner::computeListDiff(const QSet<QByteArray>& originalList, const QSet<QByteArray>& newList,
                                          QSet<QByteArray>& addedList, QSet<QByteArray>& removedList) const {
    // create differences of the lists.. what is added / removed
    addedList = newList;
    addedList.subtract(originalList);
    removedList = originalList;
    removedList.subtract(newList);
}

}  // namespace

