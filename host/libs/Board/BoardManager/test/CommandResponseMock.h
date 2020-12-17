#pragma once

#include <rapidjson/document.h>
#include <rapidjson/writer.h>
#include <regex>
#include "QtTest.h"

class CommandResponseMock
{
public:
    CommandResponseMock();

    static std::vector<QByteArray> replacePlaceholders(const std::vector<QByteArray> &responses,
                                                       const rapidjson::Document &requestDoc);
    static QString getPlaceholderValue(const QString placeholder,
                                       const rapidjson::Document &requestDoc);
    std::vector<QByteArray> getResponses(QByteArray request);

    bool mockIsBootloader() { return isBootloader_; }

    void mockSetLegacy(bool legacy) { isLegacy_ = legacy; }

private:
    bool isBootloader_ = false;
    bool isLegacy_ = false;  // very old board without 'get_firmware_info' command support
};


// these are global constants, so let's at least encapsulate them in a namespace
namespace test_commands
{
const QRegularExpression parameterRegex = QRegularExpression("\\{\\$.*\\}");

const QByteArray ack =
R"({
    "ack":"{$request.cmd}",
    "payload":{"return_value":true,"return_string":"command valid"}
})";

const QByteArray nack_badly_formatted_json =
R"({
    "ack":"",
    "payload":{"return_value":false,"return_string":"badly formatted json"}
})";

const QByteArray nack_command_not_found =
R"({
    "ack":"{$request.cmd}",
    "payload":{"return_value":false,"return_string":"command not found"}
})";

const QByteArray get_firmware_info_request = R"({"cmd":"get_firmware_info","payload":{}})";

const QByteArray get_firmware_info_response =
R"({
    "notification": {
        "value":"get_firmware_info",
        "payload": {
            "bootloader": {
                "version":"1.1.1",
                "date":"20180401_123420"
            },
            "application": {
                "version":"1.1.2",
                "date":"20180401_131410"
            }
        }
    }
})";

const QByteArray request_platform_id_request =
R"({
    "cmd":"request_platform_id",
    "payload":{}
})";

const QByteArray request_platform_id_response =
R"({
    "notification":{
        "value":"platform_id",
        "payload":{
            "name":"Logic Gates",
            "platform_id":"101",
            "class_id":"201",
            "count":11,
            "platform_id_version":"2.0",
            "verbose_name":"Logic Gates"
        }
    }
})";

const QByteArray request_platform_id_response_bootloader =
R"({
    "notification":{
        "value":"platform_id",
        "payload":{
            "name":"Bootloader",
            "platform_id":"Unknown",
            "class_id":"bootloader",
            "count":0,
            "platform_id_version":"2.0"
        }
    }
})";

const QByteArray start_bootloader_request = R"({"cmd":"start_bootloader","payload":{}})";

const QByteArray start_bootloader_response =
R"({
    "notification":{
        "value":"start_bootloader",
        "payload":{
            "status":"ok"
        }
    }
})";

const QByteArray start_application_request = R"({"cmd":"start_application","payload":{}})";

const QByteArray start_application_response =
R"({
    "notification":{
        "value":"start_application",
        "payload":{
            "status":"ok"
        }
    }
})";

}  // namespace test_commands
