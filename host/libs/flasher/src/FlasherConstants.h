#ifndef FLASHER_CONSTANTS_H_
#define FLASHER_CONSTANTS_H_

#include <chrono>

namespace strata {

constexpr std::chrono::milliseconds RESPONSE_TIMEOUT(1000);
constexpr std::chrono::milliseconds LAUNCH_DELAY(500);
constexpr std::chrono::milliseconds BOOTLOADER_START_DELAY(5500);

constexpr int CHUNK_SIZE = 256;

// Strata commands must end with '\n'
// constexpr const char* const CMD_GET_FIRMWARE_INFO = "{\"cmd\":\"get_firmware_info\"}\n";
constexpr const char* const CMD_REQUEST_PLATFORM_ID = "{\"cmd\":\"request_platform_id\"}";
//constexpr const char* const CMD_UPDATE_FIRMWARE = "{\"cmd\":\"update_firmware\",\"payload\":{}}";
constexpr const char* const CMD_UPDATE_FIRMWARE = "{\"cmd\":\"update_firmware\"}";

constexpr const char* const CMD_START_APPLICATION = "{\"cmd\":\"start_application\"}";

constexpr const char* const JSON_ACK = "ack";
// constexpr const char* const JSON_GET_FW_INFO = "get_firmware_info";
constexpr const char* const JSON_REQ_PLATFORM_ID = "request_platform_id";
constexpr const char* const JSON_REQ_UPDATE_FW = "request_update_firmware";
constexpr const char* const JSON_REQ_FLASH_FW = "request_flash_firmware";
constexpr const char* const JSON_REQ_START_APP = "request_start_application";
constexpr const char* const JSON_PAYLOAD = "payload";
constexpr const char* const JSON_RETURN_VALUE = "return_value";
constexpr const char* const JSON_NOTIFICATION = "notification";
// constexpr const char* const JSON_BOOTLOADER = "bootloader";
// constexpr const char* const JSON_APPLICATION = "application";
// constexpr const char* const JSON_VERSION = "version";
constexpr const char* const JSON_NAME = "name";
constexpr const char* const JSON_VERBOSE_NAME = "verbose_name";
constexpr const char* const JSON_PLATFORM_ID = "platform_id";
constexpr const char* const JSON_CLASS_ID = "class_id";

}

#endif // FLASHER_CONSTANTS_H_
