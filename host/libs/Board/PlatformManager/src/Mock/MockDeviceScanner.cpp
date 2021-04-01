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

bool MockDeviceScanner::addMockDevice(const QByteArray& deviceId) {
    // 1. construct the mock device
    // 2. emit signal

    QString name("12345");
    DevicePtr device = std::make_shared<MockDevice>(deviceId, name, false);

    qCInfo(logCategoryDeviceScanner).nospace().noquote()
        << "Created new serial device: ID: " << deviceId << ", name: '" << name << "'";

    emit deviceDetected(device);

    return true;
}

}  // namespace

