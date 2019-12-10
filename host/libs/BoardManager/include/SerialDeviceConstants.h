#ifndef SERIAL_DEVICE_CONSTANTS_H
#define SERIAL_DEVICE_CONSTANTS_H

const unsigned READ_BUFFER_SIZE = 4096;
const int RESPONSE_TIMEOUT_MS = 1000;
const int LAUNCH_DELAY_MS = 450;

#define CMD_GET_FIRMWARE_INFO "{\"cmd\":\"get_firmware_info\"}"
#define CMD_REQUEST_PLATFORM_ID "{\"cmd\":\"request_platform_id\"}"

#define JSON_ACK "ack"
#define JSON_GET_FW_INFO "get_firmware_info"
#define JSON_REQ_PLATFORM_ID "request_platform_id"
#define JSON_PAYLOAD "payload"
#define JSON_RETURN_VALUE "return_value"
#define JSON_NOTIFICATION "notification"
#define JSON_PLATFORM_ID "platform_id"
#define JSON_VALUE "value"
#define JSON_BOOTLOADER "bootloader"
#define JSON_APPLICATION "application"
#define JSON_VERSION "version"
#define JSON_PLAT_ID_VERSION "platform_id_version"
#define JSON_VERBOSE_NAME "verbose_name"
#define JSON_NAME "name"

#endif // SERIAL_DEVICE_CONSTANTS_H
