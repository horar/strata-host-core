//
// Created by Mustafa Alshehab on 8/17/18.
//

#include <stdlib.h>
#include "dispatch.h"
#include <string.h>
#include <printf.h>
#include "cJSON.h"

const char *response_string[] = {
        "{\"nak\":\"\",\"payload\":{\"return_value\":false,\"return_string\":\"json error: badly formatted json\"}}",
        "{\"notification\":\"payload\":{\"return_string\":\"error: command not found\"}}",
        "{\"ack\":\"\", \"payload\":{\"return_value\":true,\"return_string\":\"Command Valid\"}"
};
/* *
 * Lists of the command_handler that will be used for dispatching
 * commands. Each sub array in function_map[] will have the
 * command in a string format followed by the function that
 * will be declared and defined in dispatch.h and
 * dispatch.c respectively. Command argument will be the
 * name of the function.
 * */

command_handler_t command_handlers[] = {
        {"request_platform_id", request_platform_id},
        {"request_echo", request_echo},
        {"general_purpose", general_purpose},
};

int g_command_handlers_size = ARRAY_SIZE(command_handlers);

/* An example of json format
   * payload arguments could be anything you want
   * this examples have a number and string arguments

     "{\"cmd\" : \"whatever\", \"payload\" : {\"number_argument\" : 1, \"string_argument\" : \"whatever"}}"
     OR
     "{\"cmd\" : \"whatever\"}"
*/

/**
 * check for proper json command and command validation, call the
 * right function for each command by calling call_command_handler function.
 **/
void dispatch(char * data)
{
    char *parse_string = data;
    printf("parsing string is %s \n", parse_string);

    cJSON *json = NULL;
    cJSON *cmd = NULL;
    cJSON *payload = NULL;
    json = cJSON_Parse(parse_string);

    // check for proper json string code goes here before cJSON_GetObjectItem gets called
    if (json == NULL)
    {
        const char *error_ptr = cJSON_GetErrorPtr();
        if (error_ptr != NULL)
        {
            printf("%s %s", error_ptr, "is invalid json\n");
            //response_string[BAD_JSON]; //emit json not valid
        }
        /* warning: memory is allocated to store the parsed JSON and
         * must be freed by cJSON_Delete(json); to prevent memory lea */
        cJSON_Delete(json);
        return;
    }

    cmd = cJSON_GetObjectItem(json, "cmd");
    payload = cJSON_GetObjectItem(json, "payload");

    if (cmd == NULL)
    {
        /* warning: memory is allocated to store the parsed JSON and
         * must be freed by cJSON_Delete(json); to prevent memory lea */
        cJSON_Delete(json);
        return;
    }

    char *cmd_value = cmd->valuestring;

    /* check for command type and call the right function if exist */
    call_command_handler(cmd_value, payload);

    /* warning: memory is allocated to store the parsed JSON and
         * must be freed by cJSON_Delete(json); to prevent memory lea */
    cJSON_Delete(json);
}

void call_command_handler(char *name, cJSON *payload_value)
{
    printf("Size of the command_handlers  %u\n", g_command_handlers_size);

    for (int i = 0; i < g_command_handlers_size; i++) {
        if (!strcmp(command_handlers[i].name, name)) {
//            response_string[COMMAND_VALID]; //emit ack
            command_handlers[i].fp(payload_value);
            return;
        }
    }
      printf("%s %s \n", name, "command doesn't exist");
////    response_string[COMMAND_NOT_FOUND]; //emit command not found
}

// Below are the lists of functions used for each command specified

void request_platform_id (cJSON *payload_value)
{
    printf("confirm execution of platform_id_command or echo command \n");
    /* call a send response function
     * In case of RSL-10 will be something
     * like below to sent platform id through UART
     * UART->TX_DATA = "what ever the message you want to send";
     * for echo you could echo whatever you received from rx uart
     * UART->TX_DATA = uart_rx_buffer;
     */
}

void request_echo (cJSON *payload_value)
{
    printf("confirm execution of echo command \n");
    /* In case of RSL-10 will be something
     * you could echo whatever you received from rx uart
     * UART->TX_DATA = uart_rx_buffer;
     */
}

void general_purpose (cJSON *payload_value)
{
    cJSON *number_argument = NULL;
    cJSON *string_argument = NULL;

    printf("confirm execution of general_command\n");

    number_argument = cJSON_GetObjectItem(payload_value, "number_argument");
    uint32_t number_value = number_argument->valueint;

    string_argument = cJSON_GetObjectItem(payload_value, "string_argument");
    char *string_value = string_argument->valuestring;

    /* do whatever you want below this line
     * by using number_value and string_value variables
     */
}