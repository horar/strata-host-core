#include "Verificator.h"
#include "logging/LoggingQtCategories.h"
#include <Serial/SerialDeviceScanner.h>
#include <Mock/MockDeviceScanner.h>

namespace strata {

using device::Device;
using device::scanner::DeviceScanner;
using strata::device::scanner::MockDeviceScanner;
using strata::device::scanner::SerialDeviceScanner;

Verificator::Verificator():
    serialDeviceScanner(new SerialDeviceScanner()),
    mockDeviceScanner(new MockDeviceScanner())
{
    qCDebug(logCategoryPlatformVerification) << "Created Serial Device Scanner with type:" << serialDeviceScanner->scannerType();
    qCDebug(logCategoryPlatformVerification) << "Created Mock Device Scanner with type:" << mockDeviceScanner->scannerType();

    connect(serialDeviceScanner.get(), &DeviceScanner::deviceDetected, this, &Verificator::deviceDetectedHandler);
    connect(mockDeviceScanner.get(), &DeviceScanner::deviceDetected, this, &Verificator::deviceDetectedHandler);
    connect(serialDeviceScanner.get(), &DeviceScanner::deviceLost, this, &Verificator::deviceLostHandler);
    connect(mockDeviceScanner.get(), &DeviceScanner::deviceLost, this, &Verificator::deviceLostHandler);
}

Verificator::~Verificator() { }

void Verificator::stop() {
    qCDebug(logCategoryPlatformVerification) << "Deinitializing scanners";
    mockDeviceScanner->deinit();
    serialDeviceScanner->deinit();
}

void Verificator::start() {
    qCDebug(logCategoryPlatformVerification) << "Initializing scanners";
    serialDeviceScanner->init();
    mockDeviceScanner->init();

    addMockDevices();
}

void Verificator::deviceDetectedHandler(device::DevicePtr device) {
    DeviceScanner *deviceScanner = qobject_cast<DeviceScanner*>(QObject::sender());
    if (deviceScanner == nullptr) {
        qCCritical(logCategoryPlatformVerification) << "Received corrupt scanner pointer:" << deviceScanner;
        return;
    }

    if (device == nullptr) {
        qCCritical(logCategoryPlatformVerification) << "Received corrupt device pointer:" << device;
        return;
    }

    qCInfo(logCategoryPlatformVerification).nospace() << "Device detected: ID:" << device->deviceId() << ", Scanner Type: " << deviceScanner->scannerType();

    if (openedDevices_.find(device->deviceId()) == openedDevices_.end()) {
        openedDevices_.insert(device->deviceId(), device);
        qCDebug(logCategoryPlatformVerification) << "Device added to map";

        connect(device.get(), &Device::msgFromDevice, this, &Verificator::messageFromDeviceHandler);
        connect(device.get(), &Device::messageSent, this, &Verificator::messageSentHandler);
        connect(device.get(), &Device::deviceError, this, &Verificator::deviceErrorHandler);
    } else {
        qCWarning(logCategoryPlatformVerification) << "Unable to add device to map, device Id already exists";
    }
}

void Verificator::deviceLostHandler(QByteArray deviceId) {

    DeviceScanner *deviceScanner = qobject_cast<DeviceScanner*>(QObject::sender());
    if (deviceScanner == nullptr) {
        qCCritical(logCategoryPlatformVerification) << "Received corrupt scanner pointer:" << deviceScanner;
        return;
    }

    qCInfo(logCategoryPlatformVerification).nospace() << "Device lost: ID: " << deviceId << ", Scanner Type: " << deviceScanner->scannerType();

    auto iter = openedDevices_.find(deviceId);
    if (iter != openedDevices_.end()) {
        disconnect(iter.value().get(), nullptr, this, nullptr);
        openedDevices_.erase(iter);
        qCDebug(logCategoryPlatformVerification) << "Device erased from map";
    } else {
        qCWarning(logCategoryPlatformVerification) << "Unable to erase device from map, device Id does not exists";
    }
}

void Verificator::messageFromDeviceHandler(QByteArray msg) {
    Device *device = qobject_cast<Device*>(QObject::sender());
    if (device == nullptr) {
        qCCritical(logCategoryPlatformVerification) << "Received corrupt device pointer:" << device;
        return;
    }
    qCInfo(logCategoryPlatformVerification).nospace() << "Device message received: ID: " << device->deviceId() << ", message: " << msg;
}

void Verificator::messageSentHandler(QByteArray msg) {
    Device *device = qobject_cast<Device*>(QObject::sender());
    if (device == nullptr) {
        qCCritical(logCategoryPlatformVerification) << "Received corrupt device pointer:" << device;
        return;
    }
    qCInfo(logCategoryPlatformVerification).nospace() << "Device message sent: ID: " << device->deviceId() << ", message: " << msg;
}

void Verificator::deviceErrorHandler(Device::ErrorCode errCode, QString msg) {
    Device *device = qobject_cast<Device*>(QObject::sender());
    if (device == nullptr) {
        qCCritical(logCategoryPlatformVerification) << "Received corrupt device pointer:" << device;
        return;
    }
    qCInfo(logCategoryPlatformVerification).nospace() << "Device error received: ID: " << device->deviceId() << ", code: " << errCode << ", message: " << msg;
}

void Verificator::addMockDevices() {
    const unsigned count = 10;
    qCDebug(logCategoryPlatformVerification) << "Adding" << count << "mock devices to mockDeviceScanner";

    for (unsigned i = 0; i < count; i++) {
        QString name = "MOCK" + QString::number(i);
        QByteArray deviceId = device::MockDevice::createDeviceId(name);
        static_cast<MockDeviceScanner*>(mockDeviceScanner.get())->mockDeviceDetected(deviceId, name, false);
    }
}

}  // namespace
