//
// Created by Mustafa Alshehab on 8/17/18.
//

#ifndef PLATFORM_INTERFACE_DISPATCH_H
#define PLATFORM_INTERFACE_DISPATCH_H

#include "cJSON.h"
#include "queue.h"

void dispatch(char *data, functions function_map1[], int size);

// lists of fucntions to be used for each command
void request_platform_id(cJSON *payload_value);
void request_echo(cJSON *payload_value);
void general_purpose(cJSON *payload_value);
// check if a command exist and passes payload value
// to the function command
void function_call(char *name, cJSON *payload_value, functions *function_map1, int size);

#endif //PLATFORM_INTERFACE_DISPATCH_H
