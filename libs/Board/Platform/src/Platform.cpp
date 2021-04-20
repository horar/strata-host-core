#include <Platform.h>
#include <CommandValidator.h>

#include "logging/LoggingQtCategories.h"

#include <QMutexLocker>
#include <QReadLocker>
#include <QWriteLocker>

#include <rapidjson/document.h>
#include <rapidjson/schema.h>

namespace strata::platform {

QDebug operator<<(QDebug dbg, const Platform* d) {
    return dbg.nospace().noquote() << d->device_;
}

QDebug operator<<(QDebug dbg, const PlatformPtr& d) {
    return dbg << d.get();
}

Platform::Platform(const device::DevicePtr& device) :
    device_(device), operationLock_(0), retryMsec_(std::chrono::milliseconds::zero()),
    bootloaderMode_(false), isRecognized_(false), apiVersion_(ApiVersion::Unknown),
    controllerType_(ControllerType::Embedded)
{
    if (device_ == nullptr) {
        throw std::invalid_argument("Missing mandatory device pointer in platform");
    }

    connect(device_.get(), &device::Device::messageReceived, this, &Platform::messageReceivedHandler);
    connect(device_.get(), &device::Device::messageSent, this, &Platform::messageSentHandler);
    connect(device_.get(), &device::Device::deviceError, this, &Platform::deviceErrorHandler);

    reconnectTimer_.setSingleShot(true);
    connect(&reconnectTimer_, &QTimer::timeout, this, &Platform::openDevice);
}

Platform::~Platform() {
    // stop reconnectTimer_ just in case close was not called before (should not happen)
    abortReconnect();

    // no need to close device here (if close was not called before), will be done in device
}

device::DevicePtr Platform::getDevice() const {
    return device_;
}

const rapidjson::SchemaDocument platformIdChangedSchema(
    CommandValidator::parseSchema(
R"(
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "type": "object",
  "properties": {
    "notification": {
      "type": "object",
      "properties": {
        "value": {"type": "string", "pattern": "^platform_id_changed$"}
      },
      "required": ["value"]
    }
  },
  "required": ["notification"]
}
)"
    )
);

void Platform::messageReceivedHandler(QByteArray msg) {
    // re-emit the message first, then parse
    emit messageReceived(device_->deviceId(), msg);

    rapidjson::Document doc;
    if (CommandValidator::parseJsonCommand(msg, doc, true) == false) {
        return;
    }
    if (CommandValidator::validateJsonWithSchema(platformIdChangedSchema, doc, true) == false) {
        return;
    }

    qCInfo(logCategoryPlatform).noquote()
        << "Received 'platform_id_changed' notification for device" << deviceId();

    emit platformIdChanged(device_->deviceId());
}

void Platform::messageSentHandler(QByteArray msg) {
    emit messageSent(device_->deviceId(), msg);
}

void Platform::deviceErrorHandler(device::Device::ErrorCode errCode, QString msg) {
    emit deviceError(device_->deviceId(), errCode, msg);
}

bool Platform::open(const std::chrono::milliseconds retryMsec) {
    retryMsec_ = retryMsec;
    abortReconnect();
    return openDevice();
}

void Platform::close(const std::chrono::milliseconds waitMsec, const std::chrono::milliseconds retryMsec) {
    retryMsec_ = retryMsec;
    abortReconnect();
    closeDevice(waitMsec);
}

void Platform::abortReconnect() {
    if (reconnectTimer_.isActive())
        reconnectTimer_.stop();
}

// public method
bool Platform::sendMessage(const QByteArray msg) {
    return sendMessage(msg, 0);
}

// private method
bool Platform::sendMessage(const QByteArray msg, quintptr lockId) {
    bool canWrite = false;
    {
        QMutexLocker lock(&operationMutex_);
        if (operationLock_ == lockId) {
            canWrite = true;
        }
    }
    if (canWrite) {
        // Slot connected to below emitted signal may emit other signals
        // and therefore it shouldn't be locked to avoid a deadlock.
        device_->sendMessage(msg);
        return true;
    } else {
        QString errMsg(QStringLiteral("Cannot write to device because device is busy."));
        qCWarning(logCategoryPlatform) << this << errMsg;
        emit deviceError(device_->deviceId(), device::Device::ErrorCode::DeviceBusy, errMsg);
        return false;
    }
}

QString Platform::name() {
    QReadLocker rLock(&properiesLock_);
    return name_;
}

QString Platform::bootloaderVer() {
    QReadLocker rLock(&properiesLock_);
    return bootloaderVer_;
}

QString Platform::applicationVer() {
    QReadLocker rLock(&properiesLock_);
    return applicationVer_;
}

QString Platform::platformId() {
    QReadLocker rLock(&properiesLock_);
    return platformId_;
}

bool Platform::hasClassId() {
    QReadLocker rLock(&properiesLock_);
    return (classId_.isNull() == false);
}

QString Platform::classId() {
    QReadLocker rLock(&properiesLock_);
    return classId_;
}

QString Platform::controllerPlatformId() {
    QReadLocker rLock(&properiesLock_);
    return controllerPlatformId_;
}

QString Platform::controllerClassId() {
    QReadLocker rLock(&properiesLock_);
    return controllerClassId_;
}

QString Platform::firmwareClassId() {
    QReadLocker rLock(&properiesLock_);
    return firmwareClassId_;
}

Platform::ApiVersion Platform::apiVersion() {
    QReadLocker rLock(&properiesLock_);
    return apiVersion_;
}

Platform::ControllerType Platform::controllerType() {
    QReadLocker rLock(&properiesLock_);
    return controllerType_;
}

bool Platform::isControllerConnectedToPlatform() {
    return ((this->controllerType() == ControllerType::Assisted) && this->hasClassId());
}

bool Platform::isRecognized() {
    QReadLocker rLock(&properiesLock_);
    return isRecognized_;
}

QByteArray Platform::deviceId() const {
    return device_->deviceId();
}

const QString Platform::deviceName() const {
    return device_->deviceName();
}

device::Device::Type Platform::deviceType() const {
    return device_->deviceType();
}

void Platform::setVersions(const char* bootloaderVer, const char* applicationVer) {
    // Do not change property if parameter is nullptr.
    QWriteLocker wLock(&properiesLock_);
    if (bootloaderVer)  { bootloaderVer_ = bootloaderVer; }
    if (applicationVer) { applicationVer_ = applicationVer; }
}

void Platform::setProperties(const char* name, const char* platformId, const char* classId, ControllerType type) {
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

void Platform::setAssistedProperties(const char* platformId, const char* classId, const char* fwClassId) {
    // Clear property of parameter is nullptr.
    QWriteLocker wLock(&properiesLock_);
    if (platformId) { controllerPlatformId_ = platformId; }
    else { controllerPlatformId_.clear(); }

    if (classId) { controllerClassId_ = classId; }
    else { controllerClassId_.clear(); }

    if (fwClassId) { firmwareClassId_ = fwClassId; }
    else { firmwareClassId_.clear(); }
}

bool Platform::lockDeviceForOperation(quintptr lockId) {
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

void Platform::unlockDevice(quintptr lockId) {
    QMutexLocker lock(&operationMutex_);
    if (operationLock_ == lockId) {
        operationLock_ = 0;
    }
}

void Platform::setBootloaderMode(bool inBootloaderMode) {
    QWriteLocker wLock(&properiesLock_);
    bootloaderMode_ = inBootloaderMode;
}

bool Platform::bootloaderMode() {
    QReadLocker rLock(&properiesLock_);
    return bootloaderMode_;
}

void Platform::setApiVersion(ApiVersion apiVersion) {
    QWriteLocker wLock(&properiesLock_);
    apiVersion_ = apiVersion;
}

void Platform::identifyFinished(bool isRecognized) {
    {
        QWriteLocker wLock(&properiesLock_);
        isRecognized_ = isRecognized;
    }
    emit recognized(device_->deviceId(), isRecognized);
}

bool Platform::openDevice() {
    if (device_->open() == true) {
        emit opened(device_->deviceId());
        return true;
    } else {
        QString errMsg(QStringLiteral("Unable to open device."));
        qCWarning(logCategoryPlatform) << this << errMsg;
        emit deviceError(device_->deviceId(), device::Device::ErrorCode::DeviceFailedToOpen, errMsg);
        if (retryMsec_ != std::chrono::milliseconds::zero()) {
            reconnectTimer_.start(retryMsec_.count());
        }
        return false;
    }
}

void Platform::closeDevice(const std::chrono::milliseconds waitMsec) {
    emit aboutToClose(device_->deviceId());
    device_->close();   // can take some time depending on the device type
    emit closed(device_->deviceId());
    if (waitMsec != std::chrono::milliseconds::zero()) {
        reconnectTimer_.start(waitMsec.count());
    }
}

}  // namespace
