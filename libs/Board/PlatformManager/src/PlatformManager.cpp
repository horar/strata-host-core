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

    // forcibly terminate all scanners, do not wait for signals
    foreach(DeviceScannerPtr scanner, scanners_) {
        disconnect(scanner.get(), nullptr, this, nullptr);
        scanner->deinit();
    }
    scanners_.clear();

    // forcibly terminate all devices, do not wait for signals
    foreach(PlatformPtr platform, closedPlatforms_) {
        disconnect(platform.get(), nullptr, this, nullptr);
        platform->terminate(false);
    }
    closedPlatforms_.clear();

    foreach(PlatformPtr platform, openedPlatforms_) {
        disconnect(platform.get(), nullptr, this, nullptr);
        const QByteArray deviceId = platform->deviceId();
        emit platformAboutToClose(deviceId);
        platform->terminate(true);
        emit platformRemoved(deviceId);
        qCDebug(logCategoryPlatformManager).noquote() << "Platform terminated by force, deviceId:" << deviceId;
    }
    openedPlatforms_.clear();
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
        qCCritical(logCategoryPlatformManager) << "Invalid DeviceScanner type:" << scannerType;
        return;
    }
    }

    for (const auto &existingScanner : scanners_) {
        if (existingScanner->scannerPrefix().startsWith(scanner->scannerPrefix()) ||
            scanner->scannerPrefix().startsWith(existingScanner->scannerPrefix())) {

            qCCritical(logCategoryPlatformManager) << "Colliding scanner prefixes:" << scanner->scannerType() << scanner->scannerPrefix() << existingScanner->scannerType() << existingScanner->scannerPrefix();
            return;
        }
    }

    scanners_.insert(scannerType, scanner);

    qCDebug(logCategoryPlatformManager) << "Created DeviceScanner with type:" << scannerType;

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

    qCDebug(logCategoryPlatformManager) << "Erased DeviceScanner with type:" << scannerType;
}

bool PlatformManager::disconnectPlatform(const QByteArray& deviceId, std::chrono::milliseconds disconnectDuration) {
    auto it = openedPlatforms_.constFind(deviceId);
    if (it != openedPlatforms_.constEnd()) {
        qCDebug(logCategoryPlatformManager).noquote().nospace() << "Going to disconnect platform, deviceId: "
            << deviceId << ", duration: " << disconnectDuration.count() << " ms";
        it.value()->close(disconnectDuration);
        return true;
    }
    return false;
}

bool PlatformManager::reconnectPlatform(const QByteArray& deviceId) {
    auto it = closedPlatforms_.constFind(deviceId);
    if (it != closedPlatforms_.constEnd()) {
        qCDebug(logCategoryPlatformManager).noquote() << "Going to reconnect platform, deviceId:" << deviceId;
        it.value()->open();
        return true;
    }
    return false;
}

PlatformPtr PlatformManager::getPlatform(const QByteArray& deviceId, bool open, bool closed) const {
    if ((open == true) && (closed == false)) {
        return openedPlatforms_.value(deviceId);
    } else if ((open == false) && (closed == true)) {
        return closedPlatforms_.value(deviceId);
    } else if ((open == true) && (closed == true)) {
        auto openIter = openedPlatforms_.constFind(deviceId);
        if (openIter != openedPlatforms_.constEnd()) {
            return openIter.value();
        }
        auto closedIter = closedPlatforms_.constFind(deviceId);
        if (closedIter != closedPlatforms_.constEnd()) {
            return closedIter.value();
        }
    }

    return PlatformPtr();
}

QList<PlatformPtr> PlatformManager::getPlatforms(bool open, bool closed) const {
    if ((open == true) && (closed == false)) {
        return openedPlatforms_.values();
    } else if ((open == false) && (closed == true)) {
        return closedPlatforms_.values();
    } else if ((open == true) && (closed == true)) {
        return openedPlatforms_.values() + closedPlatforms_.values();
    } else {
        return QList<PlatformPtr>();
    }
}

QList<QByteArray> PlatformManager::getDeviceIds(bool open, bool closed) {
    if ((open == true) && (closed == false)) {
        return openedPlatforms_.keys();
    } else if ((open == false) && (closed == true)) {
        return closedPlatforms_.keys();
    } else if ((open == true) && (closed == true)) {
        return openedPlatforms_.keys() + closedPlatforms_.keys();
    } else {
        return QList<QByteArray>();
    }
}

DeviceScannerPtr PlatformManager::getScanner(Device::Type scannerType) {
    return scanners_.value(scannerType);
}

void PlatformManager::handleDeviceDetected(PlatformPtr platform) {
    if (platform == nullptr) {
        qCCritical(logCategoryPlatformManager) << "Received corrupt platform pointer:" << platform;
        return;
    }

    const QByteArray deviceId = platform->deviceId();

    qCInfo(logCategoryPlatformManager).nospace().noquote() << "Platform detected: deviceId: " << deviceId << ", Type: " << platform->deviceType();

    if ((openedPlatforms_.contains(deviceId) == false) &&
        (closedPlatforms_.contains(deviceId) == false)) {
        // add first to closedPlatforms_ and when open() succeeds, add to openedPlatforms_
        closedPlatforms_.insert(deviceId, platform);

        connect(platform.get(), &Platform::opened, this, &PlatformManager::handlePlatformOpened, Qt::QueuedConnection);
        connect(platform.get(), &Platform::aboutToClose, this, &PlatformManager::handlePlatformAboutToClose, Qt::QueuedConnection);
        connect(platform.get(), &Platform::closed, this, &PlatformManager::handlePlatformClosed, Qt::QueuedConnection);
        connect(platform.get(), &Platform::terminated, this, &PlatformManager::handlePlatformTerminated, Qt::QueuedConnection);
        connect(platform.get(), &Platform::recognized, this, &PlatformManager::handlePlatformRecognized, Qt::QueuedConnection);
        connect(platform.get(), &Platform::platformIdChanged, this, &PlatformManager::handlePlatformIdChanged, Qt::QueuedConnection);
        connect(platform.get(), &Platform::deviceError, this, &PlatformManager::handleDeviceError, Qt::QueuedConnection);

        platform->open();
    } else {
        qCCritical(logCategoryPlatformManager) << "Unable to add platform to maps, device Id already exists";
    }
}

void PlatformManager::handleDeviceLost(QByteArray deviceId) {
    qCInfo(logCategoryPlatformManager).noquote() << "Platform lost: deviceId:" << deviceId;

    auto openIter = openedPlatforms_.constFind(deviceId);
    if (openIter != openedPlatforms_.constEnd()) {
        openIter.value()->terminate(true);
        return;
    }
    auto closedIter = closedPlatforms_.constFind(deviceId);
    if (closedIter != closedPlatforms_.constEnd()) {
        closedIter.value()->terminate(false);
        return;
    }

    qCWarning(logCategoryPlatformManager).noquote() << "Unable to erase platform from maps, device Id does not exist:" << deviceId;
}

void PlatformManager::handlePlatformOpened() {
    Platform *platform = qobject_cast<Platform*>(QObject::sender());
    if (platform == nullptr) {
        qCCritical(logCategoryPlatformManager) << "Platform does not exist";
        return;
    }

    const QByteArray deviceId = platform->deviceId();

    auto closedIter = closedPlatforms_.find(deviceId);
    if (closedIter != closedPlatforms_.end()) {
        PlatformPtr platformPtr = closedIter.value();
        closedPlatforms_.erase(closedIter);
        openedPlatforms_.insert(deviceId, platformPtr);
        qCInfo(logCategoryPlatformManager).noquote() << "Platform open, deviceId:" << deviceId;

        emit platformAdded(deviceId);

        startPlatformOperations(platformPtr);
    } else if (openedPlatforms_.contains(deviceId)) {
        qCDebug(logCategoryPlatformManager).noquote() << "Platform already open, deviceId:" << deviceId;
    } else {
        qCWarning(logCategoryPlatformManager).noquote() << "Unable to move to openedPlatforms_, device Id does not exist:" << deviceId;
    }
}

void PlatformManager::handlePlatformAboutToClose() {
    Platform *platform = qobject_cast<Platform*>(QObject::sender());
    if (platform == nullptr) {
        qCCritical(logCategoryPlatformManager) << "Platform does not exist";
        return;
    }

    const QByteArray deviceId = platform->deviceId();

    qCDebug(logCategoryPlatformManager).noquote() << "Platform about to close, deviceId:" << deviceId;

    platformOperations_.stopOperation(deviceId);

    emit platformAboutToClose(deviceId);
}

void PlatformManager::handlePlatformClosed() {
    Platform *platform = qobject_cast<Platform*>(QObject::sender());
    if (platform == nullptr) {
        qCCritical(logCategoryPlatformManager) << "Platform does not exist";
        return;
    }

    const QByteArray deviceId = platform->deviceId();

    auto openIter = openedPlatforms_.find(deviceId);
    if (openIter != openedPlatforms_.end()) {
        PlatformPtr platformPtr = openIter.value();
        openedPlatforms_.erase(openIter);
        closedPlatforms_.insert(deviceId, platformPtr);
        qCInfo(logCategoryPlatformManager).noquote() << "Platform closed, deviceId:" << deviceId;
        emit platformRemoved(deviceId);
    } else if (closedPlatforms_.contains(deviceId)) {
        qCDebug(logCategoryPlatformManager).noquote() << "Platform already closed, deviceId:" << deviceId;
    } else {
        qCWarning(logCategoryPlatformManager).noquote() << "Unable to move to closedPlatforms_, device Id does not exist:" << deviceId;
    }
}

void PlatformManager::handlePlatformTerminated() {
    Platform *platform = qobject_cast<Platform*>(QObject::sender());
    if (platform == nullptr) {
        qCCritical(logCategoryPlatformManager) << "Platform does not exist";
        return;
    }

    const QByteArray deviceId = platform->deviceId();

    auto closedIter = closedPlatforms_.find(deviceId);
    if (closedIter != closedPlatforms_.end()) {
        disconnect(closedIter.value().get(), nullptr, this, nullptr);
        closedPlatforms_.erase(closedIter);
        qCDebug(logCategoryPlatformManager).noquote() << "Terminated device:" << deviceId;
        return;
    }

    auto openIter = openedPlatforms_.find(deviceId);
    if (openIter != openedPlatforms_.end()) {
        disconnect(openIter.value().get(), nullptr, this, nullptr);
        openedPlatforms_.erase(openIter);
        qCWarning(logCategoryPlatformManager).noquote() << "Terminating open device:" << deviceId;
        return;
    }

    qCWarning(logCategoryPlatformManager).noquote() << "Unable to terminate, device Id does not exist:" << deviceId;
}

void PlatformManager::handlePlatformRecognized(bool isRecognized) {
    Platform *platform = qobject_cast<Platform*>(QObject::sender());
    if (platform == nullptr) {
        qCCritical(logCategoryPlatformManager) << "Platform does not exist";
        return;
    }

    const QByteArray deviceId = platform->deviceId();

    qCDebug(logCategoryPlatformManager).noquote().nospace() << "Platform recognized: " << isRecognized << ", deviceId: " << deviceId;

    emit platformRecognized(deviceId, isRecognized);

    if (isRecognized == false && keepDevicesOpen_ == false) {
        qCInfo(logCategoryPlatformManager).noquote()
            << "Platform was not recognized, going to release communication channel, deviceId:" << deviceId;
        disconnectPlatform(deviceId);
    }
}

void PlatformManager::handlePlatformIdChanged() {
    Platform *platform = qobject_cast<Platform*>(QObject::sender());
    if (platform == nullptr) {
        qCCritical(logCategoryPlatformManager) << "Platform does not exist";
        return;
    }

    const QByteArray deviceId = platform->deviceId();

    auto iter = openedPlatforms_.constFind(deviceId);
    if (iter != openedPlatforms_.constEnd()) {
        qCDebug(logCategoryPlatformManager).noquote() << "Platform Id changed, going to Identify, deviceId:" << deviceId;
        startPlatformOperations(iter.value());
    } else if (closedPlatforms_.contains(deviceId)) {
        qCDebug(logCategoryPlatformManager).noquote() << "Platform Id changed, but unable to Identify (platform closed), deviceId:" << deviceId;
    } else {
        qCWarning(logCategoryPlatformManager).noquote() << "Platform Id changed, but unable to Identify, device Id does not exist:" << deviceId;
    }
}

void PlatformManager::handleDeviceError(Device::ErrorCode errCode, QString errStr) {
    Platform *platform = qobject_cast<Platform*>(QObject::sender());
    if (platform == nullptr) {
        return;
    }

    switch (errCode) {
    case Device::ErrorCode::NoError: {
    } break;
    case Device::ErrorCode::DeviceFailedToOpen:
    case Device::ErrorCode::DeviceFailedToOpenGoingToRetry: {
        // no need to handle these error codes
        // qCDebug(logCategoryPlatformManager).nospace() << "Platform warning received: deviceId: " << platform->deviceId() << ", code: " << errCode << ", message: " << errStr;
    } break;
    case Device::ErrorCode::DeviceDisconnected: {
        const QByteArray deviceId = platform->deviceId();
        qCWarning(logCategoryPlatformManager).nospace() << "Platform was disconnected: deviceId: " << deviceId << ", code: " << errCode << ", message: " << errStr;
        disconnectPlatform(deviceId);
    } break;
    case Device::ErrorCode::DeviceError: {
        const QByteArray deviceId = platform->deviceId();
        qCCritical(logCategoryPlatformManager).nospace() << "Platform error received: deviceId: " << deviceId << ", code: " << errCode << ", message: " << errStr;
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
