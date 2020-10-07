#ifndef DEVICEOPERATIONS_CONSTANTS_H
#define DEVICEOPERATIONS_CONSTANTS_H

#include <chrono>
#include <QString>

namespace strata {

constexpr std::chrono::milliseconds RESPONSE_TIMEOUT(1000);

constexpr uint MAX_GET_FW_INFO_RETRIES(5);

constexpr uint MAX_CHUNK_RETRIES(1);

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
constexpr const char* const JSON_CHUNK = "chunk";
constexpr const char* const JSON_CHUNKS = "chunks";
constexpr const char* const JSON_NUMBER = "number";
constexpr const char* const JSON_SIZE = "size";
constexpr const char* const JSON_CRC = "crc";
constexpr const char* const JSON_DATA = "data";
constexpr const char* const JSON_STATUS = "status";
constexpr const char* const JSON_OK = "ok";
constexpr const char* const JSON_RESEND_CHUNK = "resend_chunk";
constexpr const char* const JSON_MD5 = "md5";

const QString QSTR_BOOTLOADER("Bootloader");

constexpr const char* const CSTR_NO_FIRMWARE = "no_firmware";

}  // namespace

#endif // DEVICEOPERATIONS_CONSTANTS_H
