#pragma once

#include <rapidjson/document.h>
#include <rapidjson/writer.h>
#include <regex>
#include "QtTest.h"

class CommandResponseMock
{
public:
    CommandResponseMock();

    enum class Command {
        unknown,
        get_firmware_info,
        request_platform_id,
        start_bootloader,
        start_application
    };

    enum class MockResponse {
        normal,
        no_payload,
        no_JSON,
        nack,
        invalid
    };

    static std::vector<QByteArray> replacePlaceholders(const std::vector<QByteArray> &responses,
                                                       const rapidjson::Document &requestDoc);
    static QString getPlaceholderValue(const QString placeholder,
                                       const rapidjson::Document &requestDoc);
    std::vector<QByteArray> getResponses(QByteArray request);

    bool mockIsBootloader() { return isBootloader_; }

    void mockSetLegacy(bool legacy) { isLegacy_ = legacy; }

    void mockSetCommandForResponse(Command command, MockResponse response) { command_ = command; response_ = response; }

    void mockSetResponse(MockResponse response) { response_ = response; }

private:
    bool isBootloader_ = false;
    bool isLegacy_ = false;  // very old board without 'get_firmware_info' command support
    Command command_ = Command::unknown;
    MockResponse response_ = MockResponse::normal;
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

const QByteArray get_firmware_info_response_no_payload =
R"({
    "notification": {
        "value":"get_firmware_info",
    }
})";

const QByteArray get_firmware_info_response_invalid =
R"({
    "notification": {
        "value":"get_firmware_info",
        "payload": {
            "bootloader": {
                "version":-1,
                "date":"20180401_123420"
            },
            "application": {
                "version":-1
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

const QByteArray request_platform_id_response_no_payload =
R"({
    "notification":{
        "value":"platform_id",
    }
})";

const QByteArray request_platform_id_response_invalid =
R"({
    "notification":{
        "value":"platform_id",
        "payload":{
            "name":-1,
            "platform_id":"platform",
            "class_id":"class",
            "count":count,
            "platform_id_version":"version",
            "verbose_name":-1
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

const QByteArray request_platform_id_response_bootloader_no_payload =
R"({
    "notification":{
        "value":"platform_id",
    }
})";

const QByteArray request_platform_id_response_bootloader_invalid =
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

const QByteArray start_bootloader_response_no_payload =
R"({
    "notification":{
        "value":"start_bootloader",
    }
})";

const QByteArray start_bootloader_response_invalid =
R"({
    "notification":{
        "value":"start_bootloader",
        "payload":{
            "status":-1
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

const QByteArray start_application_response_no_payload =
R"({
    "notification":{
        "value":"start_application",
    }
})";

const QByteArray start_application_response_invalid =
R"({
    "notification":{
        "value":"start_application",
        "payload":{
            "status":-1
        }
    }
})";

const QByteArray no_JSON_response =
"notJSON";

}  // namespace test_commands
