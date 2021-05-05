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

void MockDeviceScanner::init() {
    running_ = true;
}

void MockDeviceScanner::deinit() {
    running_ = false;

    mockAllDevicesLost();
}

bool MockDeviceScanner::mockDeviceDetected(const QByteArray& deviceId, const QString& name, const bool saveMessages) {
    if (deviceIds_.find(deviceId) != deviceIds_.end()) {
        qCWarning(logCategoryDeviceScanner).nospace().noquote()
            << "Unable to create new mock device: ID: " << deviceId << ", name: '" << name << "', device already exists";
        return false;
    }

    DevicePtr device = std::make_shared<MockDevice>(deviceId, name, saveMessages);
    platform::PlatformPtr platform = std::make_shared<platform::Platform>(device);

    deviceIds_.insert(deviceId);

    qCInfo(logCategoryDeviceScanner).nospace().noquote()
        << "Created new mock device: ID: " << deviceId << ", name: '" << name << "'";

    emit deviceDetected(platform);

    return true;
}

bool MockDeviceScanner::mockDeviceDetected(DevicePtr mockDevice) {
    if ((mockDevice == nullptr) || (mockDevice->deviceType() != Device::Type::MockDevice)) {
        qCWarning(logCategoryDeviceScanner) << "Invalid mock device provided:" << mockDevice;
        return false;
    }

    if (deviceIds_.find(mockDevice->deviceId()) != deviceIds_.end()) {
        qCWarning(logCategoryDeviceScanner).nospace().noquote()
            << "Unable to create new mock device: ID: " << mockDevice->deviceId()
            << ", name: '" << mockDevice->deviceName() << "', device already exists";
        return false;
    }

    platform::PlatformPtr platform = std::make_shared<platform::Platform>(mockDevice);

    deviceIds_.insert(mockDevice->deviceId());

    qCInfo(logCategoryDeviceScanner).nospace().noquote()
        << "Created new mock device: ID: " << mockDevice->deviceId()
        << ", name: '" << mockDevice->deviceName() << "'";

    emit deviceDetected(platform);

    return true;
}

bool MockDeviceScanner::mockDeviceLost(const QByteArray& deviceId) {
    if (deviceIds_.erase(deviceId) == 0) {
        qCWarning(logCategoryDeviceScanner).nospace().noquote()
            << "Unable to erase mock device: ID: " << deviceId << ", device does not exists";
        return false;
    }

    qCInfo(logCategoryDeviceScanner).nospace().noquote()
        << "Erased mock device: ID: " << deviceId;

    emit deviceLost(deviceId);

    return true;
}

void MockDeviceScanner::mockAllDevicesLost() {
    for (const auto& deviceId : deviceIds_) {
        emit deviceLost(deviceId);
    }

    deviceIds_.clear();
}

}  // namespace

