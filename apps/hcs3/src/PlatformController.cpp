/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QLatin1String>

#include "PlatformController.h"
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
    auto it = platforms_.find(deviceId);
    if (it == platforms_.end()) {
        qCWarning(logCategoryHcsPlatform).noquote() << "Cannot send message, platform" << deviceId << "was not found.";
        return;
    }
    qCDebug(logCategoryHcsPlatform).noquote() << "Sending message to platform" << deviceId;
    it.value().sentMessageNumber = it.value().platform->sendMessage(message);
}

PlatformPtr PlatformController::getPlatform(const QByteArray& deviceId) const {
    auto it = platforms_.constFind(deviceId);
    if (it != platforms_.constEnd()) {
        return it.value().platform;
    }
    return nullptr;
}

void PlatformController::bootloaderActive(QByteArray deviceId)
{
    auto it = platforms_.find(deviceId);
    if (it != platforms_.end()) {
        it.value().inBootloader = true;
    }
}

void PlatformController::applicationActive(QByteArray deviceId)
{
    auto it = platforms_.find(deviceId);
    if (it != platforms_.end()) {
        it.value().inBootloader = false;
    }
}

void PlatformController::newConnection(const QByteArray& deviceId, bool recognized, bool inBootloader) {
    if (recognized) {
        PlatformPtr platform = platformManager_.getPlatform(deviceId);
        if (platform == nullptr) {
            qCWarning(logCategoryHcsPlatform).noquote() << "Platform not found by its id" << deviceId;
            return;
        }

        connect(platform.get(), &Platform::messageReceived, this, &PlatformController::messageFromPlatform);
        connect(platform.get(), &Platform::messageSent, this, &PlatformController::messageToPlatform);
        platforms_.insert(deviceId, PlatformData(platform, inBootloader));

        qCInfo(logCategoryHcsPlatform).noquote() << "Connected new platform" << deviceId;

        emit platformConnected(deviceId);
    } else {
        qCWarning(logCategoryHcsPlatform).noquote() << "Connected unknown (unrecognized) platform" << deviceId;
        // Remove platform if it was previously connected.
        auto it = platforms_.find(deviceId);
        if (it != platforms_.end()) {
            platforms_.erase(it);
            emit platformDisconnected(deviceId);
        }
    }
}

void PlatformController::closeConnection(const QByteArray& deviceId)
{
    auto it = platforms_.find(deviceId);
    if (it == platforms_.end()) {
        // This situation can occur if unrecognized platform is disconnected.
        qCInfo(logCategoryHcsPlatform).noquote() << "Disconnected unknown platform" << deviceId;
        return;
    }

    platforms_.erase(it);

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

    auto it = platforms_.constFind(platform->deviceId());
    if ((it != platforms_.constEnd()) && (it.value().sentMessageNumber == msgNumber)) {
        qCWarning(logCategoryHcsPlatform) << platform << "Cannot send message: '"
            << rawMessage << "', error: '" << errorString << '\'';
    }
}

QJsonObject PlatformController::createPlatformsList() {
    QJsonArray arr;
    for (auto it = platforms_.constBegin(); it != platforms_.constEnd(); ++it) {
        const PlatformPtr& platform = it.value().platform;
        Platform::ControllerType controllerType = platform->controllerType();
        QJsonObject item {
            { JSON_DEVICE_ID, QLatin1String(platform->deviceId()) },
            { JSON_CONTROLLER_TYPE, static_cast<int>(controllerType) },
            { JSON_FW_VERSION, platform->applicationVer() },
            { JSON_BL_VERSION, platform->bootloaderVer() },
            { JSON_ACTIVE, (it.value().inBootloader == true)
                           ? QLatin1String("bootloader")
                           : QLatin1String("application")}
        };
        if (platform->hasClassId()) {
            item.insert(JSON_CLASS_ID, platform->classId());
        }
        if (platform->name().isNull() == false) {
            item.insert(JSON_VERBOSE_NAME, platform->name());
        }

        if (controllerType == Platform::ControllerType::Assisted) {
            item.insert(JSON_CONTROLLER_CLASS_ID, platform->controllerClassId());
            item.insert(JSON_FW_CLASS_ID, platform->firmwareClassId());
        }
        arr.append(item);
    }

    return QJsonObject{{JSON_LIST, arr}};
}

PlatformController::PlatformData::PlatformData(PlatformPtr p, bool b)
    : platform(p), inBootloader(b), sentMessageNumber(0)
{ }
