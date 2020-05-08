#ifndef FLASHER_CONSTANTS_H_
#define FLASHER_CONSTANTS_H_

#include <chrono>
#include <QString>

namespace strata {

constexpr std::chrono::milliseconds RESPONSE_TIMEOUT(1000);
constexpr std::chrono::milliseconds LAUNCH_DELAY(500);
constexpr std::chrono::milliseconds BOOTLOADER_START_DELAY(5500);

constexpr uint MAX_CHUNK_RETRIES(1);

constexpr const char* const CMD_GET_FIRMWARE_INFO = "{\"cmd\":\"get_firmware_info\"}";
constexpr const char* const CMD_REQUEST_PLATFORM_ID = "{\"cmd\":\"request_platform_id\"}";
constexpr const char* const CMD_UPDATE_FIRMWARE = "{\"cmd\":\"update_firmware\"}";
constexpr const char* const CMD_BACKUP_FIRMWARE = "{\"cmd\":\"backup_firmware\"}";
constexpr const char* const CMD_BACKUP_FIRMWARE_STATUS_OK = "{\"cmd\":\"backup_firmware\",\"payload\":{\"status\":\"ok\"}}";
constexpr const char* const CMD_BACKUP_FIRMWARE_STATUS_RESEND = "{\"cmd\":\"backup_firmware\",\"payload\":{\"status\":\"resend_chunk\"}}";
constexpr const char* const CMD_START_APPLICATION = "{\"cmd\":\"start_application\"}";

constexpr const char* const JSON_ACK = "ack";
constexpr const char* const JSON_CMD = "cmd";
constexpr const char* const JSON_GET_FW_INFO = "get_firmware_info";
constexpr const char* const JSON_REQ_PLATFORM_ID = "request_platform_id";
constexpr const char* const JSON_UPDATE_FIRMWARE = "update_firmware";
constexpr const char* const JSON_FLASH_FIRMWARE = "flash_firmware";
constexpr const char* const JSON_BACKUP_FIRMWARE = "backup_firmware";
constexpr const char* const JSON_START_APP = "start_application";
constexpr const char* const JSON_PAYLOAD = "payload";
constexpr const char* const JSON_VALUE = "value";
constexpr const char* const JSON_RETURN_VALUE = "return_value";
constexpr const char* const JSON_NOTIFICATION = "notification";
constexpr const char* const JSON_BOOTLOADER = "bootloader";
constexpr const char* const JSON_APPLICATION = "application";
constexpr const char* const JSON_VERSION = "version";
constexpr const char* const JSON_NAME = "name";
constexpr const char* const JSON_VERBOSE_NAME = "verbose_name";
constexpr const char* const JSON_PLATFORM_ID = "platform_id";
constexpr const char* const JSON_CLASS_ID = "class_id";
constexpr const char* const JSON_CHUNK = "chunk";
constexpr const char* const JSON_NUMBER = "number";
constexpr const char* const JSON_SIZE = "size";
constexpr const char* const JSON_CRC = "crc";
constexpr const char* const JSON_DATA = "data";
constexpr const char* const JSON_STATUS = "status";
constexpr const char* const JSON_OK = "ok";
constexpr const char* const JSON_RESEND_CHUNK = "resend_chunk";

const QString BOOTLOADER_STR("Bootloader");

}  // namespace

#endif // FLASHER_CONSTANTS_H_
