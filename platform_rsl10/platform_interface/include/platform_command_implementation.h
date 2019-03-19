//
// Created by Mustafa Alshehab on 12/26/18.
//

#ifndef PLATFORM_INTERFACE_PLATFORM_COMMAND_IMPLEMENTATION_H
#define PLATFORM_INTERFACE_PLATFORM_COMMAND_IMPLEMENTATION_H

#include <cJSON.h>

static const char *response_string[] = {
        "{\"nak\":\"\",\"payload\":{\"return_value\":false,\"return_string\":\"json error: badly formatted json\"}}",
        "{\"notification\":\"payload\":{\"return_string\":\"error: command not found\"}}",
        "{\"ack\":\"\", \"payload\":{\"return_value\":true,\"return_string\":\"Command Valid\"}",
        "{\"notification\":\"payload\":{\"return_string\":\"error: command size exceeded the specified limit\"}}"
};

enum emit_messages {BAD_JSON, COMMAND_NOT_FOUND, COMMAND_VALID, LONG_COMMAND};

// forward declaration
typedef struct command_handler command_handler_t;

// list of core functions
void call_command_handler(char *name, cJSON *payload_value);
void request_platform_id(cJSON *payload_value);
void request_echo(cJSON *payload_value);
void general_purpose(cJSON *payload_value);
void emit(const char *);

#endif //PLATFORM_INTERFACE_PLATFORM_COMMAND_IMPLEMENTATION_H
