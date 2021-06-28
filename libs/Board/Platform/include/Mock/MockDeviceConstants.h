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

constexpr const char* const RES_NORMAL          = "Normal";
constexpr const char* const RES_NO_PAYLOAD      = "No Payload";
constexpr const char* const RES_NO_JSON         = "No JSON";
constexpr const char* const RES_NACK            = "No JSON";
constexpr const char* const RES_INVALID         = "Invalid";
constexpr const char* const RES_PLATFORM_CONFIG_BOOTLOADER          = "Platform Config: Bootloader";
constexpr const char* const RES_PLATFORM_CONFIG_BOOTLOADER_INVALID  = "Platform Config: Bootloader Invalid";
constexpr const char* const RES_PLATFORM_CONFIG_EMBEDDED_APP        = "Platform Config: Embedded App";
constexpr const char* const RES_PLATFORM_CONFIG_ASSISTED_APP        = "Platform Config: Assisted App";
constexpr const char* const RES_PLATFORM_CONFIG_ASSISTED_NO_BOARD   = "Platform Config: Assisted No Board";
constexpr const char* const RES_PLATFORM_CONFIG_EMBEDDED_BOOTLOADER = "Platform Config: Embedded Bootloader";
constexpr const char* const RES_PLATFORM_CONFIG_ASSISTED_BOOTLOADER = "Platform Config: Assisted Bootloader";
constexpr const char* const RES_FLASH_FIRMWARE_RESEND_CHUNK         = "Flash Firmware: Resend Chunk";
constexpr const char* const RES_FLASH_FIRMWARE_MEMORY_ERROR         = "Flash Firmware: Memory Error";
constexpr const char* const RES_FLASH_FIRMWARE_INVALID_CMD_SEQUENCE = "Flash Firmware: Invalid Cmd Sequence";
constexpr const char* const RES_FLASH_FIRMWARE_INVALID_VALUE        = "Flash Firmware: Invalid Value";
constexpr const char* const RES_START_FLASH_FIRMWARE_INVALID        = "Start Flash Firmware: Invalid";
constexpr const char* const RES_START_FLASH_FIRMWARE_INVALID_COMMAND = "Start Flash Firmware: Invalid command";
constexpr const char* const RES_START_FLASH_FIRMWARE_TOO_LARGE      = "Start Flash Firmware: Firmware too large";
constexpr const char* const RES_START_BACKUP_FIRMWARE_NO_FW         = "Backup Firmware: No firmware";
constexpr const char* const RES_BACKUP_FIRMWARE_NO_FW               = "Start Backup Firmware: No firmware";

constexpr const char* const VERSION_1        = "Version 1 (non-OTA)";
constexpr const char* const VERSION_2        = "Version 2 (OTA)";

Q_NAMESPACE

enum class MockCommand {
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

inline bool mockCommandConvertStringToEnum(const std::string& stringCommand, MockCommand& enumCommand) {
    if (0 == stringCommand.compare(CMD_GET_FIRMWARE_INFO)) {
        enumCommand = MockCommand::Get_firmware_info;
    } else if (0 == stringCommand.compare(CMD_REQUEST_PLATFORM_ID)) {
        enumCommand = MockCommand::Request_platform_id;
    } else if (0 == stringCommand.compare(CMD_START_BOOTLOADER)) {
        enumCommand = MockCommand::Start_bootloader;
    } else if (0 == stringCommand.compare(CMD_START_APPLICATION)) {
        enumCommand = MockCommand::Start_application;
    } else if (0 == stringCommand.compare(CMD_START_FLASH_FIRMWARE)) {
        enumCommand = MockCommand::Start_flash_firmware;
    } else if (0 == stringCommand.compare(CMD_FLASH_FIRMWARE)) {
        enumCommand = MockCommand::Flash_firmware;
    } else if (0 == stringCommand.compare(CMD_START_FLASH_BOOTLOADER)) {
        enumCommand = MockCommand::Start_flash_bootloader;
    } else if (0 == stringCommand.compare(CMD_FLASH_BOOTLOADER)) {
        enumCommand = MockCommand::Flash_bootloader;
    } else if (0 == stringCommand.compare(CMD_START_BACKUP_FIRMWARE)) {
        enumCommand = MockCommand::Start_backup_firmware;
    } else if (0 == stringCommand.compare(CMD_BACKUP_FIRMWARE)) {
        enumCommand = MockCommand::Backup_firmware;
    } else if (0 == stringCommand.compare(CMD_SET_ASSISTED_PLATFORM_ID)) {
        enumCommand = MockCommand::Set_assisted_platform_id;
    } else if (0 == stringCommand.compare(CMD_SET_PLATFORM_ID)) {
        enumCommand = MockCommand::Set_platform_id;
    } else {
        return false;
    }
    return true;
}

inline QString mockCommandConvertEnumToString(const MockCommand& command) {
    switch(command) {
    case MockCommand::Get_firmware_info:
        return CMD_GET_FIRMWARE_INFO;
    case MockCommand::Request_platform_id:
        return CMD_REQUEST_PLATFORM_ID;
    case MockCommand::Start_bootloader:
        return CMD_START_BOOTLOADER;
    case MockCommand::Start_application:
        return CMD_START_APPLICATION;
    case MockCommand::Flash_firmware:
        return CMD_FLASH_FIRMWARE;
    case MockCommand::Flash_bootloader:
        return CMD_FLASH_BOOTLOADER;
    case MockCommand::Start_flash_firmware:
        return CMD_START_FLASH_FIRMWARE;
    case MockCommand::Start_flash_bootloader:
        return CMD_START_FLASH_BOOTLOADER;
    case MockCommand::Set_assisted_platform_id:
        return CMD_SET_ASSISTED_PLATFORM_ID;
    case MockCommand::Set_platform_id:
        return CMD_SET_PLATFORM_ID;
    case MockCommand::Start_backup_firmware:
        return CMD_START_BACKUP_FIRMWARE;
    case MockCommand::Backup_firmware:
        return CMD_BACKUP_FIRMWARE;
    }
    return "";
}

enum class MockResponse {
    // generic responses

    Normal,
    No_payload,
    No_JSON,
    Nack,
    Invalid,

    // specific response configurations to a particular test case or command

    Platform_config_bootloader,
    Platform_config_bootloader_invalid,
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
    Start_flash_firmware_too_large,

    Start_backup_firmware_no_fw,

    Backup_firmware_no_fw
};
Q_ENUM_NS(MockResponse)

inline QString mockResponseConvertEnumToString(const MockResponse& response) {
    switch(response) {
    case MockResponse::Normal:
        return RES_NORMAL;
    case MockResponse::No_payload:
        return RES_NO_PAYLOAD;
    case MockResponse::No_JSON:
        return RES_NO_JSON;
    case MockResponse::Nack:
        return RES_NACK;
    case MockResponse::Invalid:
        return RES_INVALID;
    case MockResponse::Platform_config_bootloader:
        return RES_PLATFORM_CONFIG_BOOTLOADER;
    case MockResponse::Platform_config_bootloader_invalid:
        return RES_PLATFORM_CONFIG_BOOTLOADER_INVALID;
    case MockResponse::Platform_config_embedded_app:
        return RES_PLATFORM_CONFIG_EMBEDDED_APP;
    case MockResponse::Platform_config_assisted_app:
        return RES_PLATFORM_CONFIG_ASSISTED_APP;
    case MockResponse::Platform_config_assisted_no_board:
        return RES_PLATFORM_CONFIG_ASSISTED_NO_BOARD;
    case MockResponse::Platform_config_embedded_bootloader:
        return RES_PLATFORM_CONFIG_EMBEDDED_BOOTLOADER;
    case MockResponse::Platform_config_assisted_bootloader:
        return RES_PLATFORM_CONFIG_ASSISTED_BOOTLOADER;
    case MockResponse::Flash_firmware_resend_chunk:
        return RES_FLASH_FIRMWARE_RESEND_CHUNK;
    case MockResponse::Flash_firmware_memory_error:
        return RES_FLASH_FIRMWARE_MEMORY_ERROR;
    case MockResponse::Flash_firmware_invalid_cmd_sequence:
        return RES_FLASH_FIRMWARE_INVALID_CMD_SEQUENCE;
    case MockResponse::Flash_firmware_invalid_value:
        return RES_FLASH_FIRMWARE_INVALID_VALUE;
    case MockResponse::Start_flash_firmware_invalid:
        return RES_START_FLASH_FIRMWARE_INVALID;
    case MockResponse::Start_flash_firmware_invalid_command:
        return RES_START_FLASH_FIRMWARE_INVALID_COMMAND;
    case MockResponse::Start_flash_firmware_too_large:
        return RES_START_FLASH_FIRMWARE_TOO_LARGE;
    case MockResponse::Start_backup_firmware_no_fw:
        return RES_START_BACKUP_FIRMWARE_NO_FW;
    case MockResponse::Backup_firmware_no_fw:
        return RES_BACKUP_FIRMWARE_NO_FW;
    }

    return "";
}

enum class MockVersion {
    Version_1,
    Version_2
};
Q_ENUM_NS(MockVersion)

inline QString mockVersionConvertEnumToString(const MockVersion& version) {
    switch(version) {
    case MockVersion::Version_1:
        return VERSION_1;
    case MockVersion::Version_2:
        return VERSION_2;
    }
    return "";
}

namespace mock_firmware_constants {

const QByteArray mockFirmwareData = R"(Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec ac lobortis tellus. Sed mattis ultricies porta. Aliquam fringilla hendrerit felis, in ultricies odio. Quisque sit amet ex lacinia, dignissim ex et, mollis est. Pellentesque imperdiet nulla vitae velit lacinia fringilla. Integer molestie commodo felis, non condimentum ipsum aliquam ut. Sed vel orci dui.

Pellentesque massa risus, vulputate nec accumsan sed, cursus sit amet metus. Maecenas sed lobortis elit. Donec quis lectus finibus, condimentum turpis at, blandit tortor. Praesent molestie tortor eu diam blandit, et varius nunc rutrum. Vestibulum non placerat massa. Aenean vulputate nibh id pulvinar luctus. Pellentesque facilisis eros magna, et dapibus nulla vestibulum sit amet. Etiam sit amet mattis erat. In eu nulla sollicitudin, dictum dolor viverra, aliquam lectus. In nec odio a tortor tincidunt finibus. Proin efficitur, tortor eget rhoncus scelerisque, dolor dolor viverra sem, vitae maximus ante dui non nulla. Nullam fringilla eros id velit egestas, ut rutrum orci pretium. Sed volutpat quis libero quis lacinia.

Ut non dapibus turpis. Vivamus at mauris ac ligula pretium iaculis ut sed nibh. Etiam bibendum scelerisque facilisis. Mauris sit amet vulputate turpis. Aliquam lobortis quam sit amet urna volutpat suscipit eget vel nisi. Donec pharetra a purus eu imperdiet. Aenean vel sem et dolor sollicitudin tempus et vel erat. Fusce dictum leo eu tellus facilisis, mollis cursus sem lobortis. Donec tempor, urna a congue interdum, elit risus malesuada est, et auctor nulla felis ut tortor. Suspendisse congue laoreet elit in mollis.

Integer tempor purus mauris, sed elementum neque venenatis et. Fusce sed libero diam. Sed lacinia gravida augue id molestie. Cras at dapibus urna, quis ornare leo. Vivamus viverra consectetur dictum. Praesent sit amet metus tristique nisi tempor pretium. Pellentesque scelerisque augue a ultrices mattis. In hac habitasse platea dictumst. Phasellus sit amet velit odio. Pellentesque vitae ante nec felis commodo condimentum ac et est. Aliquam sollicitudin tempor tellus et varius.

Pellentesque ut venenatis magna. Sed feugiat neque eget ipsum egestas, vel hendrerit lectus cursus. Nulla vitae lacus sodales dui mollis vehicula ut a massa. Sed ultrices erat non volutpat ultrices. Nullam lobortis ultrices lorem, et laoreet ligula vulputate vel. Nulla pharetra quam eget justo egestas dapibus. Nam at fringilla mi, vel hendrerit dolor. Nam nisi dolor, dictum eu malesuada ut, mollis ut metus. Duis porttitor sollicitudin scelerisque. Nulla finibus augue ac sem euismod, nec condimentum dui pulvinar. Cras ullamcorper purus sed augue feugiat rutrum. Morbi consectetur non dui ac viverra. Pellentesque id elementum tellus. Quisque at nulla eget purus porttitor vehicula eu at nulla. Donec pulvinar urna ac tellus malesuada, sit amet dignissim mi vulputate.

Curabitur ultrices quam a sem maximus imperdiet. Cras non est urna. Nam facilisis libero ac nibh tincidunt, venenatis aliquam augue tempus. Pellentesque ultricies arcu in magna ornare tincidunt. Nunc non commodo velit. Nulla venenatis lacus eget fermentum hendrerit. Phasellus malesuada sit amet metus id sodales. Suspendisse non tincidunt quam.

Nulla ac velit ac augue hendrerit venenatis. Etiam odio mi, pharetra et augue quis, malesuada laoreet ligula. Curabitur ligula purus, fermentum eu urna vel, ultrices lacinia neque. Nunc fermentum, nunc eu porttitor ornare, purus risus mollis erat, vel dictum arcu nibh nec enim. Quisque sapien nunc, laoreet eu semper sit amet, feugiat sed lectus. Nullam eleifend fringilla aliquam. Cras accumsan egestas rutrum. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Proin a lorem vel odio mattis porttitor. Fusce dapibus rutrum est sed vulputate. Aliquam consectetur pulvinar elit eu eleifend. Nullam eleifend odio ante, a imperdiet ex ornare quis. Duis dolor nisi, consequat at egestas ut, bibendum id purus. Fusce semper cursus sapien, semper luctus nisl gravida nec.

Donec ultricies tortor odio, a tristique massa malesuada eget. Aliquam in ipsum placerat, fermentum nisl eget, posuere nulla. Cras sagittis suscipit augue nec dictum. Quisque in ligula et lorem dapibus accumsan nec sed purus. Pellentesque libero purus, auctor quis pretium eget, maximus id libero. Nulla sit amet vehicula enim, eu maximus erat. Donec felis sapien, fermentum non tortor at, fringilla dapibus quam. Morbi et placerat felis. Proin fermentum nulla nec libero commodo, vitae fermentum dolor euismod. Pellentesque ut libero eu est scelerisque egestas. Nunc quam elit, lobortis sit amet facilisis eget, ullamcorper eu nibh. Proin tempus lorem vel velit hendrerit, vitae consectetur quam porttitor. Morbi venenatis enim at scelerisque cursus. Maecenas dictum, tortor sit amet tempor varius, tortor lorem sodales ipsum, non aliquet lacus orci porta neque.

Curabitur tempus finibus leo, sed hendrerit elit mattis et. Etiam in semper risus. Duis dui lacus, porttitor id tincidunt nec, ullamcorper rhoncus nulla.)";

// size of chunk in bytes
constexpr int CHUNK_SIZE = 256;

} // namespace mock_firmware_constants

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

const QByteArray request_platform_id_response_bootloader_invalid = normalizeMessage(
R"({
    "notification":{
        "value":"bootloader_id",
        "payload":{
            "name":-1,
            "platform_id":"bootloader",
            "class_id":"class",
            "count":-1,
            "platform_id_version":-1,
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
        "value":"[$request.cmd]",
        "payload": {
            "size":["$firmware.size"],
            "chunks":["$firmware.chunks"]
        }
    }
})");

const QByteArray backup_firmware_request_init = normalizeMessage(R"({"cmd":"backup_firmware","payload":{"status":"init"}})");

const QByteArray backup_firmware_request = normalizeMessage(R"({"cmd":"backup_firmware","payload":{"status":"ok"}})");

const QByteArray backup_firmware_response = normalizeMessage(
R"({
    "notification":{
        "value":"[$request.cmd]",
        "payload":{
            "chunk":{
                "number":["$chunk.number"],
                "size":["$chunk.size"],
                "crc":["$chunk.crc"],
                "data":"[$chunk.data]"
            }
        }
    }
})");

const QMap<MockVersion, QMap<MockCommand, QMap<MockResponse, QByteArray> > > mockResponsesMap = {
    // version 1.0
    {{MockVersion::Version_1, {
        {MockCommand::Get_firmware_info, {
            {MockResponse::Normal, get_firmware_info_response},
            {MockResponse::No_payload, get_firmware_info_response_no_payload},
            {MockResponse::Invalid, get_firmware_info_response_invalid}
        }},

        {MockCommand::Request_platform_id, {
            {MockResponse::Normal, request_platform_id_response},
            {MockResponse::No_payload, request_platform_id_response_no_payload},
            {MockResponse::Invalid, request_platform_id_response_invalid},
            {MockResponse::Platform_config_bootloader, request_platform_id_response_bootloader},
            {MockResponse::Platform_config_bootloader_invalid, request_platform_id_response_bootloader_invalid}
        }}
    }},

    // version 2.0
    {MockVersion::Version_2, {
        {MockCommand::Get_firmware_info, {
            {MockResponse::Normal, get_firmware_info_response},
            {MockResponse::No_payload, get_firmware_info_response_no_payload},
            {MockResponse::Invalid, get_firmware_info_response_ver2_invalid},
            {MockResponse::Platform_config_embedded_app, get_firmware_info_response_ver2_application},
            {MockResponse::Platform_config_assisted_app, get_firmware_info_response_ver2_application},
            {MockResponse::Platform_config_assisted_no_board, get_firmware_info_response_ver2_application},
            {MockResponse::Platform_config_embedded_bootloader, get_firmware_info_response_ver2_bootloader},
            {MockResponse::Platform_config_assisted_bootloader, get_firmware_info_response_ver2_bootloader}
        }},

        {MockCommand::Request_platform_id, {
            {MockResponse::Normal, request_platform_id_response},
            {MockResponse::No_payload, request_platform_id_response_no_payload},
            {MockResponse::Invalid, request_platform_id_response_invalid},
            {MockResponse::Platform_config_embedded_app, request_platform_id_response_ver2_embedded},
            {MockResponse::Platform_config_assisted_app, request_platform_id_response_ver2_assisted},
            {MockResponse::Platform_config_assisted_no_board, request_platform_id_response_ver2_assisted_without_board},
            {MockResponse::Platform_config_embedded_bootloader, request_platform_id_response_ver2_embedded_bootloader},
            {MockResponse::Platform_config_assisted_bootloader, request_platform_id_response_ver2_assisted_bootloader}
        }},

        {MockCommand::Start_bootloader, {
            {MockResponse::Normal, start_bootloader_response},
            {MockResponse::No_payload, start_bootloader_response_no_payload},
            {MockResponse::Invalid, start_bootloader_response_invalid}
        }},

        {MockCommand::Start_application, {
            {MockResponse::Normal, start_application_response},
            {MockResponse::No_payload, start_application_response_no_payload},
            {MockResponse::Invalid, start_application_response_invalid}
        }},

        {MockCommand::Flash_firmware, {
            {MockResponse::Normal, flash_firmware_response},
            {MockResponse::Flash_firmware_resend_chunk, flash_firmware_response_resend_chunk},
            {MockResponse::Flash_firmware_memory_error, flash_firmware_response_memory_error},
            {MockResponse::Flash_firmware_invalid_cmd_sequence, flash_firmware_response_invalid_cmd_sequence},
            {MockResponse::Flash_firmware_invalid_value, flash_firmware_invalid_value}
        }},

        {MockCommand::Flash_bootloader, {
            {MockResponse::Normal, flash_bootloader_response}
        }},

        {MockCommand::Start_flash_firmware, {
            {MockResponse::Normal, start_flash_firmware_response},
            {MockResponse::Start_flash_firmware_invalid, start_flash_firmware_response_invalid},
            {MockResponse::Start_flash_firmware_invalid_command, start_flash_firmware_response_invalid_command},
            {MockResponse::Start_flash_firmware_too_large, start_flash_firmware_response_firmware_too_large}
        }},

        {MockCommand::Start_flash_bootloader, {
            {MockResponse::Normal, start_flash_bootloader_response}
        }},

        {MockCommand::Set_assisted_platform_id, {
            {MockResponse::Normal, set_assisted_platform_id_response}
        }},

        {MockCommand::Start_backup_firmware, {
            {MockResponse::Normal, start_backup_firmware_response},
            {MockResponse::Start_backup_firmware_no_fw, start_backup_firmware_response}
        }},

        {MockCommand::Backup_firmware, {
            {MockResponse::Normal, backup_firmware_response},
            {MockResponse::Backup_firmware_no_fw, backup_firmware_response}
        }}
    }}}
};

} // namespace strata::device::test_commands

inline QList<MockVersion> mockSupportedVersions() {
    return test_commands::mockResponsesMap.keys();
}

inline QList<MockCommand> mockSupportedCommands(const MockVersion& version) {
    auto versionIter = test_commands::mockResponsesMap.constFind(version);
    if (versionIter != test_commands::mockResponsesMap.constEnd()) {
        return versionIter.value().keys();
    }
    return QList<MockCommand>();
}

inline QList<MockResponse> mockSupportedResponses(const MockVersion& version, const MockCommand& command) {
    auto versionIter = test_commands::mockResponsesMap.constFind(version);
    if (versionIter != test_commands::mockResponsesMap.constEnd()) {
        auto commandIter = versionIter.value().constFind(command);
        if (commandIter != versionIter.value().constEnd()) {
            return commandIter.value().keys();
        }
    }
    return QList<MockResponse>();
}

}
