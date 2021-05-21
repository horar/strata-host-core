#pragma once

#include <QRegularExpression>
#include <QByteArray>
#include <QJsonDocument>

namespace strata::device {

constexpr unsigned MAX_STORED_MESSAGES = 4096;

constexpr const char* const CMD_GET_FIRMWARE_INFO        = "get_firmware_info";
constexpr const char* const CMD_REQUEST_PLATFORM_ID      = "request_platform_id";
constexpr const char* const CMD_START_BOOTLOADER         = "start_bootloader";
constexpr const char* const CMD_START_APPLICATION        = "start_application";
constexpr const char* const CMD_START_FLASH_FIRMWARE     = "start_flash_firmware";
constexpr const char* const CMD_FLASH_FIRMWARE           = "flash_firmware";
constexpr const char* const CMD_START_FLASH_BOOTLOADER   = "start_flash_bootloader";
constexpr const char* const CMD_FLASH_BOOTLOADER         = "flash_bootloader";
constexpr const char* const CMD_START_BACKUP_FIRMWARE    = "start_backup_firmware";
constexpr const char* const CMD_BACKUP_FIRMWARE          = "backup_firmware";
constexpr const char* const CMD_SET_ASSISTED_PLATFORM_ID = "set_assisted_platform_id";
constexpr const char* const CMD_SET_PLATFORM_ID          = "set_platform_id";

Q_NAMESPACE

enum class MockCommand {
    Any_command,
    Get_firmware_info,
    Request_platform_id,
    Start_bootloader,
    Start_application,
    Flash_firmware,
    Flash_bootloader,
    Start_flash_firmware,
    Start_flash_bootloader,
    Set_assisted_platform_id,
    Set_platform_id,
    Start_backup_firmware,
    Backup_firmware
};
Q_ENUM_NS(MockCommand)

inline MockCommand convertCommandToEnum(const std::string& cmd) {
    if (0 == cmd.compare(CMD_GET_FIRMWARE_INFO)) {
        return MockCommand::Get_firmware_info;
    } else if (0 == cmd.compare(CMD_REQUEST_PLATFORM_ID)) {
        return MockCommand::Request_platform_id;
    } else if (0 == cmd.compare(CMD_START_BOOTLOADER)) {
        return MockCommand::Start_bootloader;
    } else if (0 == cmd.compare(CMD_START_APPLICATION)) {
        return MockCommand::Start_application;
    } else if (0 == cmd.compare(CMD_START_FLASH_FIRMWARE)) {
        return MockCommand::Start_flash_firmware;
    } else if (0 == cmd.compare(CMD_FLASH_FIRMWARE)) {
        return MockCommand::Flash_firmware;
    } else if (0 == cmd.compare(CMD_START_FLASH_BOOTLOADER)) {
        return MockCommand::Start_flash_bootloader;
    } else if (0 == cmd.compare(CMD_FLASH_BOOTLOADER)) {
        return MockCommand::Flash_bootloader;
    } else if (0 == cmd.compare(CMD_START_BACKUP_FIRMWARE)) {
        return MockCommand::Start_backup_firmware;
    } else if (0 == cmd.compare(CMD_BACKUP_FIRMWARE)) {
        return MockCommand::Backup_firmware;
    } else if (0 == cmd.compare(CMD_SET_ASSISTED_PLATFORM_ID)) {
        return MockCommand::Set_assisted_platform_id;
    } else if (0 == cmd.compare(CMD_SET_PLATFORM_ID)) {
        return MockCommand::Set_platform_id;
    }
    return MockCommand::Any_command;
}

enum class MockResponse {
    // generic responses

    Normal,
    No_payload,
    No_JSON,
    Nack,
    Invalid,

    // specific response configurations to a particular test case or command

    Platform_config_embedded_app,
    Platform_config_assisted_app,
    Platform_config_assisted_no_board,
    Platform_config_embedded_bootloader,
    Platform_config_assisted_bootloader,

    Flash_firmware_resend_chunk,
    Flash_firmware_memory_error,
    Flash_firmware_invalid_cmd_sequence,
    Flash_firmware_invalid_value,

    Start_flash_firmware_invalid,
    Start_flash_firmware_invalid_command,
    Start_flash_firmware_too_large
};
Q_ENUM_NS(MockResponse)

enum class MockVersion {
    Version_1,
    Version_2
};
Q_ENUM_NS(MockVersion)

// these are global constants for testing
namespace test_commands {

// matches strings like [$...] or ["$..."], where the ... is captured in group 1 (the whole match is in group 0)
// usage:
//     "string_data":"[$replacement_string]"    ->   "string_data":"abc"
//     "integer_data":["$replacement_string"]   ->   "integer_data":123
const QRegularExpression parameterRegex = QRegularExpression("\\[\"?\\$([^\\[\"]*)\"?\\]");

inline QByteArray normalizeMessage(const char* message) {
    return QJsonDocument::fromJson(message).toJson(QJsonDocument::Compact).append('\n');
}

const QByteArray ack = normalizeMessage(
R"({
    "ack":"[$request.cmd]",
    "payload":{"return_value":true,"return_string":"command valid"}
})");

const QByteArray nack_badly_formatted_json = normalizeMessage(
R"({
    "ack":"",
    "payload":{"return_value":false,"return_string":"badly formatted json"}
})");

const QByteArray nack_command_not_found = normalizeMessage(
R"({
    "ack":"[$request.cmd]",
    "payload":{"return_value":false,"return_string":"command not found"}
})");

const QByteArray get_firmware_info_request = normalizeMessage(
R"({
    "cmd":"get_firmware_info",
    "payload":{}
})");

const QByteArray get_firmware_info_response = normalizeMessage(
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

const QByteArray get_firmware_info_response_no_bootloader = normalizeMessage(
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

const QByteArray get_firmware_info_response_ver2_application = normalizeMessage(
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

const QByteArray get_firmware_info_response_ver2_bootloader = normalizeMessage(
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

const QByteArray get_firmware_info_response_ver2_invalid = normalizeMessage(
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

const QByteArray get_firmware_info_response_no_payload = normalizeMessage(
R"({
    "notification": {
        "value":"get_firmware_info"
    }
})");

const QByteArray get_firmware_info_response_invalid = normalizeMessage(
R"({
    "notification": {
        "value":"get_firmware_info",
        "payload": {
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

const QByteArray request_platform_id_request = normalizeMessage(
R"({
    "cmd":"request_platform_id",
    "payload":{}
})");

const QByteArray request_platform_id_response = normalizeMessage(
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

const QByteArray request_platform_id_response_ver2_embedded = normalizeMessage(
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

const QByteArray request_platform_id_response_ver2_assisted = normalizeMessage(
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

const QByteArray request_platform_id_response_ver2_assisted_without_board = normalizeMessage(
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

const QByteArray request_platform_id_response_ver2_assisted_invalid = normalizeMessage(
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

const QByteArray request_platform_id_response_ver2_embedded_bootloader = normalizeMessage(
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

const QByteArray request_platform_id_response_ver2_assisted_bootloader = normalizeMessage(
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

const QByteArray request_platform_id_response_no_payload = normalizeMessage(
R"({
    "notification":{
        "value":"platform_id"
    }
})");

const QByteArray request_platform_id_response_invalid = normalizeMessage(
R"({
    "notification":{
        "value":"platform_id",
        "payload":{
            "name":-1,
            "platform_id":"platform",
            "class_id":"class",
            "count":-1,
            "platform_id_version":-1,
            "verbose_name":-1
        }
    }
})");

const QByteArray request_platform_id_response_bootloader = normalizeMessage(
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

const QByteArray request_platform_id_response_bootloader_no_payload = normalizeMessage(
R"({
    "notification":{
        "value":"platform_id"
    }
})");

const QByteArray request_platform_id_response_bootloader_invalid = normalizeMessage(
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

const QByteArray start_bootloader_request = normalizeMessage(
R"({
    "cmd":"start_bootloader",
    "payload":{}
})");

const QByteArray start_bootloader_response = normalizeMessage(
R"({
    "notification":{
        "value":"start_bootloader",
        "payload":{
            "status":"ok"
        }
    }
})");

const QByteArray start_bootloader_response_no_payload = normalizeMessage(
R"({
    "notification":{
        "value":"start_bootloader"
    }
})");

const QByteArray start_bootloader_response_invalid = normalizeMessage(
R"({
    "notification":{
        "value":"start_bootloader",
        "payload":{
            "status":-1
        }
    }
})");

const QByteArray start_application_request = normalizeMessage(
R"({
    "cmd":"start_application",
    "payload":{}
})");

const QByteArray start_application_response = normalizeMessage(
R"({
    "notification":{
        "value":"start_application",
        "payload":{
            "status":"ok"
        }
    }
})");

const QByteArray start_application_response_no_payload = normalizeMessage(
R"({
    "notification":{
        "value":"start_application"
    }
})");

const QByteArray start_application_response_invalid = normalizeMessage(
R"({
    "notification":{
        "value":"start_application",
        "payload":{
            "status":-1
        }
    }
})");

const QByteArray no_JSON_response = "notJSON";

const QByteArray flash_firmware_request = normalizeMessage(
R"({
    "cmd":"flash_firmware",
    "payload":{
        "chunk":{
            "number":["$request.payload.chunk.number"],
            "size":["$request.payload.chunk.size"],
            "crc":["$request.payload.chunk.crc"],
            "data":"[$request.payload.chunk.data]"
        }
    }
})");

const QByteArray flash_bootloader_request = normalizeMessage(
R"({
    "cmd":"flash_bootloader",
    "payload":{
        "chunk":{
            "number":["$request.payload.chunk.number"],
            "size":["$request.payload.chunk.size"],
            "crc":["$request.payload.chunk.crc"],
            "data":"[$request.payload.chunk.data]"
        }
    }
})");

const QByteArray start_flash_firmware_request = normalizeMessage(
R"({
    "cmd":"start_flash_firmware",
    "payload": {
        "size": ["$request.payload.size"],
        "chunks": ["$request.payload.chunks"],
        "md5": "[$request.payload.md5]"
    }
})");

const QByteArray start_flash_bootloader_request = normalizeMessage(
R"({
    "cmd":"start_flash_bootloader",
    "payload": {
        "size": ["$request.payload.size"],
        "chunks": ["$request.payload.chunks"],
        "md5": "[$request.payload.md5]"
    }
})");

const QByteArray start_flash_firmware_response = normalizeMessage(
R"({
    "notification":{
        "value":"start_flash_firmware",
        "payload":{
            "status":"ok"
        }
    }
})");

const QByteArray start_flash_bootloader_response = normalizeMessage(
R"({
    "notification":{
        "value":"start_flash_bootloader",
        "payload":{
            "status":"ok"
        }
    }
})");

const QByteArray start_flash_firmware_response_invalid = normalizeMessage(
R"({
    "notification":{
        "value":"start_flash_firmware",
        "payload":{
            "status":-1
        }
    }
})");

const QByteArray start_flash_firmware_response_invalid_command = normalizeMessage(
R"({
    "notification":{
        "value":"start_flash_firmware",
        "payload":{
            "status":"invalid_command"
        }
    }
})");

const QByteArray start_flash_firmware_response_firmware_too_large = normalizeMessage(
R"({
    "notification":{
        "value":"start_flash_firmware",
        "payload":{
            "status":"firmware_too_large"
        }
    }
})");

const QByteArray flash_firmware_response = normalizeMessage(
R"({
    "notification":{
        "value":"flash_firmware",
        "payload":{
            "status":"ok"
        }
    }
})");

const QByteArray flash_firmware_response_resend_chunk = normalizeMessage(
R"({
    "notification":{
        "value":"flash_firmware",
        "payload":{
            "status":"resend_chunk"
        }
    }
})");

const QByteArray flash_firmware_response_memory_error = normalizeMessage(
R"({
    "notification":{
        "value":"flash_firmware",
        "payload":{
            "status":"flash_memory_error"
        }
    }
})");

const QByteArray flash_firmware_response_invalid_cmd_sequence = normalizeMessage(
R"({
    "notification":{
        "value":"flash_firmware",
        "payload":{
            "status":"invalid_cmd_sequence"
        }
    }
})");

const QByteArray flash_firmware_invalid_value = normalizeMessage(
R"({
    "notification":{
        "value":"flash_firmware",
        "payload":{
            "status":-1
        }
    }
})");

const QByteArray flash_bootloader_response = normalizeMessage(
R"({
    "notification":{
        "value":"flash_bootloader",
        "payload":{
            "status":"ok"
        }
    }
})");

const QByteArray set_assisted_platform_id_response = normalizeMessage(
R"({
    "notification":{
        "value":"set_assisted_platform_id",
        "payload":{
            "status":"ok"
        }
    }
})");

const QByteArray start_backup_firmware_request = normalizeMessage(R"({"cmd":"start_backup_firmware","payload":{}})");

const QByteArray start_backup_firmware_response = normalizeMessage(
R"({
    "notification":{
        "value":"start_backup_firmware",
        "payload": {
            "size":["$response.payload.size"],
            "chunks":["$response.payload.chunks"]
        }
    }
})");

const QByteArray backup_firmware_request_init = normalizeMessage(
R"({
    "notification":{
        "value":"backup_firmware",
        "payload":{
            "status":"init"
        }
    }
})");

const QByteArray backup_firmware_request = normalizeMessage(
R"({
    "notification":{
        "value":"backup_firmware",
        "payload":{
            "status":"ok"
        }
    }
})");

const QByteArray backup_firmware_response = normalizeMessage(
R"({
    "notification":{
        "value":"backup_firmware",
        "payload":{
            "chunk":{
                "number":["$response.payload.chunk.number"],
                "size":["$response.payload.chunk.size"],
                "crc":["$response.payload.chunk.crc"],
                "data":"[$response.payload.chunk.data]"
            }
        }
    }
})");

} // namespace strata::device::test_commands
}
