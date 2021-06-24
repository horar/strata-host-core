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
using strata::device::scanner::BluetoothLowEnergyScanner;

PlatformController::PlatformController(): platformManager_(false, false, true) {
    connect(&platformManager_, &PlatformManager::platformRecognized, this, &PlatformController::newConnection);
    connect(&platformManager_, &PlatformManager::platformAboutToClose, this, &PlatformController::closeConnection);
}

void PlatformController::initialize() {
    platformManager_.init(strata::device::Device::Type::SerialDevice);
    platformManager_.init(strata::device::Device::Type::BLEDevice);

    strata::device::scanner::BluetoothLowEnergyScannerPtr bleDeviceScanner = std::static_pointer_cast<BluetoothLowEnergyScanner>(
        platformManager_.getScanner(strata::device::Device::Type::BLEDevice));
    if (bleDeviceScanner != nullptr) {
        connect(bleDeviceScanner.get(), &BluetoothLowEnergyScanner::discoveryFinished, this, &PlatformController::bleDiscoveryFinishedHandler);
    }
}

bool PlatformController::sendMessage(const QByteArray& deviceId, const QByteArray& message) {
    auto it = platforms_.constFind(deviceId);
    if (it == platforms_.constEnd()) {
        qCWarning(logCategoryHcsPlatform).noquote() << "Cannot send message, platform" << deviceId << "was not found.";
        return false;
    }
    qCDebug(logCategoryHcsPlatform).noquote() << "Sending message to platform" << deviceId;
    return it.value()->sendMessage(message);
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
            return;
        }

        connect(platform.get(), &Platform::messageReceived, this, &PlatformController::messageFromPlatform);
        platforms_.insert(deviceId, platform);

        qCInfo(logCategoryHcsPlatform).noquote() << "Connected new platform" << deviceId;

        emit platformConnected(deviceId);
    } else {
        qCWarning(logCategoryHcsPlatform).noquote() << "Connected unknown (unrecognized) platform" << deviceId;
        // Remove platform if it was previously connected.
        if (platforms_.contains(deviceId)) {
            platforms_.remove(deviceId);
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

    QJsonObject wrapper {
        { JSON_MESSAGE, QString(message.raw()) },
        { JSON_DEVICE_ID, QLatin1String(deviceId) }
    };

    QJsonObject notification {
        { JSON_NOTIFICATION, wrapper }
    };
    QJsonDocument wrapperDoc(notification);
    QString wrapperStrJson(wrapperDoc.toJson(QJsonDocument::Compact));

    qCDebug(logCategoryHcsPlatform).noquote() << "New platform message from device" << deviceId;

    emit platformMessage(platform->platformId(), wrapperStrJson);
}

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

QJsonObject PlatformController::createBluetoothScanPayload(const std::shared_ptr<const BluetoothLowEnergyScanner> bleDeviceScanner) {
    QJsonArray payloadList;
    const auto discoveredDevices = bleDeviceScanner->discoveredDevices();
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

QString PlatformController::createPlatformsList() {
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
    QJsonObject notif {
        { JSON_LIST, arr },
        { JSON_TYPE, JSON_CONNECTED_PLATFORMS }
    };
    QJsonObject msg {
        { JSON_HCS_NOTIFICATION, notif }
    };
    QJsonDocument doc(msg);

    return doc.toJson(QJsonDocument::Compact);
}
