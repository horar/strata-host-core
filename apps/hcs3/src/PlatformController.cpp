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
using strata::device::scanner::DeviceScanner;
using strata::device::scanner::DeviceScannerPtr;
#ifdef APPS_FEATURE_BLE
using strata::device::scanner::BluetoothLowEnergyScanner;
#endif // APPS_FEATURE_BLE

namespace operation = strata::platform::operation;

PlatformController::PlatformController()
    : platformManager_(false, false, true),
      platformOperations_(true, true)
{
    connect(&platformManager_, &PlatformManager::platformRecognized, this, &PlatformController::newConnection);
    connect(&platformManager_, &PlatformManager::platformAboutToClose, this, &PlatformController::closeConnection);
    connect(&platformManager_, &PlatformManager::platformRemoved, this, &PlatformController::removeConnection);

    connect(&platformOperations_, &operation::PlatformOperations::finished, this, &PlatformController::operationFinished);
}

PlatformController::~PlatformController() {
    // do not listen to platformManager_ signals when going to destroy it
    disconnect(&platformManager_, nullptr, this, nullptr);
}

void PlatformController::initialize() {
    platformManager_.addScanner(strata::device::Device::Type::SerialDevice);

#ifdef APPS_FEATURE_BLE
    platformManager_.addScanner(strata::device::Device::Type::BLEDevice);

    strata::device::scanner::BluetoothLowEnergyScannerPtr bleDeviceScanner = std::static_pointer_cast<BluetoothLowEnergyScanner>(
        platformManager_.getScanner(strata::device::Device::Type::BLEDevice));
    if (bleDeviceScanner != nullptr) {
        connect(bleDeviceScanner.get(), &BluetoothLowEnergyScanner::discoveryFinished, this, &PlatformController::bleDiscoveryFinishedHandler);
    }
#endif // APPS_FEATURE_BLE
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
            qCWarning(logCategoryHcsPlatform).noquote() << "Platform not found by its id" << deviceId;
            return;
        }

        connect(platform.get(), &Platform::messageReceived, this, &PlatformController::messageFromPlatform);
        connect(platform.get(), &Platform::messageSent, this, &PlatformController::messageToPlatform);
        platforms_.insert(deviceId, PlatformData(platform, inBootloader));

        qCInfo(logCategoryHcsPlatform).noquote() << "Connected new platform" << deviceId;

        emit platformConnected(deviceId);

        if (connectDeviceRequests_.contains(deviceId)) {
            QList<QByteArray> clients = connectDeviceRequests_.values(deviceId);
            connectDeviceRequests_.remove(deviceId);
            for (const auto &clientId : clients) {
                emit connectDeviceFinished(deviceId, clientId, QString());
            }
        }
    } else {
        // no need to handle it will be erased by PlatformManager in a few moments (keepDevicesOpen = false)
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

void PlatformController::removeConnection(const QByteArray& deviceId, const QString& errorString)
{
    if (connectDeviceRequests_.contains(deviceId)) {
        QList<QByteArray> clients = connectDeviceRequests_.values(deviceId);
        connectDeviceRequests_.remove(deviceId);
        for (const auto &clientId : clients) {
            emit connectDeviceFinished(deviceId, clientId, errorString);
        }
    }

    if (disconnectDeviceRequests_.contains(deviceId)) {
        QList<QByteArray> clients = disconnectDeviceRequests_.values(deviceId);
        disconnectDeviceRequests_.remove(deviceId);
        for (const auto &clientId : clients) {
            emit disconnectDeviceFinished(deviceId, clientId, errorString);
        }
    }
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

#ifdef APPS_FEATURE_BLE
void PlatformController::startBluetoothScan() {
    std::shared_ptr<BluetoothLowEnergyScanner> bleDeviceScanner = std::static_pointer_cast<BluetoothLowEnergyScanner>(
        platformManager_.getScanner(strata::device::Device::Type::BLEDevice));
    if (bleDeviceScanner != nullptr) {
        bleDeviceScanner->startDiscovery();
    } else {
        emit bluetoothScanFinished(createBluetoothScanErrorPayload("BluetoothLowEnergyScanner not initialized."));
    }
}

void PlatformController::bleDiscoveryFinishedHandler(strata::device::scanner::BluetoothLowEnergyScanner::DiscoveryFinishStatus status, QString errorString) {
    QJsonObject payload;
    switch (status) {
        case strata::device::scanner::BluetoothLowEnergyScanner::Finished:
        {
            std::shared_ptr<BluetoothLowEnergyScanner> bleDeviceScanner = std::static_pointer_cast<BluetoothLowEnergyScanner>(
                platformManager_.getScanner(strata::device::Device::Type::BLEDevice));
            if (bleDeviceScanner != nullptr) {
                payload = createBluetoothScanPayload(bleDeviceScanner);
            } else {
                payload = createBluetoothScanErrorPayload("BluetoothLowEnergyScanner not initialized.");
            }
            break;
        }
        case strata::device::scanner::BluetoothLowEnergyScanner::DiscoveryError:
            payload = createBluetoothScanErrorPayload(errorString);
            break;
        case strata::device::scanner::BluetoothLowEnergyScanner::Cancelled:
            payload = createBluetoothScanErrorPayload("Discovery cancelled.");
            break;
        default:
            payload = createBluetoothScanErrorPayload("Unknown discovery status.");
            qCWarning(logCategoryHcsPlatform).noquote() << "BLE discovery ended with unknown status" << status;
    }
    emit bluetoothScanFinished(payload);
}
#endif // APPS_FEATURE_BLE

void PlatformController::connectDevice(const QByteArray &deviceId, const QByteArray &clientId) {
    if (disconnectDeviceRequests_.contains(deviceId)) {
        emit connectDeviceFinished(deviceId, clientId, "Disconnect already in progress.");
        return;
    }
    DeviceScannerPtr deviceScanner = platformManager_.getScanner(DeviceScanner::scannerType(deviceId));
    if (deviceScanner != nullptr) {
        if (false == connectDeviceRequests_.contains(deviceId)) {
            QString errorMessage = deviceScanner->connectDevice(deviceId);
            if (false == errorMessage.isEmpty()) {
                emit connectDeviceFinished(deviceId, clientId, errorMessage);
            } else {
                // subscribe for the result
                connectDeviceRequests_.insert(deviceId, clientId);
            }
        } else {
            // device already being connected, just subscribe for the result
            connectDeviceRequests_.insert(deviceId, clientId);
        }
    } else {
        emit connectDeviceFinished(deviceId, clientId, "Scanner not initialized.");
    }
}

void PlatformController::disconnectDevice(const QByteArray &deviceId, const QByteArray &clientId) {
    if (connectDeviceRequests_.contains(deviceId)) {
        QList<QByteArray> clients = connectDeviceRequests_.values(deviceId);
        connectDeviceRequests_.remove(deviceId);
        for (const auto &client : clients) {
            emit connectDeviceFinished(deviceId, client, "Cancelled.");
        }
    }

    DeviceScannerPtr deviceScanner = platformManager_.getScanner(DeviceScanner::scannerType(deviceId));
    if (deviceScanner != nullptr) {
        if (false == disconnectDeviceRequests_.contains(deviceId)) {
            QString errorMessage = deviceScanner->disconnectDevice(deviceId);
            if (false == errorMessage.isEmpty()) {
                emit disconnectDeviceFinished(deviceId, clientId, errorMessage);
            } else {
                // subscribe for the result
                disconnectDeviceRequests_.insert(deviceId, clientId);
            }
        } else {
            // device already being connected, just subscribe for the result
            disconnectDeviceRequests_.insert(deviceId, clientId);
        }
    } else {
        emit disconnectDeviceFinished(deviceId, clientId, "Scanner not initialized.");
    }
}

#ifdef APPS_FEATURE_BLE
QJsonObject PlatformController::createBluetoothScanPayload(const std::shared_ptr<const BluetoothLowEnergyScanner> bleDeviceScanner) {
    QJsonArray payloadList;
    const auto discoveredDevices = bleDeviceScanner->discoveredBleDevices();
    for (const auto &device : discoveredDevices) {
        QJsonArray manufacturerIdList;
        for (const auto id : device.manufacturerIds) {
            manufacturerIdList.append(id);
        }
        QJsonObject item {
            { JSON_BLE_DEVICE_ID, QLatin1String(device.deviceId) },
            { JSON_BLE_NAME, device.name },
            { JSON_BLE_ADDRESS, device.address },
            { JSON_BLE_RSSI, device.rssi },
            { JSON_BLE_IS_STRATA, device.isStrata },
            { JSON_BLE_MANUFACTURER_IDS, manufacturerIdList }
        };
        payloadList.append(item);
    }

    QJsonObject payload {
        { JSON_LIST, payloadList }
    };

    return payload;
}

QJsonObject PlatformController::createBluetoothScanErrorPayload(QString errorString) {
    QJsonObject payload {
        { JSON_ERROR_STRING, errorString }
    };

    return payload;
}
#endif // APPS_FEATURE_BLE

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
        qCDebug(logCategoryHcsPlatform).noquote() << "Platform application was started for device" << deviceId;
        emit platformApplicationStarted(deviceId);
    } else {
        it->startAppFailed = true;
        qCWarning(logCategoryHcsPlatform).noquote()
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
        qCWarning(logCategoryHcsPlatform).noquote()
            << "Previous attempt to start application for device" << deviceId
            << "has failed. To prevent infinite looping, current attempt will be ignored.";
        return false;
    }
    if (platformOperations_.StartApplication(it->platform) == nullptr) {
        qCWarning(logCategoryHcsPlatform).noquote()
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
