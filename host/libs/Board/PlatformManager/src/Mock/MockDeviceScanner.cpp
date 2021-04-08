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

    for (const auto& deviceId : deviceIds_) {
        emit deviceLost(deviceId);
    }

    deviceIds_.clear();
}

bool MockDeviceScanner::mockDeviceDetected(const QByteArray& deviceId, const QString& name, const bool saveMessages) {
    if (deviceIds_.find(deviceId) != deviceIds_.end()) {
        qCWarning(logCategoryDeviceScanner).nospace().noquote()
            << "Unable to create new mock device: ID: " << deviceId << ", name: '" << name << "', device already exists";
        return false;
    }

    DevicePtr device = std::make_shared<MockDevice>(deviceId, name, saveMessages);

    deviceIds_.insert(deviceId);

    qCInfo(logCategoryDeviceScanner).nospace().noquote()
        << "Created new mock device: ID: " << deviceId << ", name: '" << name << "'";

    emit deviceDetected(device);

    return true;
}

bool MockDeviceScanner::mockDeviceLost(const QByteArray& deviceId) {
    auto iter = deviceIds_.find(deviceId);
    if (iter == deviceIds_.end()) {
        qCWarning(logCategoryDeviceScanner).nospace().noquote()
            << "Unable to erase mock device: ID: " << deviceId << ", device does not exists";
        return false;
    }

    deviceIds_.erase(iter);

    qCInfo(logCategoryDeviceScanner).nospace().noquote()
        << "Erased mock device: ID: " << deviceId;

    emit deviceLost(deviceId);

    return true;
}

}  // namespace

