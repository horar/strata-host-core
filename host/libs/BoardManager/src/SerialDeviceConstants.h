#ifndef SERIAL_DEVICE_CONSTANTS_H
#define SERIAL_DEVICE_CONSTANTS_H

#include <chrono>

namespace spyglass {

constexpr int NUMBER_OF_RETRIES = 5;
constexpr unsigned READ_BUFFER_SIZE = 4096;
constexpr std::chrono::milliseconds RESPONSE_TIMEOUT(1000);
constexpr std::chrono::milliseconds LAUNCH_DELAY(500);

// Strata commands must end with '\n'
constexpr const char* const CMD_GET_FIRMWARE_INFO = "{\"cmd\":\"get_firmware_info\"}\n";
constexpr const char* const CMD_REQUEST_PLATFORM_ID = "{\"cmd\":\"request_platform_id\"}\n";

constexpr const char* const JSON_ACK = "ack";
constexpr const char* const JSON_GET_FW_INFO = "get_firmware_info";
constexpr const char* const JSON_REQ_PLATFORM_ID = "request_platform_id";
constexpr const char* const JSON_PAYLOAD = "payload";
constexpr const char* const JSON_RETURN_VALUE = "return_value";
constexpr const char* const JSON_NOTIFICATION = "notification";
constexpr const char* const JSON_BOOTLOADER = "bootloader";
constexpr const char* const JSON_APPLICATION = "application";
constexpr const char* const JSON_VERSION = "version";
constexpr const char* const JSON_NAME = "name";
constexpr const char* const JSON_VERBOSE_NAME = "verbose_name";
constexpr const char* const JSON_PLATFORM_ID = "platform_id";
constexpr const char* const JSON_CLASS_ID = "class_id";

}  // namespace

#endif // SERIAL_DEVICE_CONSTANTS_H
