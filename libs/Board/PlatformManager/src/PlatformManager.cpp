/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "PlatformManager.h"
#include "PlatformManagerConstants.h"
#include "logging/LoggingQtCategories.h"

#include <Serial/SerialDeviceScanner.h>
#include <Mock/MockDeviceScanner.h>
#include <Tcp/TcpDeviceScanner.h>

namespace strata {

using device::Device;
using platform::Platform;
using platform::PlatformPtr;
using device::scanner::DeviceScanner;
using device::scanner::DeviceScannerPtr;
using device::scanner::MockDeviceScanner;
using device::scanner::SerialDeviceScanner;
using device::scanner::TcpDeviceScanner;

namespace operation = platform::operation;

PlatformManager::PlatformManager(bool requireFwInfoResponse, bool keepDevicesOpen, bool handleIdentify) :
    platformOperations_(true, true),
    reqFwInfoResp_(requireFwInfoResponse),
    keepDevicesOpen_(keepDevicesOpen),
    handleIdentify_(handleIdentify)
{ }

PlatformManager::~PlatformManager() {
    // stop all operations here to avoid capturing signals later which could crash
    platformOperations_.stopAllOperations();

    // forcibly terminate all scanners
    for(const DeviceScannerPtr& scanner: qAsConst(scanners_)) {
        disconnect(scanner.get(), nullptr, this, nullptr);  // ignore signals, do cleanup manually
        scanner->deinit();
    }
    scanners_.clear();

    // forcibly terminate all devices, do not wait for signals as they might be queued
    for(const PlatformPtr& platform: qAsConst(platforms_)) {
        disconnect(platform.get(), nullptr, this, nullptr);
        const QByteArray deviceId = platform->deviceId();
        if (platform->isOpen()) {
            emit platformAboutToClose(deviceId);
            platform->close();
            emit platformClosed(deviceId);
            platform->terminate();
            emit platformRemoved(deviceId);
            qCDebug(lcPlatformManager).noquote() << "Platform terminated by force, deviceId:" << deviceId;
        } else {
            platform->terminate();
            emit platformRemoved(deviceId);
        }
    }
    platforms_.clear();
}

void PlatformManager::addScanner(Device::Type scannerType, quint32 flags) {
    if (scanners_.contains(scannerType)) {
        return; // already added
    }

    DeviceScannerPtr scanner;

    switch(scannerType) {
    case Device::Type::SerialDevice: {
        scanner = std::make_shared<SerialDeviceScanner>();
    } break;
    case Device::Type::MockDevice: {
        scanner = std::make_shared<MockDeviceScanner>();
    } break;
    case Device::Type::TcpDevice: {
        scanner = std::make_shared<TcpDeviceScanner>();
    } break;
    default: {
        qCCritical(lcPlatformManager) << "Invalid DeviceScanner type:" << scannerType;
        return;
    }
    }

    for(const auto &existingScanner: qAsConst(scanners_)) {
        if (existingScanner->scannerPrefix().startsWith(scanner->scannerPrefix()) ||
            scanner->scannerPrefix().startsWith(existingScanner->scannerPrefix())) {

            qCCritical(lcPlatformManager) << "Colliding scanner prefixes:" << scanner->scannerType() << scanner->scannerPrefix() << existingScanner->scannerType() << existingScanner->scannerPrefix();
            return;
        }
    }

    scanners_.insert(scannerType, scanner);

    qCDebug(lcPlatformManager) << "Created DeviceScanner with type:" << scannerType;

    connect(scanner.get(), &DeviceScanner::deviceDetected, this, &PlatformManager::handleDeviceDetected);
    connect(scanner.get(), &DeviceScanner::deviceLost, this, &PlatformManager::handleDeviceLost);

    scanner->init(flags);
}

void PlatformManager::removeScanner(Device::Type scannerType) {
    auto iter = scanners_.find(scannerType);
    if (iter == scanners_.end()) {
        return; // scanner not found
    }

    DeviceScannerPtr scanner = iter.value();
    scanners_.erase(iter);

    scanner->deinit(); // all devices will be reported as lost

    disconnect(scanner.get(), nullptr, this, nullptr); // in case someone held the scanner pointer

    qCDebug(lcPlatformManager) << "Erased DeviceScanner with type:" << scannerType;
}

bool PlatformManager::disconnectPlatform(const QByteArray& deviceId, std::chrono::milliseconds disconnectDuration) {
    auto iter = platforms_.constFind(deviceId);
    if (iter != platforms_.constEnd()) {
        PlatformPtr platform = iter.value();
        if (platform->isOpen()) {
            qCDebug(lcPlatformManager).noquote().nospace() << "Going to disconnect platform, deviceId: "
                << deviceId << ", duration: " << disconnectDuration.count() << " ms";
            platform->close(disconnectDuration);
            return true;
        } else {
            qCDebug(lcPlatformManager).noquote().nospace() << "Platform already disconnected, deviceId: " << deviceId;
        }
    } else {
        qCDebug(lcPlatformManager).noquote().nospace() << "Platform not found, deviceId: " << deviceId;
    }
    return false;
}

bool PlatformManager::disconnectPlatform(const QByteArray& deviceId) {
    if (platforms_.contains(deviceId) == false) {
        qCDebug(lcPlatformManager).noquote().nospace() << "Platform not found, deviceId: " << deviceId;
        return false;
    }

    Device::Type scannerType = DeviceScanner::scannerType(deviceId);
    DeviceScannerPtr scanner = getScanner(scannerType);
    if (scanner == nullptr) {
        qCCritical(lcPlatformManager).nospace() << "Unable to acquire scanner type: " << scannerType;
        return false;
    }

    QString res = scanner->disconnectDevice(deviceId);
    if (res.isEmpty() == false) {
        qCDebug(lcPlatformManager).noquote().nospace() << "Unable to disconnect platform in scanner (" << res << ") deviceId: " << deviceId;
        return false;
    }
    return true;
}

bool PlatformManager::reconnectPlatform(const QByteArray& deviceId) {
    auto iter = platforms_.constFind(deviceId);
    if (iter != platforms_.constEnd()) {
        PlatformPtr platform = iter.value();
        if (platform->isOpen() == false) {
            qCDebug(lcPlatformManager).noquote() << "Going to reconnect platform, deviceId:" << deviceId;
            platform->open();
            return true;
        } else {
            qCDebug(lcPlatformManager).noquote().nospace() << "Platform already connected, deviceId: " << deviceId;
        }
    } else {
        qCDebug(lcPlatformManager).noquote().nospace() << "Platform not found, deviceId: " << deviceId;
    }
    return false;
}

PlatformPtr PlatformManager::getPlatform(const QByteArray& deviceId, bool open, bool closed) const {
    PlatformPtr platform = platforms_.value(deviceId);
    if (platform != nullptr) {
        if ((platform->isOpen() && open) || ((platform->isOpen() == false) && closed)) {
            return platform;
        }
    }
    return PlatformPtr();
}

QList<QByteArray> PlatformManager::getDeviceIds(bool open, bool closed) {
    QList<QByteArray> platforms;
    for(const PlatformPtr& platform: qAsConst(platforms_)) {
        if ((platform->isOpen() && open) || ((platform->isOpen() == false) && closed)) {
            platforms.push_back(platform->deviceId());
        }
    }
    return platforms;
}

DeviceScannerPtr PlatformManager::getScanner(Device::Type scannerType) {
    return scanners_.value(scannerType);
}

void PlatformManager::handleDeviceDetected(PlatformPtr platform) {
    if (platform == nullptr) {
        qCCritical(lcPlatformManager) << "Received corrupt platform pointer:" << platform;
        return;
    }

    const QByteArray deviceId = platform->deviceId();

    qCInfo(lcPlatformManager).nospace().noquote() << "Platform detected: deviceId: " << deviceId << ", Type: " << platform->deviceType();

    if ((platforms_.contains(deviceId) == false)) {
        platforms_.insert(deviceId, platform);

        connect(platform.get(), &Platform::opened, this, &PlatformManager::handlePlatformOpened);
        connect(platform.get(), &Platform::aboutToClose, this, &PlatformManager::handlePlatformAboutToClose);
        connect(platform.get(), &Platform::closed, this, &PlatformManager::handlePlatformClosed);
        // terminated signal must be queued as it erases the object and it must wait for other operations before doing so
        // using deleteLater also works, but during exit of program it does not triggers and fails to clean up (e.g. temp data on HDD)
        connect(platform.get(), &Platform::terminated, this, &PlatformManager::handlePlatformTerminated, Qt::QueuedConnection);
        connect(platform.get(), &Platform::recognized, this, &PlatformManager::handlePlatformRecognized);
        connect(platform.get(), &Platform::platformIdChanged, this, &PlatformManager::handlePlatformIdChanged);
        connect(platform.get(), &Platform::deviceError, this, &PlatformManager::handleDeviceError);

        platform->open();
    } else {
        qCCritical(lcPlatformManager) << "Unable to add platform to maps, device Id already exists";
    }
}

void PlatformManager::handleDeviceLost(QByteArray deviceId) {
    qCInfo(lcPlatformManager).noquote() << "Platform lost: deviceId:" << deviceId;

    auto iter = platforms_.constFind(deviceId);
    if (iter != platforms_.constEnd()) {
        qCDebug(lcPlatformManager).noquote().nospace() << "Going to terminate platform, deviceId: " << deviceId;
        iter.value()->terminate();
    }
}

void PlatformManager::handlePlatformOpened() {
    Platform *platform = qobject_cast<Platform*>(QObject::sender());
    if (platform == nullptr) {
        qCCritical(lcPlatformManager) << "Platform does not exist";
        return;
    }

    const QByteArray deviceId = platform->deviceId();

    auto iter = platforms_.find(deviceId);
    if (iter != platforms_.end()) {
        PlatformPtr platformPtr = iter.value();
        qCInfo(lcPlatformManager).noquote() << "Platform open, deviceId:" << deviceId;

        emit platformAdded(deviceId);

        startPlatformOperations(platformPtr);
    } else {
        qCCritical(lcPlatformManager).noquote() << "Unable to locate platform, device Id does not exist:" << deviceId;
    }
}

void PlatformManager::handlePlatformAboutToClose() {
    Platform *platform = qobject_cast<Platform*>(QObject::sender());
    if (platform == nullptr) {
        qCCritical(lcPlatformManager) << "Platform does not exist";
        return;
    }

    const QByteArray deviceId = platform->deviceId();

    qCDebug(lcPlatformManager).noquote() << "Platform about to close, deviceId:" << deviceId;

    platformOperations_.stopOperation(deviceId);

    emit platformAboutToClose(deviceId);
}

void PlatformManager::handlePlatformClosed() {
    Platform *platform = qobject_cast<Platform*>(QObject::sender());
    if (platform == nullptr) {
        qCCritical(lcPlatformManager) << "Platform does not exist";
        return;
    }

    const QByteArray deviceId = platform->deviceId();

    qCInfo(lcPlatformManager).noquote() << "Platform closed, deviceId:" << deviceId;
    emit platformClosed(deviceId);
}

void PlatformManager::handlePlatformTerminated() {
    Platform *platform = qobject_cast<Platform*>(QObject::sender());
    if (platform == nullptr) {
        qCCritical(lcPlatformManager) << "Platform does not exist";
        return;
    }

    const QByteArray deviceId = platform->deviceId();
    auto iter = platforms_.find(deviceId);
    if (iter != platforms_.end()) {
        qCDebug(lcPlatformManager).noquote() << "Terminating device:" << deviceId;
        disconnect(iter.value().get(), nullptr, this, nullptr);
        platforms_.erase(iter);     // platform gets deleted after this point, do not reuse
        emit platformRemoved(deviceId);
        return;
    } else {
        qCWarning(lcPlatformManager).noquote() << "Unable to terminate, device Id does not exist:" << deviceId;
    }
}

void PlatformManager::handlePlatformRecognized(bool isRecognized, bool inBootloader) {
    Platform *platform = qobject_cast<Platform*>(QObject::sender());
    if (platform == nullptr) {
        qCCritical(lcPlatformManager) << "Platform does not exist";
        return;
    }

    const QByteArray deviceId = platform->deviceId();

    qCDebug(lcPlatformManager).noquote().nospace() << "Platform recognized: " << isRecognized << ", deviceId: " << deviceId;

    emit platformRecognized(deviceId, isRecognized, inBootloader);

    if (isRecognized == false && keepDevicesOpen_ == false) {
        qCInfo(lcPlatformManager).noquote()
            << "Platform was not recognized and should be ignored, going to release communication channel, deviceId:" << deviceId;
        disconnectPlatform(deviceId);
    }
}

void PlatformManager::handlePlatformIdChanged() {
    Platform *platform = qobject_cast<Platform*>(QObject::sender());
    if (platform == nullptr) {
        qCCritical(lcPlatformManager) << "Platform does not exist";
        return;
    }

    const QByteArray deviceId = platform->deviceId();

    auto iter = platforms_.constFind(deviceId);
    if (iter != platforms_.constEnd()) {
        PlatformPtr platformPtr = iter.value();
        if (platformPtr->isOpen()) {
            qCDebug(lcPlatformManager).noquote() << "Platform Id changed, going to Identify, deviceId:" << deviceId;
            startPlatformOperations(platformPtr);
        } else {
            qCDebug(lcPlatformManager).noquote() << "Platform Id changed, but unable to Identify (platform closed), deviceId:" << deviceId;
        }
    } else {
        qCWarning(lcPlatformManager).noquote() << "Platform Id changed, but unable to Identify, device Id does not exist:" << deviceId;
    }
}

void PlatformManager::handleDeviceError(Device::ErrorCode errCode, QString errStr) {
    Platform *platform = qobject_cast<Platform*>(QObject::sender());
    if (platform == nullptr) {
        qCCritical(lcPlatformManager) << "Platform does not exist";
        return;
    }

    const QByteArray deviceId = platform->deviceId();

    switch (errCode) {
    case Device::ErrorCode::NoError: {
    } break;
    case Device::ErrorCode::DeviceFailedToOpenGoingToRetry: {
        // no need to handle this error code
        // qCDebug(lcPlatformManager).nospace() << "Platform failed to open, going to retry: deviceId: " << deviceId << ", code: " << errCode << ", message: " << errStr;
    } break;
    case Device::ErrorCode::DeviceFailedToOpen: {
        qCWarning(lcPlatformManager).nospace() << "Platform failed to open: deviceId: " << deviceId << ", code: " << errCode << ", message: " << errStr;
        disconnectPlatform(deviceId);
    }
    case Device::ErrorCode::DeviceDisconnected: {
        qCWarning(lcPlatformManager).nospace() << "Platform was disconnected: deviceId: " << deviceId << ", code: " << errCode << ", message: " << errStr;
        disconnectPlatform(deviceId);
    } break;
    case Device::ErrorCode::DeviceError: {
        qCCritical(lcPlatformManager).nospace() << "Platform error received: deviceId: " << deviceId << ", code: " << errCode << ", message: " << errStr;
        disconnectPlatform(deviceId);
    } break;
    }
}

void PlatformManager::startPlatformOperations(const PlatformPtr& platform) {
    if (handleIdentify_) {
        std::chrono::milliseconds delay = (platform->deviceType() == Device::Type::MockDevice)
                ? std::chrono::milliseconds::zero()
                : IDENTIFY_LAUNCH_DELAY;
        platformOperations_.Identify(platform, reqFwInfoResp_, GET_FW_INFO_MAX_RETRIES, delay);
    }
}

}  // namespace
