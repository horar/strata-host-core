#include <Device/Device.h>

#include "logging/LoggingQtCategories.h"

#include <QMutexLocker>
#include <QReadLocker>
#include <QWriteLocker>

namespace strata::device {

QDebug operator<<(QDebug dbg, const Device* d) {
    return dbg.nospace().noquote() << "Device " << d->deviceId_ << ": ";
}

QDebug operator<<(QDebug dbg, const DevicePtr& d) {
    return dbg << d.get();
}

Device::Device(const QByteArray& deviceId, const QString& name, const Type type) :
    deviceId_(deviceId), deviceName_(name), deviceType_(type), operationLock_(0),
    bootloaderMode_(false), apiVersion_(ApiVersion::Unknown), controllerType_(ControllerType::Embedded)
{ }

Device::~Device() { }

QString Device::name() {
    QReadLocker rLock(&properiesLock_);
    return name_;
}

QString Device::bootloaderVer() {
    QReadLocker rLock(&properiesLock_);
    return bootloaderVer_;
}

QString Device::applicationVer() {
    QReadLocker rLock(&properiesLock_);
    return applicationVer_;
}

QString Device::platformId() {
    QReadLocker rLock(&properiesLock_);
    return platformId_;
}

bool Device::hasClassId() {
    QReadLocker rLock(&properiesLock_);
    return (classId_.isNull() == false);
}

QString Device::classId() {
    QReadLocker rLock(&properiesLock_);
    return classId_;
}

QString Device::controllerPlatformId() {
    QReadLocker rLock(&properiesLock_);
    return controllerPlatformId_;
}

QString Device::controllerClassId() {
    QReadLocker rLock(&properiesLock_);
    return controllerClassId_;
}

QString Device::firmwareClassId() {
    QReadLocker rLock(&properiesLock_);
    return firmwareClassId_;
}

Device::ApiVersion Device::apiVersion() {
    QReadLocker rLock(&properiesLock_);
    return apiVersion_;
}

Device::ControllerType Device::controllerType() {
    QReadLocker rLock(&properiesLock_);
    return controllerType_;
}

QByteArray Device::deviceId() const {
    return deviceId_;
}

const QString Device::deviceName() const {
    return deviceName_;
}

Device::Type Device::deviceType() const {
    return deviceType_;
}

bool Device::isControllerConnectedToPlatform() {
    return ((this->controllerType() == ControllerType::Assisted) && this->hasClassId());
}

void Device::setVersions(const char* bootloaderVer, const char* applicationVer) {
    // Do not change property if parameter is nullptr.
    QWriteLocker wLock(&properiesLock_);
    if (bootloaderVer)  { bootloaderVer_ = bootloaderVer; }
    if (applicationVer) { applicationVer_ = applicationVer; }
}

void Device::setProperties(const char* name, const char* platformId, const char* classId, ControllerType type) {
    // Clear property of parameter is nullptr.
    QWriteLocker wLock(&properiesLock_);
    if (name) { name_ = name; }
    else { name_.clear(); }

    if (platformId) { platformId_ = platformId; }
    else { platformId_.clear(); }

    if (classId) { classId_ = classId; }
    else { classId_.clear(); }

    controllerType_ = type;
}

void Device::setAssistedProperties(const char* platformId, const char* classId, const char* fwClassId) {
    // Clear property of parameter is nullptr.
    QWriteLocker wLock(&properiesLock_);
    if (platformId) { controllerPlatformId_ = platformId; }
    else { controllerPlatformId_.clear(); }

    if (classId) { controllerClassId_ = classId; }
    else { controllerClassId_.clear(); }

    if (fwClassId) { firmwareClassId_ = fwClassId; }
    else { firmwareClassId_.clear(); }
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
