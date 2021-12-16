/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include <Platform.h>
#include <CommandValidator.h>

#include "logging/LoggingQtCategories.h"

#include <QMutexLocker>
#include <QReadLocker>
#include <QWriteLocker>

#include <rapidjson/document.h>
#include <rapidjson/schema.h>

#include <stdexcept>

namespace strata::platform {

QDebug operator<<(QDebug dbg, const Platform* d) {
    return dbg.nospace().noquote() << d->device_;
}

QDebug operator<<(QDebug dbg, const PlatformPtr& d) {
    return dbg << d.get();
}

Platform::Platform(const device::DevicePtr& device) :
    device_(device),
    operationLock_(0),
    bootloaderMode_(false),
    isRecognized_(false),
    platformState_(PlatformState::Closed),
    apiVersion_(ApiVersion::Unknown),
    controllerType_(ControllerType::Embedded)
{
    if (device_ == nullptr) {
        throw std::invalid_argument("Missing mandatory device pointer in platform");
    }

    connect(device_.get(), &device::Device::opened, this, &Platform::openedHandler);
    connect(device_.get(), &device::Device::messageReceived, this, &Platform::messageReceivedHandler);
    // 'messageSent' must be connected via queued connection, see comment in 'messageSentHandler'
    connect(device_.get(), &device::Device::messageSent, this, &Platform::messageSentHandler, Qt::QueuedConnection);
    connect(device_.get(), &device::Device::deviceError, this, &Platform::deviceErrorHandler);

    reconnectTimer_.setSingleShot(true);
    connect(&reconnectTimer_, &QTimer::timeout, this, &Platform::open);
}

Platform::~Platform() {
    // stop reconnectTimer_ just in case close was not called before (should not happen)
    abortReconnect();

    // no need to close device here (if close was not called before), will be done in device
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

void Platform::messageReceivedHandler(QByteArray rawMsg) {
    // re-emit the message first, then validate for platform_id_changed

    PlatformMessage message(rawMsg);

    if (message.isJsonValid() == false) {
        qCDebug(lcPlatform) << this << "JSON error at offset "
            << message.jsonErrorOffset() << ": " << message.jsonErrorString();
    }

    emit messageReceived(message);

    if (message.isJsonValidObject()) {
        if (CommandValidator::validateJsonWithSchema(platformIdChangedSchema, message.json(), true)) {
            qCInfo(lcPlatform) << this << "Received 'platform_id_changed' notification";

            emit platformIdChanged();
        }
    }
}

void Platform::messageSentHandler(QByteArray rawMsg, unsigned msgNum, QString errStr) {
    // We need to emit 'messageSent' signal after return from 'sendMessage' method,
    // (due to error handling), so this slot must be connected via 'Qt::QueuedConnection'
    // or signal must be emitted via single-shot timer (with duration 0 ms).
    emit messageSent(rawMsg, msgNum, errStr);
}

void Platform::deviceErrorHandler(device::Device::ErrorCode errCode, QString errStr) {
    if (errCode == device::Device::ErrorCode::DeviceFailedToOpen) {
        if (errStr.isEmpty()) {
            errStr = "Unable to open device.";
        }
    }
    emit deviceError(errCode, errStr);
}

void Platform::open() {
    if (platformState_ == PlatformState::Closed) {
        abortReconnect();
        device_->open();
    } else {
        qCWarning(lcPlatform) << this << "Attempting to open device in invalid state" << platformState_;
    }
}

void Platform::close(const std::chrono::milliseconds waitInterval) {
    if (platformState_ == PlatformState::Opened) {
        abortReconnect();
        platformState_ = PlatformState::AboutToClose;
        emit aboutToClose();
        device_->close();   // can take some time depending on the device type
        // clear internal device buffer for receiving messages because
        // there can stay fragments of old message when device is reconnected
        resetReceiving();
        emit closed();
        platformState_ = PlatformState::Closed;
        if (waitInterval != std::chrono::milliseconds::zero()) {
            reconnectTimer_.start(waitInterval.count());
        }
    } else {
        qCWarning(lcPlatform) << this << "Attempting to close device in invalid state" << platformState_;
    }
}

void Platform::terminate() {
    if (platformState_ != PlatformState::Terminated) {
        if (platformState_ == PlatformState::Opened) {
            close(std::chrono::milliseconds::zero());
        } else {
            abortReconnect();
        }
        platformState_ = PlatformState::Terminated;
        emit terminated();
    } else {
        qCWarning(lcPlatform) << this << "Attempting to terminate already terminated platform";
    }
}

// public method
unsigned Platform::sendMessage(const QByteArray& message) {
    return sendMessage(message, 0);
}

// private method
unsigned Platform::sendMessage(const QByteArray& message, quintptr lockId) {
    // Strata commands must end with new line character ('\n')
    QByteArray msgToWrite(message);
    if (msgToWrite.endsWith('\n') == false) {
        msgToWrite.append('\n');
    }

    bool canWrite = false;
    {
        QMutexLocker lock(&operationMutex_);
        if (operationLock_ == lockId) {
            canWrite = true;
        }
    }
    if (canWrite) {
        return device_->sendMessage(msgToWrite);
    }

    QString errMsg(QStringLiteral("Cannot write to device because device is busy."));
    qCWarning(lcPlatform) << this << errMsg;
    unsigned messageNumber = device_->nextMessageNumber();
    emit device_->messageSent(msgToWrite, messageNumber, errMsg);
    return messageNumber;
}

QString Platform::name() {
    QReadLocker rLock(&propertiesLock_);
    return name_;
}

QString Platform::bootloaderVer() {
    QReadLocker rLock(&propertiesLock_);
    return bootloaderVer_;
}

QString Platform::applicationVer() {
    QReadLocker rLock(&propertiesLock_);
    return applicationVer_;
}

QString Platform::platformId() {
    QReadLocker rLock(&propertiesLock_);
    return platformId_;
}

bool Platform::hasClassId() {
    QReadLocker rLock(&propertiesLock_);
    return (classId_.isNull() == false);
}

QString Platform::classId() {
    QReadLocker rLock(&propertiesLock_);
    return classId_;
}

QString Platform::controllerPlatformId() {
    QReadLocker rLock(&propertiesLock_);
    return controllerPlatformId_;
}

QString Platform::controllerClassId() {
    QReadLocker rLock(&propertiesLock_);
    return controllerClassId_;
}

QString Platform::firmwareClassId() {
    QReadLocker rLock(&propertiesLock_);
    return firmwareClassId_;
}

Platform::ApiVersion Platform::apiVersion() {
    QReadLocker rLock(&propertiesLock_);
    return apiVersion_;
}

Platform::ControllerType Platform::controllerType() {
    QReadLocker rLock(&propertiesLock_);
    return controllerType_;
}

bool Platform::isControllerConnectedToPlatform() {
    return ((this->controllerType() == ControllerType::Assisted) && this->hasClassId());
}

bool Platform::isRecognized() {
    QReadLocker rLock(&propertiesLock_);
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

bool Platform::deviceConnected() const {
    return device_->isConnected();
}

void Platform::resetReceiving() {
    device_->resetReceiving();
}

void Platform::SetTerminationCause(const QString& terminationCause) {
    terminationCause_ = terminationCause;
}

QString Platform::GetTerminationCause() const {
    return terminationCause_;
}

void Platform::setVersions(const char* bootloaderVer, const char* applicationVer) {
    // Do not change property if parameter is nullptr.
    QWriteLocker wLock(&propertiesLock_);
    if (bootloaderVer)  { bootloaderVer_ = bootloaderVer; }
    if (applicationVer) { applicationVer_ = applicationVer; }
}

void Platform::setProperties(const char* name, const char* platformId, const char* classId, ControllerType type) {
    // Clear property of parameter is nullptr.
    QWriteLocker wLock(&propertiesLock_);
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
    QWriteLocker wLock(&propertiesLock_);
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
    QWriteLocker wLock(&propertiesLock_);
    bootloaderMode_ = inBootloaderMode;
}

bool Platform::bootloaderMode() {
    QReadLocker rLock(&propertiesLock_);
    return bootloaderMode_;
}

void Platform::setApiVersion(ApiVersion apiVersion) {
    QWriteLocker wLock(&propertiesLock_);
    apiVersion_ = apiVersion;
}

void Platform::setRecognized(bool isRecognized) {
    {
        QWriteLocker wLock(&propertiesLock_);
        isRecognized_ = isRecognized;
    }
    emit recognized(isRecognized, bootloaderMode());
}

bool Platform::isOpen() const {
    return platformState_ == PlatformState::Opened;
}

void Platform::openedHandler() {
    if (platformState_ == PlatformState::Closed) {
        platformState_ = PlatformState::Opened;
        emit opened();
    } else {
        qCWarning(lcPlatform) << this << "Attempting to emit open() signal in invalid state" << platformState_;
    }
}

void Platform::abortReconnect() {
    if (reconnectTimer_.isActive()) {
        reconnectTimer_.stop();
    }
}

}  // namespace
