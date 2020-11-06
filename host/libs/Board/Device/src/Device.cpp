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
    bootloaderMode_(false), apiVersion_(ApiVersion::Unknown)
{ }

Device::~Device() { }

QString Device::property(DeviceProperties property) {
    QReadLocker rLock(&properiesLock_);
    switch (property) {
        case DeviceProperties::deviceName:
            return deviceName_;
        case DeviceProperties::verboseName :
            return verboseName_;
        case DeviceProperties::platformId :
            return platformId_;
        case DeviceProperties::classId :
            return classId_;
        case DeviceProperties::bootloaderVer :
            return bootloaderVer_;
        case DeviceProperties::applicationVer :
            return applicationVer_;
    }
    return QString();
}

int Device::deviceId() const {
    return deviceId_;
}

Device::Type Device::deviceType() const {
    return deviceType_;
}

Device::ApiVersion Device::apiVersion() {
    QReadLocker rLock(&properiesLock_);
    return apiVersion_;
}

void Device::setProperties(const char* verboseName, const char* platformId, const char* classId, const char* btldrVer, const char* applVer) {
    QWriteLocker wLock(&properiesLock_);
    if (verboseName) { verboseName_ = verboseName; }
    if (platformId)  { platformId_ = platformId; }
    if (classId)     { classId_ = classId; }
    if (btldrVer)    { bootloaderVer_ = btldrVer; }
    if (applVer)     { applicationVer_ = applVer; }
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
