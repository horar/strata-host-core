#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QLatin1String>

#include "BoardController.h"
#include "Dispatcher.h"
#include "logging/LoggingQtCategories.h"
#include "JsonStrings.h"

using strata::PlatformManager;
using strata::platform::Platform;
using strata::platform::PlatformPtr;

BoardController::BoardController(): platformManager_(false, false, true) {
    connect(&platformManager_, &PlatformManager::platformRecognized, this, &BoardController::newConnection);
    connect(&platformManager_, &PlatformManager::platformAboutToClose, this, &BoardController::closeConnection);
}

void BoardController::initialize() {
    platformManager_.init(strata::device::Device::Type::SerialDevice);
}

bool BoardController::sendMessage(const QByteArray& deviceId, const QByteArray& message) {
    auto it = boards_.constFind(deviceId);
    if (it == boards_.constEnd()) {
        qCWarning(logCategoryHcsBoard).noquote() << "Cannot send message, board" << deviceId << "was not found.";
        return false;
    }
    qCDebug(logCategoryHcsBoard).noquote() << "Sending message to board" << deviceId;
    return it.value().platform_->sendMessage(message);
}

PlatformPtr BoardController::getPlatform(const QByteArray& deviceId) const {
    auto it = boards_.constFind(deviceId);
    if (it != boards_.constEnd()) {
        return it.value().platform_;
    }
    return nullptr;
}

void BoardController::newConnection(const QByteArray& deviceId, bool recognized) {
    if (recognized) {
        PlatformPtr platform = platformManager_.getPlatform(deviceId);
        if (platform == nullptr) {
            return;
        }

        connect(platform.get(), &Platform::messageReceived, this, &BoardController::messageFromBoard);
        boards_.insert(deviceId, Board(platform));

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

void BoardController::messageFromBoard(QByteArray deviceId, QString message)
{
    PlatformPtr platform = platformManager_.getPlatform(deviceId);
    if (platform == nullptr) {
        return;
    }

    QJsonObject wrapper {
        { JSON_MESSAGE, message },
        { JSON_DEVICE_ID, QLatin1String(deviceId) }
    };

    QJsonObject notification {
        { JSON_NOTIFICATION, wrapper }
    };
    QJsonDocument wrapperDoc(notification);
    QString wrapperStrJson(wrapperDoc.toJson(QJsonDocument::Compact));

    QString platformId = platform->platformId();

    qCDebug(logCategoryHcsBoard).noquote() << "New board message from device" << deviceId;

    emit boardMessage(platformId, wrapperStrJson);
}

QString BoardController::createPlatformsList() {
    QJsonArray arr;
    for (auto it = boards_.constBegin(); it != boards_.constEnd(); ++it) {
        Platform::ControllerType controllerType = it.value().platform_->controllerType();
        QJsonObject item {
            { JSON_DEVICE_ID, QLatin1String(it.value().platform_->deviceId()) },
            { JSON_CONTROLLER_TYPE, static_cast<int>(controllerType) },
            { JSON_FW_VERSION, it.value().platform_->applicationVer() },
            { JSON_BL_VERSION, it.value().platform_->bootloaderVer() }
        };
        if (it.value().platform_->hasClassId()) {
            item.insert(JSON_CLASS_ID, it.value().platform_->classId());
        }
        if (controllerType == Platform::ControllerType::Assisted) {
            item.insert(JSON_CONTROLLER_CLASS_ID, it.value().platform_->controllerClassId());
            item.insert(JSON_FW_CLASS_ID, it.value().platform_->firmwareClassId());
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

BoardController::Board::Board(const PlatformPtr& platform) : platform_(platform) { }
