#include <cstdio>

#include <rapidjson/document.h>
#include <rapidjson/stringbuffer.h>
#include <rapidjson/writer.h>

#include "BoardManagerWrapper.h"
#include "Dispatcher.h"

BoardManagerWrapper::BoardManagerWrapper() {
    connect(&boardManager_, &spyglass::BoardManager::boardReady, this, &BoardManagerWrapper::newConnection);
    connect(&boardManager_, &spyglass::BoardManager::boardDisconnected, this, &BoardManagerWrapper::closeConnection);
    connect(&boardManager_, &spyglass::BoardManager::newMessage, this, &BoardManagerWrapper::messageFromConnection);
}

void BoardManagerWrapper::initialize(HCS_Dispatcher* dispatcher) {
    dispatcher_ = dispatcher;
    boardManager_.init();
}

void BoardManagerWrapper::setLogAdapter(LoggingAdapter* adapter) {
    logAdapter_ = adapter;
}

void BoardManagerWrapper::sendMessage(const int connectionId, const std::string& message) {
    if (logAdapter_) {
        char hexStr[(2 * sizeof(unsigned)) + 3];  // we need 2 chars per byte + 3 extra bytes ('0','x','\0')
        std::sprintf(hexStr, "0x%x", static_cast<unsigned>(connectionId));
        std::string logText("Sending msg to board with connection ID ");
        logText.append(hexStr);
        logAdapter_->Log(LoggingAdapter::LogLevel::eLvlDebug, logText);
    }

    boardManager_.sendMessage(connectionId, QString::fromStdString(message));
}

void BoardManagerWrapper::newConnection(int connectionId, bool recognized) {
    if (recognized) {
        boardInfo_.emplace(connectionId, BoardInfo(
            boardManager_.getDeviceProperty(connectionId, spyglass::DeviceProperties::classId),
            boardManager_.getDeviceProperty(connectionId, spyglass::DeviceProperties::platformId),
            boardManager_.getDeviceProperty(connectionId, spyglass::DeviceProperties::verboseName)
        ));
        char hexStr[(2 * sizeof(unsigned)) + 3];  // we need 2 chars per byte + 3 extra bytes ('0','x','\0')
        std::sprintf(hexStr, "0x%x", static_cast<unsigned>(connectionId));
        PlatformMessage item;
        item.msg_type = PlatformMessage::eMsgPlatformConnected;
        item.from_client = hexStr;  // TODO: Is this necessary?
        item.from_connectionId.conn_id = connectionId;
        item.from_connectionId.is_set = true;
        item.msg_document = nullptr;

        dispatcher_->addMessage(item);

        if (logAdapter_) {
            std::string logText("Connected new board with connection ID ");
            logText.append(hexStr);
            logAdapter_->Log(LoggingAdapter::LogLevel::eLvlInfo, logText);
        }
    }
    else {
        if (logAdapter_) {
            logAdapter_->Log(LoggingAdapter::LogLevel::eLvlInfo, "Unrecognized board connected.");
        }
    }
}

void BoardManagerWrapper::closeConnection(int connectionId) {
    auto it = boardInfo_.at(connectionId);
    rapidjson::Document document;
    document.SetObject();
    document.AddMember("platform_id", rapidjson::Value(it.platformId.c_str(), document.GetAllocator() ), document.GetAllocator() );
    document.AddMember("class_id", rapidjson::Value(it.classId.c_str(), document.GetAllocator() ), document.GetAllocator() );

    rapidjson::StringBuffer strbuf;
    rapidjson::Writer<rapidjson::StringBuffer> writer(strbuf);
    document.Accept(writer);

    boardInfo_.erase(connectionId);

    char hexStr[(2 * sizeof(unsigned)) + 3];  // we need 2 chars per byte + 3 extra bytes ('0','x','\0')
    std::sprintf(hexStr, "0x%x", static_cast<unsigned>(connectionId));
    PlatformMessage item;
    item.msg_type = PlatformMessage::eMsgPlatformDisconnected;
    item.from_client = hexStr;  // TODO: Is this necessary?
    item.from_connectionId.conn_id = connectionId;
    item.from_connectionId.is_set = true;
    item.message = strbuf.GetString();
    item.msg_document = nullptr;

    dispatcher_->addMessage(item);

    if (logAdapter_) {
        std::string logText("Disconnected board with connection ID ");
        logText.append(hexStr);
        logAdapter_->Log(LoggingAdapter::LogLevel::eLvlInfo, logText);
    }

}

void BoardManagerWrapper::messageFromConnection(int connectionId, QString message) {
    char hexStr[(2 * sizeof(unsigned)) + 3];  // we need 2 chars per byte + 3 extra bytes ('0','x','\0')
    std::sprintf(hexStr, "0x%x", static_cast<unsigned>(connectionId));
    PlatformMessage item;
    item.msg_type = PlatformMessage::eMsgPlatformMessage;
    item.from_client = hexStr;  // TODO: Is this necessary?
    item.from_connectionId.conn_id = connectionId;
    item.from_connectionId.is_set = true;
    item.message = message.toStdString();
    item.msg_document = nullptr;

    dispatcher_->addMessage(item);

    if (logAdapter_) {
        std::string logText("Board msg from connection ID ");
        logText.append(hexStr);
        logAdapter_->Log(LoggingAdapter::LogLevel::eLvlDebug, logText);
    }
}

void BoardManagerWrapper::createPlatformsList(std::string& result) {
    rapidjson::Document document;
    document.SetObject();
    rapidjson::Value array(rapidjson::kArrayType);
    rapidjson::Document::AllocatorType& allocator = document.GetAllocator();

    for (auto const& it : boardInfo_) {
        rapidjson::Value json_verbose(it.second.verboseName.c_str(), allocator);
        rapidjson::Value json_uuid(it.second.classId.c_str(), allocator);
        rapidjson::Value array_object;
        array_object.SetObject();

        array_object.AddMember("verbose_name",json_verbose, allocator);
        array_object.AddMember("class_id",json_uuid, allocator);
        array_object.AddMember("connection", "connected", allocator);
        array.PushBack(array_object,allocator);
    }
    rapidjson::Value nested_object;
    nested_object.SetObject();
    nested_object.AddMember("list", array,allocator);
    nested_object.AddMember("type", "connected_platforms", allocator);

    document.AddMember("hcs::notification", nested_object, allocator);

    rapidjson::StringBuffer strbuf;
    rapidjson::Writer<rapidjson::StringBuffer> writer(strbuf);
    document.Accept(writer);
    result = strbuf.GetString();
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

void BoardManagerWrapper::logging(LoggingAdapter::LogLevel level, const std::string& log_text) {
    if (logAdapter_) {
        logAdapter_->Log(level, log_text);
    }
}

BoardManagerWrapper::BoardInfo::BoardInfo(QString clssId, QString pltfId, QString vName)
    : classId(clssId.toStdString()), platformId(pltfId.toStdString()), verboseName(vName.toStdString()) { }
