/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QObject>
#include <QString>
#include <QByteArray>
#include <QRegularExpression>
#include <QMap>
#include <QList>

namespace strata::device {

constexpr unsigned MAX_STORED_MESSAGES = 4096;

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

class MockCommandUtils {
public:
    static bool convertStringToEnum(const std::string& stringCommand, MockCommand& enumCommand);
    static QString convertEnumToString(const MockCommand& command);
private:
    static constexpr const char* const CMD_GET_FIRMWARE_INFO        = "get_firmware_info";
    static constexpr const char* const CMD_REQUEST_PLATFORM_ID      = "request_platform_id";
    static constexpr const char* const CMD_START_BOOTLOADER         = "start_bootloader";
    static constexpr const char* const CMD_START_APPLICATION        = "start_application";
    static constexpr const char* const CMD_START_FLASH_FIRMWARE     = "start_flash_firmware";
    static constexpr const char* const CMD_FLASH_FIRMWARE           = "flash_firmware";
    static constexpr const char* const CMD_START_FLASH_BOOTLOADER   = "start_flash_bootloader";
    static constexpr const char* const CMD_FLASH_BOOTLOADER         = "flash_bootloader";
    static constexpr const char* const CMD_START_BACKUP_FIRMWARE    = "start_backup_firmware";
    static constexpr const char* const CMD_BACKUP_FIRMWARE          = "backup_firmware";
    static constexpr const char* const CMD_SET_ASSISTED_PLATFORM_ID = "set_assisted_platform_id";
    static constexpr const char* const CMD_SET_PLATFORM_ID          = "set_platform_id";
};

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
    Start_flash_firmware_too_large
};
Q_ENUM_NS(MockResponse)

class MockResponseUtils {
public:
    static QString convertEnumToString(const MockResponse& response);
private:
    static constexpr const char* const RES_NORMAL          = "Normal";
    static constexpr const char* const RES_NO_PAYLOAD      = "No Payload";
    static constexpr const char* const RES_NO_JSON         = "No JSON";
    static constexpr const char* const RES_NACK            = "Nack";
    static constexpr const char* const RES_INVALID         = "Invalid";
    static constexpr const char* const RES_PLATFORM_CONFIG_BOOTLOADER           = "Platform Config: Bootloader";
    static constexpr const char* const RES_PLATFORM_CONFIG_BOOTLOADER_INVALID   = "Platform Config: Bootloader Invalid";
    static constexpr const char* const RES_PLATFORM_CONFIG_EMBEDDED_APP         = "Platform Config: Embedded App";
    static constexpr const char* const RES_PLATFORM_CONFIG_ASSISTED_APP         = "Platform Config: Assisted App";
    static constexpr const char* const RES_PLATFORM_CONFIG_ASSISTED_NO_BOARD    = "Platform Config: Assisted No Board";
    static constexpr const char* const RES_PLATFORM_CONFIG_EMBEDDED_BOOTLOADER  = "Platform Config: Embedded Bootloader";
    static constexpr const char* const RES_PLATFORM_CONFIG_ASSISTED_BOOTLOADER  = "Platform Config: Assisted Bootloader";
    static constexpr const char* const RES_FLASH_FIRMWARE_RESEND_CHUNK          = "Flash Firmware: Resend Chunk";
    static constexpr const char* const RES_FLASH_FIRMWARE_MEMORY_ERROR          = "Flash Firmware: Memory Error";
    static constexpr const char* const RES_FLASH_FIRMWARE_INVALID_CMD_SEQUENCE  = "Flash Firmware: Invalid Cmd Sequence";
    static constexpr const char* const RES_FLASH_FIRMWARE_INVALID_VALUE         = "Flash Firmware: Invalid Value";
    static constexpr const char* const RES_START_FLASH_FIRMWARE_INVALID         = "Start Flash Firmware: Invalid";
    static constexpr const char* const RES_START_FLASH_FIRMWARE_INVALID_COMMAND = "Start Flash Firmware: Invalid command";
    static constexpr const char* const RES_START_FLASH_FIRMWARE_TOO_LARGE       = "Start Flash Firmware: Firmware too large";
};

// When board receives command, it may send notification (one or more).
enum class MockNotification {
    BootloaderActive
};
Q_ENUM_NS(MockNotification)

enum class MockVersion {
    Version_1,
    Version_2
};
Q_ENUM_NS(MockVersion)

class MockVersionUtils {
public:
    static QString convertEnumToString(const MockVersion& version);
private:
    static constexpr const char* const VERSION_1 = "Version 1 (non-OTA)";
    static constexpr const char* const VERSION_2 = "Version 2 (OTA)";
};

namespace mock_firmware_constants {

// size of chunk in bytes
constexpr int CHUNK_SIZE = 256;
constexpr quint32 firmwareBufferSize = (20 * mock_firmware_constants::CHUNK_SIZE / sizeof(quint32) - 1); //represents 20 chunks of firmware
constexpr quint32 bootloaderBufferSize = (10 * mock_firmware_constants::CHUNK_SIZE / sizeof(quint32) - 1); //represents 10 chunks

} // namespace mock_firmware_constants

class TestCommands {
private:
    static QByteArray normalizeMessage(const char* message);
public:
    // matches strings like [$...] or ["$..."], where the ... is captured in group 1 (the whole match is in group 0)
    // usage:
    //     "string_data":"[$replacement_string]"    ->   "string_data":"abc"
    //     "integer_data":["$replacement_string"]   ->   "integer_data":123
    static const QRegularExpression parameterRegex;

    static const QByteArray ack;
    static const QByteArray nack_badly_formatted_json;
    static const QByteArray nack_command_not_found;
    static const QByteArray get_firmware_info_request;
    static const QByteArray get_firmware_info_response;
    static const QByteArray get_firmware_info_response_no_bootloader;
    static const QByteArray get_firmware_info_response_ver2_application;
    static const QByteArray get_firmware_info_response_ver2_bootloader;
    static const QByteArray get_firmware_info_response_ver2_invalid;
    static const QByteArray get_firmware_info_response_no_payload;
    static const QByteArray get_firmware_info_response_invalid;
    static const QByteArray request_platform_id_request;
    static const QByteArray request_platform_id_response;
    static const QByteArray request_platform_id_response_ver2_embedded;
    static const QByteArray request_platform_id_response_ver2_assisted;
    static const QByteArray request_platform_id_response_ver2_assisted_without_board;
    static const QByteArray request_platform_id_response_ver2_assisted_invalid;
    static const QByteArray request_platform_id_response_ver2_embedded_bootloader;
    static const QByteArray request_platform_id_response_ver2_assisted_bootloader;
    static const QByteArray request_platform_id_response_no_payload;
    static const QByteArray request_platform_id_response_invalid;
    static const QByteArray request_platform_id_response_bootloader;
    static const QByteArray request_platform_id_response_bootloader_invalid;
    static const QByteArray start_bootloader_request;
    static const QByteArray start_bootloader_response;
    static const QByteArray start_bootloader_response_no_payload;
    static const QByteArray start_bootloader_response_invalid;
    static const QByteArray start_application_request;
    static const QByteArray start_application_response;
    static const QByteArray start_application_response_no_payload;
    static const QByteArray start_application_response_invalid;
    static const QByteArray no_JSON_response;
    static const QByteArray flash_firmware_request;
    static const QByteArray flash_bootloader_request;
    static const QByteArray start_flash_firmware_request;
    static const QByteArray start_flash_bootloader_request;
    static const QByteArray start_flash_firmware_response;
    static const QByteArray start_flash_bootloader_response;
    static const QByteArray start_flash_firmware_response_invalid;
    static const QByteArray start_flash_firmware_response_invalid_command;
    static const QByteArray start_flash_firmware_response_firmware_too_large;
    static const QByteArray flash_firmware_response;
    static const QByteArray flash_firmware_response_resend_chunk;
    static const QByteArray flash_firmware_response_memory_error;
    static const QByteArray flash_firmware_response_invalid_cmd_sequence;
    static const QByteArray flash_firmware_invalid_value;
    static const QByteArray flash_bootloader_response;
    static const QByteArray set_assisted_platform_id_response;
    static const QByteArray start_backup_firmware_request;
    static const QByteArray start_backup_firmware_response;
    static const QByteArray backup_firmware_request_init;
    static const QByteArray backup_firmware_request;
    static const QByteArray backup_firmware_response;

    static const QByteArray notification_bootloader_active;

    static const QMap<MockVersion, QMap<MockCommand, QMap<MockResponse, QByteArray> > > mockResponsesMap;
    static const QMap<MockNotification, QByteArray> mockNotificationMap;
};

class MockUtils {
public:
    static QList<MockVersion> supportedVersions();
    static QList<MockCommand> supportedCommands(const MockVersion& version);
    static QList<MockResponse> supportedResponses(const MockVersion& version, const MockCommand& command);
};

}  // namespace strata::device
