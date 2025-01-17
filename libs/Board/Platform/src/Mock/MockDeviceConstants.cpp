/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include <Mock/MockDeviceConstants.h>

#include <QJsonDocument>

namespace strata::device {

// MockCommand

bool MockCommandUtils::convertStringToEnum(const std::string& stringCommand, MockCommand& enumCommand) {
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

QString MockCommandUtils::convertEnumToString(const MockCommand& command) {
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


// MockResponse

QString MockResponseUtils::convertEnumToString(const MockResponse& response) {
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
    }

    return "";
}


// MockVersion

QString MockVersionUtils::convertEnumToString(const MockVersion& version) {
    switch(version) {
    case MockVersion::Version_1:
        return VERSION_1;
    case MockVersion::Version_2:
        return VERSION_2;
    }
    return "";
}


// TestCommands

QByteArray TestCommands::normalizeMessage(const char* message) {
    return QJsonDocument::fromJson(message).toJson(QJsonDocument::Compact).append('\n');
}

const QRegularExpression TestCommands::parameterRegex = QRegularExpression("\\[\"?\\$([^\\[\"]*)\"?\\]");

const QByteArray TestCommands::ack = normalizeMessage(
R"({
    "ack":"[$request.cmd]",
    "payload":{"return_value":true,"return_string":"command valid"}
})");

const QByteArray TestCommands::nack_badly_formatted_json = normalizeMessage(
R"({
    "ack":"",
    "payload":{"return_value":false,"return_string":"badly formatted json"}
})");

const QByteArray TestCommands::nack_command_not_found = normalizeMessage(
R"({
    "ack":"[$request.cmd]",
    "payload":{"return_value":false,"return_string":"command not found"}
})");

const QByteArray TestCommands::get_firmware_info_request = normalizeMessage(
R"({
    "cmd":"get_firmware_info",
    "payload":{}
})");

const QByteArray TestCommands::get_firmware_info_response = normalizeMessage(
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

const QByteArray TestCommands::get_firmware_info_response_no_bootloader = normalizeMessage(
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

const QByteArray TestCommands::get_firmware_info_response_ver2_application = normalizeMessage(
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

const QByteArray TestCommands::get_firmware_info_response_ver2_bootloader = normalizeMessage(
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

const QByteArray TestCommands::get_firmware_info_response_ver2_invalid = normalizeMessage(
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

const QByteArray TestCommands::get_firmware_info_response_no_payload = normalizeMessage(
R"({
    "notification": {
        "value":"get_firmware_info"
    }
})");

const QByteArray TestCommands::get_firmware_info_response_invalid = normalizeMessage(
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

const QByteArray TestCommands::request_platform_id_request = normalizeMessage(
R"({
    "cmd":"request_platform_id",
    "payload":{}
})");

const QByteArray TestCommands::request_platform_id_response = normalizeMessage(
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

const QByteArray TestCommands::request_platform_id_response_ver2_embedded = normalizeMessage(
R"({
    "notification":{
        "value":"platform_id",
        "payload":{
            "name":"Mock Board",
            "controller_type":1,
            "platform_id":"00000000-0000-0000-0000-000000000000",
            "class_id":"00000000-0000-0000-0000-000000000000",
            "board_count":1
        }
    }
})");

const QByteArray TestCommands::request_platform_id_response_ver2_assisted = normalizeMessage(
R"({
    "notification":{
       "value":"platform_id",
       "payload":{
          "name":"Mock Board",
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

const QByteArray TestCommands::request_platform_id_response_ver2_assisted_without_board = normalizeMessage(
R"({
    "notification":{
       "value":"platform_id",
       "payload":{
          "name":"Mock Board",
          "controller_type":2,
          "controller_platform_id":"00000000-0000-0000-0000-000000000000",
          "controller_class_id":"00000000-0000-0000-0000-000000000000",
          "controller_board_count":1,
          "fw_class_id":"00000000-0000-0000-0000-000000000000"
       }
    }
})");

const QByteArray TestCommands::request_platform_id_response_ver2_assisted_invalid = normalizeMessage(
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

const QByteArray TestCommands::request_platform_id_response_ver2_embedded_bootloader = normalizeMessage(
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

const QByteArray TestCommands::request_platform_id_response_ver2_assisted_bootloader = normalizeMessage(
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

const QByteArray TestCommands::request_platform_id_response_no_payload = normalizeMessage(
R"({
    "notification":{
        "value":"platform_id"
    }
})");

const QByteArray TestCommands::request_platform_id_response_invalid = normalizeMessage(
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

const QByteArray TestCommands::request_platform_id_response_bootloader = normalizeMessage(
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

const QByteArray TestCommands::request_platform_id_response_bootloader_invalid = normalizeMessage(
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

const QByteArray TestCommands::start_bootloader_request = normalizeMessage(
R"({
    "cmd":"start_bootloader",
    "payload":{}
})");

const QByteArray TestCommands::start_bootloader_response = normalizeMessage(
R"({
    "notification":{
        "value":"start_bootloader",
        "payload":{
            "status":"ok"
        }
    }
})");

const QByteArray TestCommands::start_bootloader_response_no_payload = normalizeMessage(
R"({
    "notification":{
        "value":"start_bootloader"
    }
})");

const QByteArray TestCommands::start_bootloader_response_invalid = normalizeMessage(
R"({
    "notification":{
        "value":"start_bootloader",
        "payload":{
            "status":-1
        }
    }
})");

const QByteArray TestCommands::start_application_request = normalizeMessage(
R"({
    "cmd":"start_application",
    "payload":{}
})");

const QByteArray TestCommands::start_application_response = normalizeMessage(
R"({
    "notification":{
        "value":"start_application",
        "payload":{
            "status":"ok"
        }
    }
})");

const QByteArray TestCommands::start_application_response_no_payload = normalizeMessage(
R"({
    "notification":{
        "value":"start_application"
    }
})");

const QByteArray TestCommands::start_application_response_invalid = normalizeMessage(
R"({
    "notification":{
        "value":"start_application",
        "payload":{
            "status":-1
        }
    }
})");

const QByteArray TestCommands::no_JSON_response = "notJSON";

const QByteArray TestCommands::flash_firmware_request = normalizeMessage(
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

const QByteArray TestCommands::flash_bootloader_request = normalizeMessage(
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

const QByteArray TestCommands::start_flash_firmware_request = normalizeMessage(
R"({
    "cmd":"start_flash_firmware",
    "payload": {
        "size": ["$request.payload.size"],
        "chunks": ["$request.payload.chunks"],
        "md5": "[$request.payload.md5]"
    }
})");

const QByteArray TestCommands::start_flash_bootloader_request = normalizeMessage(
R"({
    "cmd":"start_flash_bootloader",
    "payload": {
        "size": ["$request.payload.size"],
        "chunks": ["$request.payload.chunks"],
        "md5": "[$request.payload.md5]"
    }
})");

const QByteArray TestCommands::start_flash_firmware_response = normalizeMessage(
R"({
    "notification":{
        "value":"start_flash_firmware",
        "payload":{
            "status":"ok"
        }
    }
})");

const QByteArray TestCommands::start_flash_bootloader_response = normalizeMessage(
R"({
    "notification":{
        "value":"start_flash_bootloader",
        "payload":{
            "status":"ok"
        }
    }
})");

const QByteArray TestCommands::start_flash_firmware_response_invalid = normalizeMessage(
R"({
    "notification":{
        "value":"start_flash_firmware",
        "payload":{
            "status":-1
        }
    }
})");

const QByteArray TestCommands::start_flash_firmware_response_invalid_command = normalizeMessage(
R"({
    "notification":{
        "value":"start_flash_firmware",
        "payload":{
            "status":"invalid_command"
        }
    }
})");

const QByteArray TestCommands::start_flash_firmware_response_firmware_too_large = normalizeMessage(
R"({
    "notification":{
        "value":"start_flash_firmware",
        "payload":{
            "status":"firmware_too_large"
        }
    }
})");

const QByteArray TestCommands::flash_firmware_response = normalizeMessage(
R"({
    "notification":{
        "value":"flash_firmware",
        "payload":{
            "status":"ok"
        }
    }
})");

const QByteArray TestCommands::flash_firmware_response_resend_chunk = normalizeMessage(
R"({
    "notification":{
        "value":"flash_firmware",
        "payload":{
            "status":"resend_chunk"
        }
    }
})");

const QByteArray TestCommands::flash_firmware_response_memory_error = normalizeMessage(
R"({
    "notification":{
        "value":"flash_firmware",
        "payload":{
            "status":"flash_memory_error"
        }
    }
})");

const QByteArray TestCommands::flash_firmware_response_invalid_cmd_sequence = normalizeMessage(
R"({
    "notification":{
        "value":"flash_firmware",
        "payload":{
            "status":"invalid_cmd_sequence"
        }
    }
})");

const QByteArray TestCommands::flash_firmware_invalid_value = normalizeMessage(
R"({
    "notification":{
        "value":"flash_firmware",
        "payload":{
            "status":-1
        }
    }
})");

const QByteArray TestCommands::flash_bootloader_response = normalizeMessage(
R"({
    "notification":{
        "value":"flash_bootloader",
        "payload":{
            "status":"ok"
        }
    }
})");

const QByteArray TestCommands::set_assisted_platform_id_response = normalizeMessage(
R"({
    "notification":{
        "value":"set_assisted_platform_id",
        "payload":{
            "status":"ok"
        }
    }
})");

const QByteArray TestCommands::start_backup_firmware_request = normalizeMessage(
R"({"cmd":"start_backup_firmware","payload":{}})");

const QByteArray TestCommands::start_backup_firmware_response = normalizeMessage(
R"({
    "notification":{
        "value":"[$request.cmd]",
        "payload": {
            "size":["$firmware.size"],
            "chunks":["$firmware.chunks"]
        }
    }
})");

const QByteArray TestCommands::backup_firmware_request_init = normalizeMessage(
R"({"cmd":"backup_firmware","payload":{"status":"init"}})");

const QByteArray TestCommands::backup_firmware_request = normalizeMessage(
R"({"cmd":"backup_firmware","payload":{"status":"ok"}})");

const QByteArray TestCommands::backup_firmware_response = normalizeMessage(
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

const QByteArray TestCommands::notification_bootloader_active =
'\n' + normalizeMessage(
R"({
    "notification":{
        "value":"bootloader_active",
        "payload":{}
    }
})");

const QMap<MockVersion, QMap<MockCommand, QMap<MockResponse, QByteArray> > > TestCommands::mockResponsesMap = {
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
            {MockResponse::Normal, get_firmware_info_response_ver2_application},
            {MockResponse::No_payload, get_firmware_info_response_no_payload},
            {MockResponse::Invalid, get_firmware_info_response_ver2_invalid},
            {MockResponse::Platform_config_embedded_app, get_firmware_info_response_ver2_application},
            {MockResponse::Platform_config_assisted_app, get_firmware_info_response_ver2_application},
            {MockResponse::Platform_config_assisted_no_board, get_firmware_info_response_ver2_application},
            {MockResponse::Platform_config_embedded_bootloader, get_firmware_info_response_ver2_bootloader},
            {MockResponse::Platform_config_assisted_bootloader, get_firmware_info_response_ver2_bootloader}
        }},

        {MockCommand::Request_platform_id, {
            {MockResponse::Normal, request_platform_id_response_ver2_embedded},
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
            {MockResponse::Normal, start_backup_firmware_response}
        }},

        {MockCommand::Backup_firmware, {
            {MockResponse::Normal, backup_firmware_response}
        }}
    }}}
};

const QMap<MockNotification, QByteArray> TestCommands::mockNotificationMap = {
    {MockNotification::BootloaderActive, notification_bootloader_active}
};


/// Mock

QList<MockVersion> MockUtils::supportedVersions() {
    return TestCommands::mockResponsesMap.keys();
}

QList<MockCommand> MockUtils::supportedCommands(const MockVersion& version) {
    auto versionIter = TestCommands::mockResponsesMap.constFind(version);
    if (versionIter != TestCommands::mockResponsesMap.constEnd()) {
        return versionIter.value().keys();
    }
    return QList<MockCommand>();
}

QList<MockResponse> MockUtils::supportedResponses(const MockVersion& version, const MockCommand& command) {
    auto versionIter = TestCommands::mockResponsesMap.constFind(version);
    if (versionIter != TestCommands::mockResponsesMap.constEnd()) {
        auto commandIter = versionIter.value().constFind(command);
        if (commandIter != versionIter.value().constEnd()) {
            QList<MockResponse> responses = commandIter.value().keys();
            // universal responses, place after MockResponse::Normal which is always first
            responses.insert(1, MockResponse::No_JSON);
            responses.insert(1, MockResponse::Nack);
            return responses;
        }
    }
    return QList<MockResponse>();
}

}  // namespace strata::device
