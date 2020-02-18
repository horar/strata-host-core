#include <cstdio>

#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

#include "BoardManagerWrapper.h"
#include "Dispatcher.h"
#include "logging/LoggingQtCategories.h"
#include "JsonStrings.h"

BoardManagerWrapper::BoardManagerWrapper() {
    connect(&boardManager_, &spyglass::BoardManager::boardReady, this, &BoardManagerWrapper::newConnection);
    connect(&boardManager_, &spyglass::BoardManager::boardDisconnected, this, &BoardManagerWrapper::closeConnection);
    connect(&boardManager_, &spyglass::BoardManager::newMessage, this, &BoardManagerWrapper::messageFromConnection);
}

void BoardManagerWrapper::initialize(HCS_Dispatcher* dispatcher) {
    dispatcher_ = dispatcher;
    boardManager_.init();
}

void BoardManagerWrapper::sendMessage(const int connectionId, const std::string& message) {
    qCInfo(logCategoryHcsBoard).nospace() << "Sending msg to board with connection ID 0x" << hex << static_cast<unsigned>(connectionId);

    boardManager_.sendMessage(connectionId, QString::fromStdString(message));
}

void BoardManagerWrapper::newConnection(int connectionId, bool recognized) {
    if (recognized) {
        boardInfo_.emplace(connectionId, BoardInfo(
            boardManager_.getDeviceProperty(connectionId, spyglass::DeviceProperties::classId),
            boardManager_.getDeviceProperty(connectionId, spyglass::DeviceProperties::platformId),
            boardManager_.getDeviceProperty(connectionId, spyglass::DeviceProperties::verboseName)
        ));
        constexpr size_t hexLen = (2 * sizeof(unsigned)) + 3;  // we need 2 chars per byte + 3 extra bytes ('0','x','\0')
        char hexStr[hexLen];
        std::snprintf(hexStr, hexLen, "0x%x", static_cast<unsigned>(connectionId));
        PlatformMessage item;
        item.msg_type = PlatformMessage::eMsgPlatformConnected;
        item.from_client = hexStr;  // TODO: Is this necessary?
        item.from_connectionId.conn_id = connectionId;
        item.from_connectionId.is_set = true;
        item.msg_document = nullptr;

        dispatcher_->addMessage(item);

        qCInfo(logCategoryHcsBoard) << "Connected new board with connection ID" << hexStr;
    }
    else {
        qCInfo(logCategoryHcsBoard) << "Unrecognized board connected.";
    }
}

void BoardManagerWrapper::closeConnection(int connectionId) {
    auto const it = boardInfo_.find(connectionId);
    if (it == boardInfo_.end()) {
        // This situation can occur if unrecognized board is disconnected.
        return;
    }

    QJsonObject msg {
        { JSON_PLATFORM_ID, QString::fromStdString((*it).second.platformId) },
        { JSON_CLASS_ID, QString::fromStdString((*it).second.classId) }
    };
    QJsonDocument doc(msg);

    boardInfo_.erase(connectionId);

    constexpr size_t hexLen = (2 * sizeof(unsigned)) + 3;  // we need 2 chars per byte + 3 extra bytes ('0','x','\0')
    char hexStr[hexLen];
    std::snprintf(hexStr, hexLen, "0x%x", static_cast<unsigned>(connectionId));
    PlatformMessage item;
    item.msg_type = PlatformMessage::eMsgPlatformDisconnected;
    item.from_client = hexStr;  // TODO: Is this necessary?
    item.from_connectionId.conn_id = connectionId;
    item.from_connectionId.is_set = true;
    item.message = doc.toJson(QJsonDocument::Compact).toStdString();
    item.msg_document = nullptr;

    dispatcher_->addMessage(item);

    qCInfo(logCategoryHcsBoard) << "Disconnected board with connection ID" << hexStr;
}

void BoardManagerWrapper::messageFromConnection(int connectionId, QString message) {
    constexpr size_t hexLen = (2 * sizeof(unsigned)) + 3;  // we need 2 chars per byte + 3 extra bytes ('0','x','\0')
    char hexStr[hexLen];
    std::snprintf(hexStr, hexLen, "0x%x", static_cast<unsigned>(connectionId));
    PlatformMessage item;
    item.msg_type = PlatformMessage::eMsgPlatformMessage;
    item.from_client = hexStr;  // TODO: Is this necessary?
    item.from_connectionId.conn_id = connectionId;
    item.from_connectionId.is_set = true;
    item.message = message.toStdString();
    item.msg_document = nullptr;

    dispatcher_->addMessage(item);

    qCInfo(logCategoryHcsBoard) << "Board msg from connection ID" << hexStr;
}

void BoardManagerWrapper::createPlatformsList(std::string& result) {
    QJsonArray arr;
    for (auto const& it : boardInfo_) {
        QJsonObject item {
            { JSON_VERBOSE_NAME, QString::fromStdString(it.second.verboseName) },
            { JSON_CLASS_ID, QString::fromStdString(it.second.classId) },
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

std::string BoardManagerWrapper::getClientId(const int connectionId) const {
    auto it = boardInfo_.find(connectionId);
    if (it != boardInfo_.end()) {
        return (*it).second.clientId;
    }
    return std::string();
}

std::string BoardManagerWrapper::getClassId(const int connectionId) const {
    auto it = boardInfo_.find(connectionId);
    if (it != boardInfo_.end()) {
        return (*it).second.classId;
    }
    return std::string();
}

std::string BoardManagerWrapper::getPlatformId(const int connectionId) const {
    auto it = boardInfo_.find(connectionId);
    if (it != boardInfo_.end()) {
        return (*it).second.platformId;
    }
    return std::string();
}

bool BoardManagerWrapper::getConnectionIdByClientId(const std::string& clientId, int& connectionId) const {
// Original implementation in BoardsController class iterated through boards (PlatformBoard objects)
// and returned first board which had desired client ID.
    for (auto const& it : boardInfo_) {
        if (clientId == it.second.clientId) {
            connectionId = it.first;
            return true;
        }
    }
    return false;
}

bool BoardManagerWrapper::getFirstConnectionIdByClassId(const std::string& classId, int& connectionId) const {
// Original implementation in BoardsController class iterated through boards (PlatformBoard objects)
// and returned first board which had desired class ID.
    for (auto const& it : boardInfo_) {
        if (classId == it.second.classId) {
            connectionId = it.first;
            return true;
        }
    }
    return false;
}

bool BoardManagerWrapper::setClientId(const std::string& clientId, const int connectionId) {
   auto it = boardInfo_.find(connectionId);
   if (it != boardInfo_.end()) {
       if ((*it).second.clientId.empty()) {
           (*it).second.clientId = clientId;
           return true;
       }
   }
   return false;
}

bool BoardManagerWrapper::clearClientId(const int connectionId) {
    auto it = boardInfo_.find(connectionId);
    if (it != boardInfo_.end()) {
        (*it).second.clientId.clear();
        return true;
    }
    return false;
}

BoardManagerWrapper::BoardInfo::BoardInfo(QString clssId, QString pltfId, QString vName)
    : classId(clssId.toStdString()), platformId(pltfId.toStdString()), verboseName(vName.toStdString()) { }
