//
// Created by Mustafa Alshehab on 12/26/18.
//
#include "../include/platform_command_implementation.h"
#include "../include/debug_macros.h"
#include <memory.h>

#define ARRAY_SIZE(array)  sizeof(array) / sizeof(array[0]);

struct command_handler{
    char  *name;
    void (*fp)(cJSON *payload_value);
};

/* *
 * Lists of the command_handler that will be used for dispatching
 * commands. Each sub array in command_handlers[] will have the
 * command in a string format followed by the function that
 * will be declared and defined in platform_command_implementation.h and
 * platform_command_implementation.c respectively. Command argument will be the
 * name of the function.
 * */

command_handler_t command_handlers[] = {
        {"request_platform_id", request_platform_id},
        {"request_echo", request_echo},
        {"general_purpose", general_purpose},
};

static int g_command_handlers_size = ARRAY_SIZE(command_handlers);

// Below are the lists of functions used for each command
void call_command_handler(char *name, cJSON *payload_value) {
    LOG_DEBUG("Size of the command_handlers list is %u", g_command_handlers_size);

    for (int i = 0; i < g_command_handlers_size; i++) {
        if (!strcmp(command_handlers[i].name, name)) {
            emit(response_string[COMMAND_VALID]); //emit ack
            command_handlers[i].fp(payload_value);
            return;
        }
    }
    LOG_ERROR("%s %s \n", name, "command doesn't exist");
    emit(response_string[COMMAND_NOT_FOUND]);
}


void request_platform_id (cJSON *payload_value) {
    LOG_DEBUG("confirm execution of platform_id_command or echo command \n");
    /* call a send response function
     * In case of RSL-10 will be something
     * like below to sent platform id through UART
     * UART->TX_DATA = "what ever the message you want to send";
     * for echo you could echo whatever you received from rx uart
     * UART->TX_DATA = uart_rx_buffer;
     */

}

void request_echo (cJSON *payload_value) {
    LOG_DEBUG("confirm execution of echo command\n");
    /* In case of RSL-10 will be something
     * you could echo whatever you received from rx uart
     * UART->TX_DATA = uart_rx_buffer;
     */
}

void general_purpose (cJSON *payload_value) {
    /* in case of payload consists of two arguments
     the first is a number and the second is a string
     "{\"cmd\" : \"command_A\", \"payload\" : {\"number_argument\" : 1, \"string_argument\" : \"whatever"}}"
     */

    cJSON *number_argument = NULL;
    cJSON *string_argument = NULL;

    LOG_DEBUG("confirm execution of general_command\n");

    if (payload_value == NULL) {
        LOG_ERROR("No payload value");
        return;
    }
    // this how to fetch a number using cJSON library
    number_argument = cJSON_GetObjectItem(payload_value, "number_argument");
    size_t number_value = number_argument->valueint;
    // this how to fetch a string using cJSON library
    string_argument = cJSON_GetObjectItem(payload_value, "string_argument");
    char *string_value = string_argument->valuestring;

/* do whatever you want below this line
 * by using number_value and string_value variables
 */
}

void emit(const char *response_string)
{
    LOG_DEBUG("confirm execution of emit %s\n", response_string);
    // the following code assumes you are using
    // cmsis uart driver for RSL10
    // send function in cmsis uart driver works by telling
    // it the size of how many bytes your sending or
    // whenever it sees the new line will stop sending
    // if that new line was found within the size of
    // bytes that has been specified in the second argument
    // https://bitbucket.org/onsemi-spyglass/spyglass/src/RSL10-development/RSL10/uart_cmsis_driver/

    // uart->Send(response_string, strlen(response_string));
}

