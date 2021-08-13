#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QLatin1String>

#include "PlatformController.h"
#include "Dispatcher.h"
#include "logging/LoggingQtCategories.h"
#include "JsonStrings.h"

using strata::PlatformManager;
using strata::platform::Platform;
using strata::platform::PlatformPtr;
using strata::platform::PlatformMessage;

PlatformController::PlatformController(): platformManager_(false, false, true) {
    connect(&platformManager_, &PlatformManager::platformRecognized, this, &PlatformController::newConnection);
    connect(&platformManager_, &PlatformManager::platformAboutToClose, this, &PlatformController::closeConnection);
}

PlatformController::~PlatformController() {
    // do not listen to platformManager_ signals when going to destroy it
    disconnect(&platformManager_, nullptr, this, nullptr);
}

void PlatformController::initialize() {
    platformManager_.addScanner(strata::device::Device::Type::SerialDevice);
}

void PlatformController::sendMessage(const QByteArray& deviceId, const QByteArray& message) {
    auto it = platforms_.constFind(deviceId);
    if (it == platforms_.constEnd()) {
        qCWarning(logCategoryHcsPlatform).noquote() << "Cannot send message, platform" << deviceId << "was not found.";
        return;
    }
    qCDebug(logCategoryHcsPlatform).noquote() << "Sending message to platform" << deviceId;
    unsigned msgNumber = it.value()->sendMessage(message);
    sentMessageNumbers_.insert(deviceId, msgNumber);
}

PlatformPtr PlatformController::getPlatform(const QByteArray& deviceId) const {
    auto it = platforms_.constFind(deviceId);
    if (it != platforms_.constEnd()) {
        return it.value();
    }
    return nullptr;
}

void PlatformController::newConnection(const QByteArray& deviceId, bool recognized) {
    if (recognized) {
        PlatformPtr platform = platformManager_.getPlatform(deviceId);
        if (platform == nullptr) {
            qCWarning(logCategoryHcsPlatform).noquote() << "Platform not found by its id" << deviceId;
            return;
        }

        connect(platform.get(), &Platform::messageReceived, this, &PlatformController::messageFromPlatform);
        connect(platform.get(), &Platform::messageSent, this, &PlatformController::messageToPlatform);
        platforms_.insert(deviceId, platform);

        qCInfo(logCategoryHcsPlatform).noquote() << "Connected new platform" << deviceId;

        emit platformConnected(deviceId);
    } else {
        qCWarning(logCategoryHcsPlatform).noquote() << "Connected unknown (unrecognized) platform" << deviceId;
        // Remove platform if it was previously connected.
        if (platforms_.contains(deviceId)) {
            platforms_.remove(deviceId);
            sentMessageNumbers_.remove(deviceId);
            emit platformDisconnected(deviceId);
        }
    }
}

void PlatformController::closeConnection(const QByteArray& deviceId)
{
    if (platforms_.contains(deviceId) == false) {
        // This situation can occur if unrecognized platform is disconnected.
        qCInfo(logCategoryHcsPlatform).noquote() << "Disconnected unknown platform" << deviceId;
        return;
    }

    platforms_.remove(deviceId);
    sentMessageNumbers_.remove(deviceId);

    qCInfo(logCategoryHcsPlatform).noquote() << "Disconnected platform" << deviceId;

    emit platformDisconnected(deviceId);
}

void PlatformController::messageFromPlatform(PlatformMessage message)
{
    Platform *platform = qobject_cast<Platform*>(QObject::sender());
    if (platform == nullptr) {
        return;
    }

    const QByteArray deviceId = platform->deviceId();

    QJsonObject payload {
        { JSON_MESSAGE, QString(message.raw()) },
        { JSON_DEVICE_ID, QLatin1String(deviceId) }
    };

    qCDebug(logCategoryHcsPlatform).noquote() << "New platform message from device" << deviceId;

    emit platformMessage(platform->platformId(), payload);
}

void PlatformController::messageToPlatform(QByteArray rawMessage, unsigned msgNumber, QString errorString)
{
    if (errorString.isEmpty()) {
        // message was sent successfully
        return;
    }

    Platform *platform = qobject_cast<Platform*>(QObject::sender());
    if (platform == nullptr) {
        return;
    }

    auto iter = sentMessageNumbers_.constFind(platform->deviceId());
    if ((iter != sentMessageNumbers_.constEnd()) && (iter.value() == msgNumber)) {
        qCWarning(logCategoryHcsPlatform) << platform << "Cannot send message: '"
            << rawMessage << "', error: '" << errorString << '\'';
    }
}

QJsonObject PlatformController::createPlatformsList() {
    QJsonArray arr;
    for (auto it = platforms_.constBegin(); it != platforms_.constEnd(); ++it) {
        Platform::ControllerType controllerType = it.value()->controllerType();
        QJsonObject item {
            { JSON_DEVICE_ID, QLatin1String(it.value()->deviceId()) },
            { JSON_CONTROLLER_TYPE, static_cast<int>(controllerType) },
            { JSON_FW_VERSION, it.value()->applicationVer() },
            { JSON_BL_VERSION, it.value()->bootloaderVer() }
        };
        if (it.value()->hasClassId()) {
            item.insert(JSON_CLASS_ID, it.value()->classId());
        }
        if (controllerType == Platform::ControllerType::Assisted) {
            item.insert(JSON_CONTROLLER_CLASS_ID, it.value()->controllerClassId());
            item.insert(JSON_FW_CLASS_ID, it.value()->firmwareClassId());
        }
        arr.append(item);
    }

    return QJsonObject{{JSON_LIST, arr}};
}
