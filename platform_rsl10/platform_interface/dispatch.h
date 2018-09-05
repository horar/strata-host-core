//
// Created by Mustafa Alshehab on 8/17/18.
//

#ifndef PLATFORM_INTERFACE_DISPATCH_H
#define PLATFORM_INTERFACE_DISPATCH_H

#include <stdbool.h>
#include "cJSON.h"
#include "queue.h"

void dispatch(char *data, command_handler command_handlers[], int size);

// lists of fucntions to be used for each command
void request_platform_id(cJSON *payload_value);
void request_echo(cJSON *payload_value);
void general_purpose(cJSON *payload_value);
// check if a command exist and passes payload value
// to the function command
void call_command_handler(char *name, cJSON *payload_value, command_handler *command_handlers, int size);

#endif //PLATFORM_INTERFACE_DISPATCH_H
