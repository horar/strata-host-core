#pragma once

#include <chrono>

namespace strata::device::command {

constexpr std::chrono::milliseconds ACK_TIMEOUT(1000);
constexpr std::chrono::milliseconds NOTIFICATION_TIMEOUT(2000);

constexpr unsigned int MAX_CHUNK_RETRIES(1);

constexpr int CONTROLLER_TYPE_EMBEDDED(1);
constexpr int CONTROLLER_TYPE_ASSISTED(2);

constexpr const char* const JSON_ACK = "ack";
constexpr const char* const JSON_CMD = "cmd";
constexpr const char* const JSON_FLASH_FIRMWARE = "flash_firmware";
constexpr const char* const JSON_FLASH_BOOTLOADER = "flash_bootloader";
constexpr const char* const JSON_PAYLOAD = "payload";
constexpr const char* const JSON_VALUE = "value";
constexpr const char* const JSON_RETURN_VALUE = "return_value";
constexpr const char* const JSON_RETURN_STRING = "return_string";
constexpr const char* const JSON_NOTIFICATION = "notification";
constexpr const char* const JSON_BOOTLOADER = "bootloader";
constexpr const char* const JSON_APPLICATION = "application";
constexpr const char* const JSON_VERSION = "version";
constexpr const char* const JSON_NAME = "name";
constexpr const char* const JSON_PLATFORM_ID = "platform_id";
constexpr const char* const JSON_CLASS_ID = "class_id";
constexpr const char* const JSON_BOARD_COUNT = "board_count";
constexpr const char* const JSON_FW_CLASS_ID = "fw_class_id";
constexpr const char* const JSON_CNTRL_PLATFORM_ID = "controller_platform_id";
constexpr const char* const JSON_CNTRL_CLASS_ID = "controller_class_id";
constexpr const char* const JSON_CNTRL_BOARD_COUNT = "controller_board_count";
constexpr const char* const JSON_CONTROLLER_TYPE = "controller_type";
constexpr const char* const JSON_CHUNK = "chunk";
constexpr const char* const JSON_CHUNKS = "chunks";
constexpr const char* const JSON_NUMBER = "number";
constexpr const char* const JSON_SIZE = "size";
constexpr const char* const JSON_CRC = "crc";
constexpr const char* const JSON_DATA = "data";
constexpr const char* const JSON_STATUS = "status";
constexpr const char* const JSON_OK = "ok";
constexpr const char* const JSON_FAILED = "failed";
constexpr const char* const JSON_ALREADY_INITIALIZED = "already_initialized";
constexpr const char* const JSON_BOARD_NOT_CONNECTED = "board_not_connected";
constexpr const char* const JSON_RESEND_CHUNK = "resend_chunk";
constexpr const char* const JSON_MD5 = "md5";
constexpr const char* const JSON_API_VERSION = "api_version";
constexpr const char* const JSON_ACTIVE = "active";
constexpr const char* const JSON_PLATF_ID_VER = "platform_id_version";

constexpr const char* const CSTR_NO_FIRMWARE = "no_firmware";
constexpr const char* const CSTR_API_2_0 = "2.0";
constexpr const char* const CSTR_BOOTLOADER = "bootloader";
constexpr const char* const CSTR_NAME_BOOTLOADER = "Bootloader";

}  // namespace
