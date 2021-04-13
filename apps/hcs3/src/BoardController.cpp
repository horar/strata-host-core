#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QLatin1String>

#include "BoardController.h"
#include "Dispatcher.h"
#include "logging/LoggingQtCategories.h"
#include "JsonStrings.h"

using strata::BoardManager;
using strata::device::Device;
using strata::device::DevicePtr;

BoardController::BoardController() {
    connect(&boardManager_, &BoardManager::boardInfoChanged, this, &BoardController::newConnection);
    connect(&boardManager_, &BoardManager::boardDisconnected, this, &BoardController::closeConnection);
}

void BoardController::initialize() {
    boardManager_.init(false, false);
}

bool BoardController::sendMessage(const QByteArray& deviceId, const QByteArray& message) {
    auto it = boards_.constFind(deviceId);
    if (it == boards_.constEnd()) {
        qCWarning(logCategoryHcsBoard).noquote() << "Cannot send message, board" << deviceId << "was not found.";
        return false;
    }
    qCDebug(logCategoryHcsBoard).noquote() << "Sending message to board" << deviceId;
    return it.value().device->sendMessage(message);
}

DevicePtr BoardController::getDevice(const QByteArray& deviceId) const {
    auto it = boards_.constFind(deviceId);
    if (it != boards_.constEnd()) {
        return it.value().device;
    }
    return nullptr;
}

void BoardController::newConnection(const QByteArray& deviceId, bool recognized) {
    if (recognized) {
        DevicePtr device = boardManager_.device(deviceId);
        if (device == nullptr) {
            return;
        }

        connect(device.get(), &Device::msgFromDevice, this, &BoardController::messageFromBoard);
        boards_.insert(deviceId, Board(device));

        qCInfo(logCategoryHcsBoard).noquote() << "Connected new board" << deviceId;

        emit boardConnected(deviceId);
    } else {
        qCWarning(logCategoryHcsBoard).noquote() << "Connected unknown (unrecognized) board" << deviceId;
        // Remove board if it was previously connected.
        if (boards_.contains(deviceId)) {
            boards_.remove(deviceId);
            emit boardDisconnected(deviceId);
        }
    }
}

void BoardController::closeConnection(const QByteArray& deviceId)
{
    if (boards_.contains(deviceId) == false) {
        // This situation can occur if unrecognized board is disconnected.
        qCInfo(logCategoryHcsBoard).noquote() << "Disconnected unknown board" << deviceId;
        return;
    }

    boards_.remove(deviceId);

    qCInfo(logCategoryHcsBoard).noquote() << "Disconnected board" << deviceId;

    emit boardDisconnected(deviceId);
}

void BoardController::messageFromBoard(QString message)
{
    Device *device = qobject_cast<Device*>(QObject::sender());
    if (device == nullptr) {
        return;
    }

    const QByteArray deviceId = device->deviceId();
    QJsonObject wrapper {
        { JSON_MESSAGE, message },
        { JSON_DEVICE_ID, QLatin1String(deviceId) }
    };

    QJsonObject notification {
        { JSON_NOTIFICATION, wrapper }
    };
    QJsonDocument wrapperDoc(notification);
    QString wrapperStrJson(wrapperDoc.toJson(QJsonDocument::Compact));

    QString platformId = device->platformId();

    qCDebug(logCategoryHcsBoard).noquote() << "New board message from device" << deviceId;

    emit boardMessage(platformId, wrapperStrJson);
}

QJsonArray BoardController::createPlatformsList() {
    QJsonArray list;
    for (auto it = boards_.constBegin(); it != boards_.constEnd(); ++it) {
        Device::ControllerType controllerType = it.value().device->controllerType();
        QJsonObject item {
            { JSON_DEVICE_ID, QLatin1String(it.value().device->deviceId()) },
            { JSON_CONTROLLER_TYPE, static_cast<int>(controllerType) },
            { JSON_FW_VERSION, it.value().device->applicationVer() },
            { JSON_BL_VERSION, it.value().device->bootloaderVer() }
        };
        if (it.value().device->hasClassId()) {
            item.insert(JSON_CLASS_ID, it.value().device->classId());
        }
        if (controllerType == Device::ControllerType::Assisted) {
            item.insert(JSON_CONTROLLER_CLASS_ID, it.value().device->controllerClassId());
            item.insert(JSON_FW_CLASS_ID, it.value().device->firmwareClassId());
        }
        list.append(item);
    }

    return list;
}

BoardController::Board::Board(const DevicePtr& devPtr) : device(devPtr) { }
