
#include "PlatformBoard.h"

#include <PlatformConnection.h>

#include <rapidjson/document.h>
#include <rapidjson/writer.h>
#include <rapidjson/stringbuffer.h>


PlatformBoard::PlatformBoard(spyglass::PlatformConnection* connection) : connection_(connection), state_(State::eInit)
{
}

PlatformBoard::~PlatformBoard()
{
}

void PlatformBoard::sendInitialMsg()
{
    const std::string init_msg("{\"cmd\":\"get_firmware_info\"}");
    connection_->addMessage(init_msg);
    state_ = State::eWaitingForFirmwareInfo;
}

void PlatformBoard::sendPlatformInfoMsg()
{
    const std::string init_msg("{\"cmd\":\"request_platform_id\"}");
    connection_->addMessage(init_msg);
    state_ = State::eWaitingForPlatformInfo;
}

PlatformBoard::ProcessResult PlatformBoard::handleMessage(const std::string& msg)
{
    if (state_ == State::eWaitingForFirmwareInfo || state_ == State::eWaitingForPlatformInfo) {
        bool wasNotification;
        ProcessResult ret = parseInitialMsg(msg, wasNotification);

        if (ProcessResult::eProcessed == ret && wasNotification) {
            if (state_ == State::eWaitingForFirmwareInfo) {
                if (applicationVersion_.empty()) {
                    state_ = State::eConnected;
                } else {
                    sendPlatformInfoMsg();
                }

            } else if (state_ == State::eWaitingForPlatformInfo) {
                state_ = State::eConnected;
            }
        }

        return ret;
    }

    return ProcessResult::eIgnored;
}

std::string PlatformBoard::getPlatformId() const
{
    return platformId_;
}

std::string PlatformBoard::getVerboseName() const
{
    return verboseName_;
}

std::string PlatformBoard::getBootloaderVersion() const
{
    return bootloaderVersion_;
}

std::string PlatformBoard::getApplicationVersion() const
{
    return applicationVersion_;
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
        if (command_id != "get_firmware_info" || command_id != "request_platform_id") {
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
        rapidjson::Value& notify_payload = doc_notify["payload"];

        if (notify_value == "get_firmware_info") {
            if (!notify_payload.HasMember("bootloader") || !notify_payload.HasMember("application")) {
                return ProcessResult::eValidationError;
            }

            rapidjson::Value& bootloader_value = notify_payload["bootloader"];
            rapidjson::Value& application_value = notify_payload["application"];

            if (bootloader_value.HasMember("version") && bootloader_value.HasMember("date")) {
                bootloaderVersion_ = bootloader_value["version"].GetString();
            } else {
                bootloaderVersion_.clear();
            }

            if (application_value.HasMember("version") && application_value.HasMember("date")) {
                applicationVersion_ = application_value["version"].GetString();
            } else {
                applicationVersion_.clear();
            }

            return ProcessResult::eProcessed;

        } else if (notify_value == "platform_id") {
            const char* nameIdentifier = "verbose_name";
            if (notify_payload.HasMember("platform_id_version")) {
                nameIdentifier = "name";
            }

            if (!notify_payload.HasMember("platform_id") || !notify_payload.HasMember(nameIdentifier)) {
                return ProcessResult::eValidationError;
            }

            platformId_ = notify_payload["platform_id"].GetString();
            verboseName_ = notify_payload[nameIdentifier].GetString();

            return ProcessResult::eProcessed;

        } else {
            return ProcessResult::eIgnored;
        }
    }

    return ProcessResult::eIgnored;
}
