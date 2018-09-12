//
// Created by Mustafa Alshehab on 8/17/18.
//

#ifndef PLATFORM_INTERFACE_DISPATCH_H
#define PLATFORM_INTERFACE_DISPATCH_H

#include <stdbool.h>
#include "cJSON.h"
#include "queue.h"

#define ARRAY_SIZE(array)  sizeof(array) / sizeof(array[0]);
// enum used for response messages
enum {BAD_JSON, COMMAND_NOT_FOUND, COMMAND_VALID};
// global queue, g indicates global
queue_t *g_queue;


void dispatch(char *data);
void call_command_handler(char *name, cJSON *payload_value);

// lists of functions to be used for each command
void request_platform_id(cJSON *payload_value);
void request_echo(cJSON *payload_value);
void general_purpose(cJSON *payload_value);


#endif //PLATFORM_INTERFACE_DISPATCH_H
