#pragma once

#include <QRegularExpression>
#include <QByteArray>
#include <QJsonDocument>

namespace strata::device {

constexpr unsigned MAX_STORED_MESSAGES = 4096;

Q_NAMESPACE

enum class MockCommand {
    all_commands,
    get_firmware_info,
    request_platform_id,
    start_bootloader,
    start_application,
    flash_firmware,
    flash_bootloader,
    start_flash_firmware,
    start_flash_bootloader
};
Q_ENUM_NS(MockCommand)

enum class MockResponse {
    normal,
    no_payload,
    no_JSON,
    nack,
    invalid,
    embedded_app,
    assisted_app,
    assisted_no_board,
    embedded_btloader,
    assisted_btloader,
    flash_resend_chunk,
    flash_memory_error,
    flash_invalid_cmd_sequence,
    flash_invalid_value,
    start_flash_firmware_invalid
};
Q_ENUM_NS(MockResponse)

enum class MockVersion {
    version1,
    version2
};
Q_ENUM_NS(MockVersion)

// these are global constants for testing
namespace test_commands {

const QRegularExpression parameterRegex = QRegularExpression("\\{\\$[^\\{]*\\}");

#define TRIM_JSON(a) QJsonDocument::fromJson(a).toJson(QJsonDocument::Compact).append('\n')

const QByteArray ack = TRIM_JSON(
R"({
    "ack":"{$request.cmd}",
    "payload":{"return_value":true,"return_string":"command valid"}
})");

const QByteArray nack_badly_formatted_json = TRIM_JSON(
R"({
    "ack":"",
    "payload":{"return_value":false,"return_string":"badly formatted json"}
})");

const QByteArray nack_command_not_found = TRIM_JSON(
R"({
    "ack":"{$request.cmd}",
    "payload":{"return_value":false,"return_string":"command not found"}
})");

const QByteArray get_firmware_info_request = TRIM_JSON(
R"({
    "cmd":"get_firmware_info",
    "payload":{}
})");

const QByteArray get_firmware_info_response = TRIM_JSON(
R"({
    "notification": {
        "value":"get_firmware_info",
        "payload": {
            "bootloader": {
                "version":"1.0.0",
                "date":"20180401_123420",
                "checksum":"0f30116f6544a35404f6d3a24b6aab60"
            },
            "application": {
                "version":"1.0.0",
                "date":"20180401_131410",
                "checksum":"0f30116f6544a35404f6d3a24b6aab60"
            }
        }
    }
})");

const QByteArray get_firmware_info_response_no_bootloader = TRIM_JSON(
R"({
    "notification": {
        "value":"get_firmware_info",
        "payload": {
            "bootloader": {},
            "application": {
                "version":"1.0.0",
                "date":"20180401_131410",
                "checksum":"0f30116f6544a35404f6d3a24b6aab60"
            }
        }
    }
})");

const QByteArray get_firmware_info_response_ver2_application = TRIM_JSON(
R"({
    "notification": {
        "value":"get_firmware_info",
        "payload": {
            "api_version":"2.0",
            "active":"application",
            "bootloader": {
                "version":"1.2.123",
                "date":"20180401_123420"
            },
            "application": {
                "version":"1.1234.1",
                "date":"20180401_131410"
            }
        }
    }
})");

const QByteArray get_firmware_info_response_ver2_bootloader = TRIM_JSON(
R"({
    "notification": {
        "value":"get_firmware_info",
        "payload": {
            "api_version":"2.0",
            "active":"bootloader",
            "bootloader": {
                "version":"1.2.123",
                "date":"20180401_123420"
            },
            "application": {
                "version":"1.1234.1",
                "date":"20180401_131410"
            }
        }
    }
})");

const QByteArray get_firmware_info_response_ver2_invalid = TRIM_JSON(
R"({
    "notification": {
        "value":"get_firmware_info",
        "payload": {
            "api_version":-1,
            "active":"both",
            "bootloader": {
                "version":-1,
                "date":"20180401_123420"
            },
            "application": {
                "version":-1,
                "date":"20180401_131410"
            }
        }
    }
})");

const QByteArray get_firmware_info_response_no_payload = TRIM_JSON(
R"({
    "notification": {
        "value":"get_firmware_info",
    }
})");

const QByteArray get_firmware_info_response_invalid = TRIM_JSON(
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
})");

const QByteArray request_platform_id_request = TRIM_JSON(
R"({
    "cmd":"request_platform_id",
    "payload":{}
})");

const QByteArray request_platform_id_response = TRIM_JSON(
R"({
    "notification":{
        "value":"platform_id",
        "payload":{
            "name":"Mock Board",
            "platform_id":"101",
            "class_id":"201",
            "count":11,
            "platform_id_version":"2.0",
            "verbose_name":"Mock Board"
        }
    }
})");

const QByteArray request_platform_id_response_ver2_embedded = TRIM_JSON(
R"({
    "notification":{
        "value":"platform_id",
        "payload":{
            "name":"LED Driver",
            "controller_type":1,
            "platform_id":"00000000-0000-0000-0000-000000000000",
            "class_id":"00000000-0000-0000-0000-000000000000",
            "board_count":1
        }
    }
})");

const QByteArray request_platform_id_response_ver2_assisted = TRIM_JSON(
R"({
    "notification":{
       "value":"platform_id",
       "payload":{
          "name":"LED Driver",
          "controller_type":2,
          "platform_id":"00000000-0000-0000-0000-000000000000",
          "class_id":"00000000-0000-0000-0000-000000000000",
          "board_count":1,
          "controller_platform_id":"00000000-0000-0000-0000-000000000000",
          "controller_class_id":"00000000-0000-0000-0000-000000000000",
          "controller_board_count":1,
          "fw_class_id":"00000000-0000-0000-0000-000000000000"
       }
    }
})");

const QByteArray request_platform_id_response_ver2_assisted_without_board = TRIM_JSON(
R"({
    "notification":{
       "value":"platform_id",
       "payload":{
          "name":"LED Driver",
          "controller_type":2,
          "controller_platform_id":"00000000-0000-0000-0000-000000000000",
          "controller_class_id":"00000000-0000-0000-0000-000000000000",
          "controller_board_count":1,
          "fw_class_id":"00000000-0000-0000-0000-000000000000"
       }
    }
})");

const QByteArray request_platform_id_response_ver2_assisted_invalid = TRIM_JSON(
R"({
    "notification":{
       "value":"platform_id",
       "payload":{
          "name":null,
          "controller_type":2,
          "platform_id":"00000000-0000-0000-0000-000000000000",
          "class_id":"00000000-0000-0000-0000-000000000000",
          "board_count":1,
          "controller_platform_id":-1,
          "controller_class_id":-1,
          "controller_board_count":1,
          "fw_class_id":"00000000-0000-0000-0000-000000000000"
       }
    }
})");

const QByteArray request_platform_id_response_ver2_embedded_bootloader = TRIM_JSON(
R"({
    "notification":{
        "value":"platform_id",
        "payload":{
            "name":"Bootloader",
            "controller_type":1,
            "platform_id":"00000000-0000-0000-0000-000000000000",
            "class_id":"00000000-0000-0000-0000-000000000000",
            "board_count":1
        }
    }
})");

const QByteArray request_platform_id_response_ver2_assisted_bootloader = TRIM_JSON(
R"({
    "notification":{
       "value":"platform_id",
       "payload":{
          "name":"Bootloader",
          "controller_type":2,
          "platform_id":"00000000-0000-0000-0000-000000000000",
          "class_id":"00000000-0000-0000-0000-000000000000",
          "board_count":1,
          "controller_platform_id":"6057eb97-5e00-4adc-8bff-9c5e8205b353",
          "controller_class_id":"6057eb97-5e00-4adc-8bff-9c5e8205b353",
          "controller_board_count":1234,
          "fw_class_id": "7bdcea96-0fb8-41de-9822-dec20ae1032a"
       }
    }
})");

const QByteArray request_platform_id_response_no_payload = TRIM_JSON(
R"({
    "notification":{
        "value":"platform_id",
    }
})");

const QByteArray request_platform_id_response_invalid = TRIM_JSON(
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
})");

const QByteArray request_platform_id_response_bootloader = TRIM_JSON(
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
})");

const QByteArray request_platform_id_response_bootloader_no_payload = TRIM_JSON(
R"({
    "notification":{
        "value":"platform_id",
    }
})");

const QByteArray request_platform_id_response_bootloader_invalid = TRIM_JSON(
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
})");

const QByteArray start_bootloader_request = TRIM_JSON(
R"({
    "cmd":"start_bootloader",
    "payload":{}
})");

const QByteArray start_bootloader_response = TRIM_JSON(
R"({
    "notification":{
        "value":"start_bootloader",
        "payload":{
            "status":"ok"
        }
    }
})");

const QByteArray start_bootloader_response_no_payload = TRIM_JSON(
R"({
    "notification":{
        "value":"start_bootloader",
    }
})");

const QByteArray start_bootloader_response_invalid = TRIM_JSON(
R"({
    "notification":{
        "value":"start_bootloader",
        "payload":{
            "status":-1
        }
    }
})");

const QByteArray start_application_request = TRIM_JSON(
R"({
    "cmd":"start_application",
    "payload":{}
})");

const QByteArray start_application_response = TRIM_JSON(
R"({
    "notification":{
        "value":"start_application",
        "payload":{
            "status":"ok"
        }
    }
})");

const QByteArray start_application_response_no_payload = TRIM_JSON(
R"({
    "notification":{
        "value":"start_application",
    }
})");

const QByteArray start_application_response_invalid = TRIM_JSON(
R"({
    "notification":{
        "value":"start_application",
        "payload":{
            "status":-1
        }
    }
})");

const QByteArray no_JSON_response = "notJSON";

const QByteArray flash_firmware_request = TRIM_JSON(
R"({
    "cmd":"flash_firmware",
    "payload":{
        "chunk":{
            "number":{$request.payload.chunk.number},
            "size":{$request.payload.chunk.size},
            "crc":{$request.payload.chunk.crc},
            "data":"{$request.payload.chunk.data}"
        }
    }
})");

const QByteArray flash_bootloader_request = TRIM_JSON(
R"({
    "cmd":"flash_bootloader",
    "payload":{
        "chunk":{
            "number":{$request.payload.chunk.number},
            "size":{$request.payload.chunk.size},
            "crc":{$request.payload.chunk.crc},
            "data":"{$request.payload.chunk.data}"
        }
    }
})");

const QByteArray start_flash_firmware_request = TRIM_JSON(
R"({
    "cmd":"start_flash_firmware",
    "payload": {
        "size": {$request.payload.size},
        "chunks": {$request.payload.chunks},
        "md5": "{$request.payload.md5}"
    }
})");

const QByteArray start_flash_bootloader_request = TRIM_JSON(
R"({
    "cmd":"start_flash_bootloader",
    "payload": {
        "size": {$request.payload.size},
        "chunks": {$request.payload.chunks},
        "md5": "{$request.payload.md5}"
    }
})");

const QByteArray start_flash_firmware_response = TRIM_JSON(
R"({
    "notification":{
        "value":"start_flash_firmware",
        "payload":{
            "status":"ok"
        }
    }
})");

const QByteArray start_flash_firmware_response_invalid = TRIM_JSON(
R"({
    "notification":{
        "value":"start_flash_firmware",
        "payload":{
            "status":-1
        }
    }
})");

const QByteArray start_flash_bootloader_response = TRIM_JSON(
R"({
    "notification":{
        "value":"start_flash_bootloader",
        "payload":{
            "status":"ok"
        }
    }
})");

const QByteArray flash_firmware_response = TRIM_JSON(
R"({
    "notification":{
        "value":"flash_firmware",
        "payload":{
            "status":"ok"
        }
    }
})");

const QByteArray flash_firmware_response_resend_chunk = TRIM_JSON(
R"({
    "notification":{
        "value":"flash_firmware",
        "payload":{
            "status":"resend_chunk"
        }
    }
})");

const QByteArray flash_firmware_response_memory_error = TRIM_JSON(
R"({
    "notification":{
        "value":"flash_firmware",
        "payload":{
            "status":"flash_memory_error"
        }
    }
})");

const QByteArray flash_firmware_response_invalid_cmd_sequence = TRIM_JSON(
R"({
    "notification":{
        "value":"flash_firmware",
        "payload":{
            "status":"invalid_cmd_sequence"
        }
    }
})");

const QByteArray flash_firmware_invalid_value = TRIM_JSON(
R"({
    "notification":{
        "value":"flash_firmware",
        "payload":{
            "status":"-1
        }
    }
})");

const QByteArray flash_bootloader_response = TRIM_JSON(
R"({
    "notification":{
        "value":"flash_bootloader",
        "payload":{
            "status":"ok"
        }
    }
})");

} // namespace strata::device::test_commands

} // namespace strata::device
