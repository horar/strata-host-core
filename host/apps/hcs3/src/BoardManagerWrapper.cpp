#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

#include "BoardManagerWrapper.h"
#include "Dispatcher.h"
#include "logging/LoggingQtCategories.h"
#include "JsonStrings.h"

BoardManagerWrapper::BoardManagerWrapper() {
    connect(&boardManager_, &strata::BoardManager::boardReady, this, &BoardManagerWrapper::newConnection);
    connect(&boardManager_, &strata::BoardManager::boardDisconnected, this, &BoardManagerWrapper::closeConnection);
}

void BoardManagerWrapper::initialize(HCS_Dispatcher* dispatcher) {
    dispatcher_ = dispatcher;
    boardManager_.init(false);
}

void BoardManagerWrapper::sendMessage(const int deviceId, const std::string& message) {
    auto const it = boards_.find(deviceId);
    if (it == boards_.end()) {
        qCWarning(logCategoryHcsBoard).noquote() << "Cannot send message, board was not found." << logDeviceId(deviceId);
        return;
    }
    qCDebug(logCategoryHcsBoard).noquote() << "Sending message to board." << logDeviceId(deviceId);
    it->second.device->sendMessage(QByteArray::fromStdString(message));
}

void BoardManagerWrapper::newConnection(int deviceId, bool recognized) {
    if (recognized) {
        strata::SerialDeviceShPtr device = boardManager_.getDevice(deviceId);
        if (device == nullptr) {
            return;
        }
        connect(device.get(), &strata::SerialDevice::msgFromDevice, this, &BoardManagerWrapper::messageFromBoard);
        boards_.emplace(deviceId, Board(device));
        PlatformMessage item;
        item.msg_type = PlatformMessage::eMsgPlatformConnected;
        item.from_connectionId.conn_id = deviceId;
        item.from_connectionId.is_set = true;
        item.msg_document = nullptr;

        dispatcher_->addMessage(item);

        qCInfo(logCategoryHcsBoard).noquote() << "Connected new board." << logDeviceId(deviceId);
    }
    else {
        qCWarning(logCategoryHcsBoard).noquote() << "Connected unknown (unrecognized) board." << logDeviceId(deviceId);
    }
}

void BoardManagerWrapper::closeConnection(int deviceId) {
    auto const it = boards_.find(deviceId);
    if (it == boards_.end()) {
        // This situation can occur if unrecognized board is disconnected.
        qCInfo(logCategoryHcsBoard).noquote() << "Disconnected unknown board." << logDeviceId(deviceId);
        return;
    }

    QJsonObject msg {
        { JSON_PLATFORM_ID, it->second.device->getProperty(strata::DeviceProperties::platformId) },
        { JSON_CLASS_ID, it->second.device->getProperty(strata::DeviceProperties::classId) }
    };
    QJsonDocument doc(msg);

    boards_.erase(deviceId);

    PlatformMessage item;
    item.msg_type = PlatformMessage::eMsgPlatformDisconnected;
    item.from_connectionId.conn_id = deviceId;
    item.from_connectionId.is_set = true;
    item.message = doc.toJson(QJsonDocument::Compact).toStdString();
    item.msg_document = nullptr;

    dispatcher_->addMessage(item);

    qCInfo(logCategoryHcsBoard).noquote() << "Disconnected board." << logDeviceId(deviceId);
}

void BoardManagerWrapper::messageFromBoard(QString message) {
    strata::SerialDevice *device = qobject_cast<strata::SerialDevice*>(QObject::sender());
    if (device == nullptr) {
        return;
    }
    int deviceId = device->getDeviceId();
    PlatformMessage item;
    item.msg_type = PlatformMessage::eMsgPlatformMessage;
    item.from_connectionId.conn_id = deviceId;
    item.from_connectionId.is_set = true;
    item.message = message.toStdString();
    item.msg_document = nullptr;

    dispatcher_->addMessage(item);

    qCDebug(logCategoryHcsBoard).noquote() << "New board message." << logDeviceId(deviceId);
}

void BoardManagerWrapper::createPlatformsList(std::string& result) {
    QJsonArray arr;
    for (auto const& it : boards_) {
        QJsonObject item {
            { JSON_VERBOSE_NAME, it.second.device->getProperty(strata::DeviceProperties::verboseName) },
            { JSON_CLASS_ID, it.second.device->getProperty(strata::DeviceProperties::classId) },
            { JSON_CONNECTION, JSON_CONNECTED }
        };
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

    result = doc.toJson(QJsonDocument::Compact).toStdString();
}

std::string BoardManagerWrapper::getClientId(const int deviceId) const {
    auto it = boards_.find(deviceId);
    if (it != boards_.end()) {
        return (*it).second.clientId;
    }
    return std::string();
}

std::string BoardManagerWrapper::getClassId(const int deviceId) const {
    auto it = boards_.find(deviceId);
    if (it != boards_.end()) {
        return it->second.device->getProperty(strata::DeviceProperties::classId).toStdString();
    }
    return std::string();
}

std::string BoardManagerWrapper::getPlatformId(const int deviceId) const {
    auto it = boards_.find(deviceId);
    if (it != boards_.end()) {
        return it->second.device->getProperty(strata::DeviceProperties::platformId).toStdString();
    }
    return std::string();
}

bool BoardManagerWrapper::getDeviceIdByClientId(const std::string& clientId, int& deviceId) const {
// Original implementation in BoardsController class iterated through boards (PlatformBoard objects)
// and returned first board which had desired client ID.
    for (auto const& it : boards_) {
        if (clientId == it.second.clientId) {
            deviceId = it.first;
            return true;
        }
    }
    return false;
}

bool BoardManagerWrapper::getFirstDeviceIdByClassId(const std::string& classId, int& deviceId) const {
// Original implementation in BoardsController class iterated through boards (PlatformBoard objects)
// and returned first board which had desired class ID.
    QString class_id = QString::fromStdString(classId);
    for (auto const& it : boards_) {
        if (class_id == it.second.device->getProperty(strata::DeviceProperties::classId)) {
            deviceId = it.first;
            return true;
        }
    }
    return false;
}

bool BoardManagerWrapper::setClientId(const std::string& clientId, const int deviceId) {
   auto it = boards_.find(deviceId);
   if (it != boards_.end()) {
       if ((*it).second.clientId.empty()) {
           (*it).second.clientId = clientId;
           return true;
       }
   }
   return false;
}

bool BoardManagerWrapper::clearClientId(const int deviceId) {
    auto it = boards_.find(deviceId);
    if (it != boards_.end()) {
        (*it).second.clientId.clear();
        return true;
    }
    return false;
}

QString BoardManagerWrapper::logDeviceId(const int deviceId) const {
    return "Device Id: 0x" + QString::number(static_cast<uint>(deviceId), 16);
}

BoardManagerWrapper::Board::Board(strata::SerialDeviceShPtr& devPtr) : device(devPtr) { }
