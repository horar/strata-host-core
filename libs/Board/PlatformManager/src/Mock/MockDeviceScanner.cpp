/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include <Mock/MockDeviceScanner.h>
#include "logging/LoggingQtCategories.h"

namespace strata::device::scanner {

MockDeviceScanner::MockDeviceScanner()
    : DeviceScanner(Device::Type::MockDevice) { }

MockDeviceScanner::~MockDeviceScanner() {
    if (running_) {
        MockDeviceScanner::deinit();
    }
}

void MockDeviceScanner::init(quint32 flags) {
    Q_UNUSED(flags)
    running_ = true;
}

void MockDeviceScanner::deinit() {
    running_ = false;

    MockDeviceScanner::disconnectAllDevices();
}

QList<QByteArray> MockDeviceScanner::discoveredDevices() const {
    return devices_.keys();
}

QString MockDeviceScanner::connectDevice(const QByteArray& deviceId) {
    Q_UNUSED(deviceId)

    return "Method not supported";
}

QString MockDeviceScanner::disconnectDevice(const QByteArray& deviceId) {
    if (devices_.remove(deviceId) == 0) {
        qCWarning(lcDeviceScanner).nospace().noquote()
            << "Unable to erase mock device: ID: " << deviceId << ", device does not exists";
        return "Device not found";
    }

    qCInfo(lcDeviceScanner).nospace().noquote()
        << "Erased mock device: ID: " << deviceId;

    emit deviceLost(deviceId, QString());

    return "";
}

void MockDeviceScanner::disconnectAllDevices() {
    for (auto devIdIter = devices_.keyBegin(); devIdIter != devices_.keyEnd(); ++devIdIter) {
        emit deviceLost(*devIdIter, QString());
    }

    devices_.clear();
}

QByteArray MockDeviceScanner::mockCreateDeviceId(const QString& mockName) {
    return createDeviceId(MockDevice::createUniqueHash(mockName));
}

QString MockDeviceScanner::mockDeviceDetected(const QByteArray& deviceId, const QString& name, const bool saveMessages) {
    if (devices_.constFind(deviceId) != devices_.cend()) {
        QString errorString = "Unable to create new mock device: ID: " + deviceId + ", name: '" + name + "', device already exists.";
        qCWarning(lcDeviceScanner).noquote() << errorString;
        return errorString;
    }

    DevicePtr device = std::make_shared<MockDevice>(deviceId, name, saveMessages);
    platform::PlatformPtr platform = std::make_shared<platform::Platform>(device);

    devices_.insert(deviceId, device);

    qCInfo(lcDeviceScanner).nospace().noquote()
        << "Created new mock device: ID: " << deviceId << ", name: '" << name << "'";

    emit deviceDetected(platform);

    return QString();
}

QString MockDeviceScanner::mockDeviceDetected(DevicePtr mockDevice) {
    if ((mockDevice == nullptr) || (mockDevice->deviceType() != Device::Type::MockDevice)) {
        QString errorString = "Invalid mock device provided.";
        if (mockDevice) {
            errorString.append(" Device ID: ");
            errorString.append(mockDevice->deviceId());
        }
        qCWarning(lcDeviceScanner).noquote() << errorString;
        return errorString;
    }

    if (devices_.find(mockDevice->deviceId()) != devices_.end()) {
        QString errorString = "Unable to create new mock device: ID: " + mockDevice->deviceId()
                              + ", name: '" + mockDevice->deviceName() + "', device already exists.";
        qCWarning(lcDeviceScanner).noquote() << errorString;
        return errorString;
    }

    platform::PlatformPtr platform = std::make_shared<platform::Platform>(mockDevice);

    devices_.insert(mockDevice->deviceId(), mockDevice);

    qCInfo(lcDeviceScanner).nospace().noquote()
        << "Created new mock device: ID: " << mockDevice->deviceId()
        << ", name: '" << mockDevice->deviceName() << "'";

    emit deviceDetected(platform);

    return QString();
}

DevicePtr MockDeviceScanner::getMockDevice(const QByteArray& deviceId) const {
    return devices_.value(deviceId, nullptr);
}

}  // namespace
