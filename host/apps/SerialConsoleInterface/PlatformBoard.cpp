
#include "PlatformBoard.h"

#include <PlatformConnection.h>

// rapid json library
#include <rapidjson/document.h>
#include <rapidjson/writer.h>
#include <rapidjson/stringbuffer.h>


PlatformBoard::PlatformBoard(spyglass::PlatformConnection* connection) : connection_(connection)
{
}

PlatformBoard::~PlatformBoard()
{
}

void PlatformBoard::sendInitialMsg()
{
    const std::string init_msg("{\"cmd\":\"request_platform_id\"}");
    connection_->addMessage(init_msg);
    state_ = State::eSendInitialMsg;
}

ProcessResult PlatformBoard::handleMessage(const std::string& msg)
{
    if (state_ == State::eSendInitialMsg) {
        bool wasNotification;
        int ret = parseInitialMsg(msg, wasNotification);
        if (ret < 0) {
            return ProcessResult::eParseError;
        }
        else if (ret == 0) {
            return ProcessResult::eIgnored;
        }
        else if (ret == 1) {
            if (wasNotification && false == platformId_.empty()) {
                state_ = State::eConnected;
            }
            return ProcessResult::eProcessed;
        }
    }

    return ProcessResult::eIgnored;
}

int PlatformBoard::parseInitialMsg(const std::string& msg, bool& wasNotification)
{
    rapidjson::Document doc;
    if (doc.Parse(msg.c_str()).HasParseError()) {
        return -1;
    }

    assert(doc.IsObject());
    auto firstIt = doc.MemberBegin();
    std::string msg_type = firstIt->name.GetString();

    if (msg_type == "ack")
    {
        wasNotification = false;
        std::string command_id = firstIt->value.GetString();

        rapidjson::Value& doc_payload = doc["payload"];

        bool ret = doc_payload.HasMember("return_value");
        assert(ret);

        return 1;
    }
    else if (msg_type == "notification")
    {
        wasNotification = true;
        rapidjson::Value& doc_notify = firstIt->value;
        std::string notify_value = doc_notify["value"].GetString();
        rapidjson::Value& notify_payload = doc_notify["payload"];

        if (notify_value == "platform_id") {
            platformId_   = notify_payload["platform_id"].GetString();
            verboseName_  = notify_payload["verbose_name"].GetString();
        }

        return 1;
    }

    return 0;
}




