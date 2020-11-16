#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

#include "BoardController.h"
#include "Dispatcher.h"
#include "logging/LoggingQtCategories.h"
#include "JsonStrings.h"

using strata::BoardManager;
using strata::device::Device;
using strata::device::DevicePtr;
using strata::device::StringProperties;
using strata::device::EnumProperties;

BoardController::BoardController() {
    connect(&boardManager_, &BoardManager::boardReady, this, &BoardController::newConnection);
    connect(&boardManager_, &BoardManager::boardDisconnected, this, &BoardController::closeConnection);
}

void BoardController::initialize() {
    boardManager_.init(false);
}

bool BoardController::sendMessage(const int deviceId, const QByteArray& message) {
    auto it = boards_.constFind(deviceId);
    if (it == boards_.constEnd()) {
        qCWarning(logCategoryHcsBoard).noquote() << "Cannot send message, board was not found." << logDeviceId(deviceId);
        return false;
    }
    qCDebug(logCategoryHcsBoard).noquote() << "Sending message to board." << logDeviceId(deviceId);
    return it.value().device->sendMessage(message);
}

DevicePtr BoardController::getDevice(const int deviceId) const {
    auto it = boards_.constFind(deviceId);
    if (it != boards_.constEnd()) {
        return it.value().device;
    }
    return nullptr;
}

void BoardController::newConnection(int deviceId, bool recognized) {
    if (recognized) {
        DevicePtr device = boardManager_.device(deviceId);
        if (device == nullptr) {
            return;
        }

        connect(device.get(), &Device::msgFromDevice, this, &BoardController::messageFromBoard);
        boards_.insert(deviceId, Board(device));

        QString classId = device->stringProperty(StringProperties::ClassId);

        qCInfo(logCategoryHcsBoard).noquote() << "Connected new board." << logDeviceId(deviceId);

        emit boardConnected(deviceId, classId);
    } else {
        qCWarning(logCategoryHcsBoard).noquote() << "Connected unknown (unrecognized) board." << logDeviceId(deviceId);
    }
}

void BoardController::closeConnection(int deviceId)
{
    auto it = boards_.constFind(deviceId);
    if (it == boards_.constEnd()) {
        // This situation can occur if unrecognized board is disconnected.
        qCInfo(logCategoryHcsBoard).noquote() << "Disconnected unknown board." << logDeviceId(deviceId);
        return;
    }

    boards_.remove(deviceId);

    qCInfo(logCategoryHcsBoard).noquote() << "Disconnected board." << logDeviceId(deviceId);

    emit boardDisconnected(deviceId);
}

void BoardController::messageFromBoard(QString message)
{
    Device *device = qobject_cast<Device*>(QObject::sender());
    if (device == nullptr) {
        return;
    }

    int deviceId = device->deviceId();
    QJsonObject wrapper {
        { JSON_MESSAGE, message },
        { JSON_DEVICE_ID, deviceId }
    };

    QJsonObject notification {
        { JSON_NOTIFICATION, wrapper }
    };
    QJsonDocument wrapperDoc(notification);
    QString wrapperStrJson(wrapperDoc.toJson(QJsonDocument::Compact));

    QString platformId = device->stringProperty(StringProperties::PlatformId);

    qCDebug(logCategoryHcsBoard).noquote() << "New board message." << logDeviceId(deviceId);

    emit boardMessage(platformId, wrapperStrJson);
}

QString BoardController::createPlatformsList() {
    QJsonArray arr;
    for (auto it = boards_.constBegin(); it != boards_.constEnd(); ++it) {
        // std::get for std::variant is available from macOS 10.14, so std::get_if must be used
        auto enumProperty = it.value().device->enumProperty(EnumProperties::ControllerType);
        Device::ControllerType controllerType = Device::ControllerType::Embedded;
        if (Device::ControllerType* type = std::get_if<Device::ControllerType>(&enumProperty)) {
            controllerType = *type;
        }
        QJsonObject item {
            { JSON_CLASS_ID, it.value().device->stringProperty(StringProperties::ClassId) },
            { JSON_DEVICE_ID, it.value().device->deviceId() },
            { JSON_CONTROLLER_TYPE, static_cast<int>(controllerType) },
            { JSON_FW_VERSION, it.value().device->stringProperty(StringProperties::ApplicationVer) },
            { JSON_BL_VERSION, it.value().device->stringProperty(StringProperties::BootloaderVer) }
        };
        if (controllerType == Device::ControllerType::Assisted) {
            item.insert(JSON_CONTROLLER_CLASS_ID, it.value().device->stringProperty(StringProperties::ControllerClassId));
            item.insert(JSON_FW_CLASS_ID, it.value().device->stringProperty(StringProperties::FirmwareClassId));
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

QString BoardController::logDeviceId(const int deviceId) const {
    return "Device Id: 0x" + QString::number(static_cast<uint>(deviceId), 16);
}

BoardController::Board::Board(const DevicePtr& devPtr) : device(devPtr) { }
