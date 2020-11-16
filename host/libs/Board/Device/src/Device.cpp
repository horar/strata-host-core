#include <Device/Device.h>

#include "logging/LoggingQtCategories.h"

#include <QMutexLocker>
#include <QReadLocker>
#include <QWriteLocker>

namespace strata::device {

QDebug operator<<(QDebug dbg, const Device* d) {
    return dbg.nospace().noquote() << "Device 0x" << hex << static_cast<uint>(d->deviceId_) << ": " << dec;
}

QDebug operator<<(QDebug dbg, const DevicePtr& d) {
    return dbg << d.get();
}

Device::Device(const int deviceId, const QString& name, const Type type) :
    deviceId_(deviceId), deviceName_(name), deviceType_(type), operationLock_(0),
    bootloaderMode_(false), apiVersion_(ApiVersion::Unknown), controllerType_(ControllerType::Embedded)
{ }

Device::~Device() { }

QString Device::property(DeviceProperties property) {
    QReadLocker rLock(&properiesLock_);
    switch (property) {
        case DeviceProperties::Name :
            return name_;
        case DeviceProperties::BootloaderVer :
            return bootloaderVer_;
        case DeviceProperties::ApplicationVer :
            return applicationVer_;
        case DeviceProperties::PlatformId :
            return platformId_;
        case DeviceProperties::ClassId :
            return classId_;
        case DeviceProperties::ControllerPlatformId :
            return controllerPlatformId_;
        case DeviceProperties::ControllerClassId :
            return controllerClassId_;
        case DeviceProperties::FirmwareClassId :
            return firmwareClassId_;
    }
    return QString();
}

int Device::deviceId() const {
    return deviceId_;
}

const QString Device::deviceName() const {
    return deviceName_;
}

Device::Type Device::deviceType() const {
    return deviceType_;
}

Device::ApiVersion Device::apiVersion() {
    QReadLocker rLock(&properiesLock_);
    return apiVersion_;
}

Device::ControllerType Device::controllerType() {
    QReadLocker rLock(&properiesLock_);
    return controllerType_;
}

void Device::setVersions(const char* bootloaderVer, const char* applicationVer) {
    QWriteLocker wLock(&properiesLock_);
    if (bootloaderVer)  { bootloaderVer_ = bootloaderVer; }
    if (applicationVer) { applicationVer_ = applicationVer; }
}

void Device::setProperties(const char* name, const char* platformId, const char* classId, ControllerType type) {
    QWriteLocker wLock(&properiesLock_);
    if (name)       { name_ = name; }
    if (platformId) { platformId_ = platformId; }
    if (classId)    { classId_ = classId; }
    controllerType_ = type;
}

void Device::setAssistedProperties(const char* platformId, const char* classId, const char* fwClassId) {
    QWriteLocker wLock(&properiesLock_);
    if (platformId) { controllerPlatformId_ = platformId; }
    if (classId)    { controllerClassId_ = classId; }
    if (fwClassId)  { firmwareClassId_ = classId; }
}

bool Device::lockDeviceForOperation(quintptr lockId) {
    QMutexLocker lock(&operationMutex_);
    if (operationLock_ == 0 && lockId != 0) {
        operationLock_ = lockId;
        return true;
    }
    if (operationLock_ == lockId && lockId != 0) {
        return true;
    }
    return false;
}

void Device::unlockDevice(quintptr lockId) {
    QMutexLocker lock(&operationMutex_);
    if (operationLock_ == lockId) {
        operationLock_ = 0;
    }
}

void Device::setBootloaderMode(bool inBootloaderMode) {
    QWriteLocker wLock(&properiesLock_);
    bootloaderMode_ = inBootloaderMode;
}

bool Device::bootloaderMode() {
    QReadLocker rLock(&properiesLock_);
    return bootloaderMode_;
}

void Device::setApiVersion(ApiVersion apiVersion) {
    QWriteLocker wLock(&properiesLock_);
    apiVersion_ = apiVersion;
}

}  // namespace
