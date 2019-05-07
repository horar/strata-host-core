
#include "PlatformBoard.h"

#include <PlatformConnection.h>

#include <rapidjson/document.h>
#include <rapidjson/writer.h>
#include <rapidjson/stringbuffer.h>


PlatformBoard::PlatformBoard(spyglass::PlatformConnectionShPtr connection) : connection_(connection), state_(State::eInit)
{
}

void PlatformBoard::sendInitialMsg()
{
    const std::string init_msg("{\"cmd\":\"request_platform_id\"}");
    connection_->addMessage(init_msg);
    state_ = State::eSendInitialMsg;
}

PlatformBoard::ProcessResult PlatformBoard::handleMessage(const std::string& msg)
{
    if (state_ == State::eSendInitialMsg) {
        bool wasNotification;
        ProcessResult ret = parseInitialMsg(msg, wasNotification);
        if (ProcessResult::eProcessed == ret && wasNotification && false == platformId_.empty()) {
            state_ = State::eConnected;
        }

        return ret;
    }

    return ProcessResult::eIgnored;
}

PlatformBoard::ProcessResult PlatformBoard::parseInitialMsg(const std::string& msg, bool& wasNotification)
{
    rapidjson::Document doc;
    if (doc.Parse(msg.c_str()).HasParseError()) {
        return ProcessResult::eParseError;
    }

    assert(doc.IsObject());
    auto firstIt = doc.MemberBegin();
    std::string msg_type = firstIt->name.GetString();

    if (msg_type == "ack")
    {
        wasNotification = false;
        std::string command_id = firstIt->value.GetString();
        if (command_id != "request_platform_id") {
            return ProcessResult::eIgnored;
        }

        if (!doc.HasMember("payload")) {
            return ProcessResult::eValidationError;
        }

        rapidjson::Value& doc_payload = doc["payload"];
        if (!doc_payload.HasMember("return_value")) {
            return ProcessResult::eValidationError;
        }

        if (doc_payload["return_value"].GetBool() != true) {
            //TODO: this is the question...
            return ProcessResult::eIgnored;
        }

        return ProcessResult::eProcessed;
    }
    else if (msg_type == "notification")
    {
        wasNotification = true;
        rapidjson::Value& doc_notify = firstIt->value;
        if (!doc_notify.HasMember("value") || !doc_notify.HasMember("payload") ) {
            return ProcessResult::eValidationError;  //Malformed notification
        }

        std::string notify_value = doc_notify["value"].GetString();
        if (notify_value != "platform_id") {
            return ProcessResult::eIgnored;
        }

        rapidjson::Value& notify_payload = doc_notify["payload"];
        if (!notify_payload.HasMember("platform_id") || !notify_payload.HasMember("verbose_name")) {
            return ProcessResult::eValidationError;
        }

        platformId_   = notify_payload["platform_id"].GetString();
        verboseName_  = notify_payload["verbose_name"].GetString();
        return ProcessResult::eProcessed;
    }

    return ProcessResult::eIgnored;
}




