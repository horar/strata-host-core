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

#include <Operations/StartApplication.h>

#include <rapidjson/pointer.h>

#include <cstring>

using strata::PlatformManager;
using strata::platform::Platform;
using strata::platform::PlatformPtr;
using strata::platform::PlatformMessage;

namespace operation = strata::platform::operation;

PlatformController::PlatformController()
    : platformManager_(false, false, true),
      platformOperations_(true, true)
{
    connect(&platformManager_, &PlatformManager::platformRecognized, this, &PlatformController::newConnection);
    connect(&platformManager_, &PlatformManager::platformAboutToClose, this, &PlatformController::closeConnection);

    connect(&platformOperations_, &operation::PlatformOperations::finished, this, &PlatformController::operationFinished);
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
        qCWarning(lcHcsPlatform).noquote() << "Cannot send message, platform" << deviceId << "was not found.";
        return;
    }
    qCDebug(lcHcsPlatform).noquote() << "Sending message to platform" << deviceId;
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
        it.value().startAppFailed = false;
    }
}

void PlatformController::applicationActive(QByteArray deviceId)
{
    auto it = platforms_.find(deviceId);
    if (it != platforms_.end()) {
        it.value().inBootloader = false;
        it.value().startAppFailed = false;
    }
}

void PlatformController::newConnection(const QByteArray& deviceId, bool recognized, bool inBootloader) {
    if (recognized) {
        PlatformPtr platform = platformManager_.getPlatform(deviceId);
        if (platform == nullptr) {
            qCWarning(lcHcsPlatform).noquote() << "Platform not found by its id" << deviceId;
            return;
        }

        connect(platform.get(), &Platform::messageReceived, this, &PlatformController::messageFromPlatform);
        connect(platform.get(), &Platform::messageSent, this, &PlatformController::messageToPlatform);
        platforms_.insert(deviceId, PlatformData(platform, inBootloader));

        qCInfo(lcHcsPlatform).noquote() << "Connected new platform" << deviceId;

        emit platformConnected(deviceId);
    } else {
        qCWarning(lcHcsPlatform).noquote() << "Connected unknown (unrecognized) platform" << deviceId;
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
        qCInfo(lcHcsPlatform).noquote() << "Disconnected unknown platform" << deviceId;
        return;
    }

    platforms_.erase(it);

    qCInfo(lcHcsPlatform).noquote() << "Disconnected platform" << deviceId;

    emit platformDisconnected(deviceId);
}

void PlatformController::messageFromPlatform(PlatformMessage message)
{
    Platform *platform = qobject_cast<Platform*>(QObject::sender());
    if (platform == nullptr) {
        return;
    }

    // do not send 'backup_firmware' and 'flash_firmware' ACKs and notifications to clients
    if (message.isJsonValidObject()) {
        const rapidjson::Value *jsonValue = rapidjson::GetValueByPointer(message.json(), "/notification/value");
        if (jsonValue == nullptr) {
            jsonValue = rapidjson::GetValueByPointer(message.json(), "/ack");
        }

        if ((jsonValue != nullptr) && jsonValue->IsString()) {
            const char *str = jsonValue->GetString();
            if (str != nullptr) {
                if ((std::strcmp("flash_firmware", str) == 0) || (std::strcmp("backup_firmware", str) == 0)) {
                    return;
                }
            }
        }
    }

    const QByteArray deviceId = platform->deviceId();

    QJsonObject payload {
        { JSON_MESSAGE, QString(message.raw()) },
        { JSON_DEVICE_ID, QLatin1String(deviceId) }
    };

    qCDebug(lcHcsPlatform).noquote() << "New platform message from device" << deviceId;

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
        qCWarning(lcHcsPlatform) << platform << "Cannot send message: '"
            << rawMessage << "', error: '" << errorString << '\'';
    }
}

void PlatformController::operationFinished(QByteArray deviceId,
                       operation::Type type,
                       operation::Result result,
                       int status,
                       QString errorString)
{
    Q_UNUSED(status)

    if (type != operation::Type::StartApplication) {
        return;
    }

    auto it = platforms_.find(deviceId);
    if (it == platforms_.end()) {
        return;
    }

    if (result == operation::Result::Success) {
        it->startAppFailed = false;
        it->inBootloader = false;
        qCDebug(lcHcsPlatform).noquote() << "Platform application was started for device" << deviceId;
        emit platformApplicationStarted(deviceId);
    } else {
        it->startAppFailed = true;
        qCWarning(lcHcsPlatform).noquote()
            << "Cannot start platform application for device" << deviceId << '-' << errorString;
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

bool PlatformController::platformStartApplication(const QByteArray& deviceId)
{
    auto it = platforms_.constFind(deviceId);
    if (it == platforms_.constEnd()) {
        return false;
    }
    if (it->startAppFailed) {
        qCWarning(lcHcsPlatform).noquote()
            << "Previous attempt to start application for device" << deviceId
            << "has failed. To prevent infinite looping, current attempt will be ignored.";
        return false;
    }
    if (platformOperations_.StartApplication(it->platform) == nullptr) {
        qCWarning(lcHcsPlatform).noquote()
            << "Another start application request for device" << deviceId << "is already running.";
        return false;
    }

    return true;
}

PlatformController::PlatformData::PlatformData(PlatformPtr p, bool b)
    : platform(p),
      inBootloader(b),
      startAppFailed(false),
      sentMessageNumber(0)
{ }
