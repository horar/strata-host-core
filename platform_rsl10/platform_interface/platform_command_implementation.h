//
// Created by Mustafa Alshehab on 12/26/18.
//

#ifndef PLATFORM_INTERFACE_PLATFORM_COMMAND_IMPLEMENTATION_H
#define PLATFORM_INTERFACE_PLATFORM_COMMAND_IMPLEMENTATION_H

#include <cJSON.h>

static const char *response_string[] = {
        "{\"nak\":\"\",\"payload\":{\"return_value\":false,\"return_string\":\"json error: badly formatted json\"}}",
        "{\"notification\":\"payload\":{\"return_string\":\"error: command not found\"}}",
        "{\"ack\":\"\", \"payload\":{\"return_value\":true,\"return_string\":\"Command Valid\"}"
};

enum {BAD_JSON, COMMAND_NOT_FOUND, COMMAND_VALID};

// forward declaration
typedef struct command_handler command_handler_t;

// List of core functions
void call_command_handler(char *name, cJSON *payload_value);
void request_platform_id(cJSON *payload_value);
void request_echo(cJSON *payload_value);
void general_purpose(cJSON *payload_value);

#endif //PLATFORM_INTERFACE_PLATFORM_COMMAND_IMPLEMENTATION_H
