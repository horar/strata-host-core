//
// Created by Mustafa Alshehab on 8/17/18.
//

#ifndef PLATFORM_INTERFACE_DISPATCH_H
#define PLATFORM_INTERFACE_DISPATCH_H

#include <stdbool.h>
#include "cJSON.h"
#include "queue.h"

#define ARRAY_SIZE(array)  sizeof(array) / sizeof(array[0]);

void dispatch(char *data);

// enum used for response messages
enum {BAD_JSON, COMMAND_NOT_FOUND, COMMAND_VALID};

// global list g indicates global
linked_list_t *g_list;
// lists of functions to be used for each command
void request_platform_id(cJSON *payload_value);
void request_echo(cJSON *payload_value);
void general_purpose(cJSON *payload_value);
// check if a command exist and passes payload value
// to the function command
void call_command_handler(char *name, cJSON *payload_value);

#endif //PLATFORM_INTERFACE_DISPATCH_H
