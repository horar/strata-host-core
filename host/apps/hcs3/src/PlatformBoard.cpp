
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

                if (getProperty("application_version").empty()) {  //Is it in bootloader mode
                    state_ = State::eConnected;  //TODO: handle when only bootloader present..
                }
                else {
                    sendPlatformInfoMsg();
                }
            }
            else if (state_ == State::eWaitingForPlatformInfo) {
                state_ = State::eConnected;
            }
        }

        return ret;
    }

    return ProcessResult::eIgnored;
}

std::string PlatformBoard::getProperty(const std::string& key)
{
    auto findIt = properties_.find(key);
    if (findIt != properties_.end()) {
        return findIt->second;
    }

    return std::string();
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

        if (doc.HasMember("payload") == false) {
            return ProcessResult::eValidationError;
        }

        rapidjson::Value& doc_payload = doc["payload"];
        if (doc_payload.HasMember("return_value") == false) {
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
        if (doc_notify.HasMember("value") == false ||
            doc_notify.HasMember("payload") == false) {
            return ProcessResult::eValidationError;  //Malformed notification
        }

        std::string notify_value = doc_notify["value"].GetString();
        rapidjson::Value& notify_payload = doc_notify["payload"];

        if (notify_value == "get_firmware_info") {
            if (notify_payload.HasMember("bootloader") == false ||
                notify_payload.HasMember("application") == false) {
                return ProcessResult::eValidationError;
            }

            rapidjson::Value& bootloader_value = notify_payload["bootloader"];
            rapidjson::Value& application_value = notify_payload["application"];

            if (bootloader_value.HasMember("version") && bootloader_value.HasMember("date")) {
                properties_["bootloader_version"] = bootloader_value["version"].GetString();
            } else {
                properties_["bootloader_version"].clear();
            }

            if (application_value.HasMember("version") && application_value.HasMember("date")) {
                properties_["application_version"] = application_value["version"].GetString();
            } else {
                properties_["application_version"].clear();
            }

            return ProcessResult::eProcessed;

        }
        else if (notify_value == "platform_id") {

            PlatformIdVer version = PlatformIdVer::eVersion1;

            const char* nameIdentifier = "verbose_name";
            if (notify_payload.HasMember("platform_id_version")) {
                nameIdentifier = "name";
                version = PlatformIdVer::eVersion2;
            }

            if (notify_payload.HasMember("platform_id") == false ||
                notify_payload.HasMember(nameIdentifier) == false) {
                return ProcessResult::eValidationError;
            }

            switch(version)
            {
                case PlatformIdVer::eVersion1:
                    properties_["platform_id"] = notify_payload["platform_id"].GetString();
                    properties_["class_id"] = properties_["platform_id"];  //TODO: test this with old boards
                    properties_["name"] = notify_payload[nameIdentifier].GetString();
                    break;
                case PlatformIdVer::eVersion2:
                    properties_["platform_id"] = notify_payload["platform_id"].GetString();
                    properties_["class_id"] = notify_payload["class_id"].GetString();
                    properties_["name"] = notify_payload[nameIdentifier].GetString();

                default:
                    break;
            }

            return ProcessResult::eProcessed;

        }
        else {
            return ProcessResult::eIgnored;
        }
    }

    return ProcessResult::eIgnored;
}

bool PlatformBoard::setClientId(const std::string& clientId)
{
    if (!clientId_.empty())
        return false;

    clientId_ = clientId;
    return true;
}

void PlatformBoard::resetClientId()
{
    clientId_.clear();
}

std::string PlatformBoard::getConnectionId() const
{
    if (!connection_) {
        return std::string();
    }

    return connection_->getName();
}

void PlatformBoard::disconnect()
{
    state_ = State::eDisconnected;
}
