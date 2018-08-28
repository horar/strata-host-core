//
// Created by Mustafa Alshehab on 8/17/18.
//

#include <stdlib.h>
#include "dispatch.h"
#include <string.h>
#include <printf.h>
#include "cJSON.h"

/* An example of json format
   * payload arguments could be anything you want
   * this examples have a number and string arguments

     "{\"cmd\" : \"whatever\", \"payload\" : {\"number_argument\" : 1, \"string_argument\" : \"whatever"}}"
     OR
     "{\"cmd\" : \"whatever\"}"
*/

/* ----------------------------------------------------------------------------
 * Function      : void dispatch(char * data, functions function_map1[], int size);
 * ----------------------------------------------------------------------------
 * Description   : check for proper json command, command validation, call the
 *                 right function for each command by calling function_call function.
 *                 The function takes three arguments. First, data pointer which
 *                 contains the json command in each node. Second, functions lists
 *                 for each command. Third is the size of the function_map[] array.
 * ------------------------------------------------------------------------- */
void dispatch(char * data, functions function_map1[], int size)
{
    char *parse_string = data;
    printf("parsing string is %s \n", parse_string);

    cJSON *json = NULL;
    cJSON *cmd = NULL;
    cJSON *payload = NULL;

    // It will parse the JSON and allocate a tree of cJSON items that represents it.
    json = cJSON_Parse(parse_string);

    /* used to print out the parsed json
    char *string = cJSON_Print(json);

    printf("cJSON parsed is: %s\n", string);
    */

    // check for proper json string code goes here before cJSON_GetObjectItem gets called
    if (json == NULL)
    {
        const char *error_ptr = cJSON_GetErrorPtr();
        if (error_ptr != NULL)
        {
            printf("%s %s", error_ptr, "is invalid json\n");
        }
        goto end;
    }

    cmd = cJSON_GetObjectItem(json, "cmd");
    payload = cJSON_GetObjectItem(json, "payload");

    if (cmd == NULL)
    {
        goto end;
    }

    char *cmd_value = cmd->valuestring;

    /* check for command type and call the right function if exist */
    function_call(cmd_value, payload, function_map1, size);

    end:
    /* Delete a cJSON structure. */
    cJSON_Delete(json);
}
/* ----------------------------------------------------------------------------
 * Function      : void function_call(char *name, cJSON *payload_value, functions *function_map1, int size);
 * ----------------------------------------------------------------------------
 * Description   : call the right function for each command.
 *                 The function takes four arguments. First, name pointer which
 *                 contains string name of the function. Second, payload value for each command.
 *                 third, functions lists for each command. Fourth is the size of the function_map[] array.
 * ------------------------------------------------------------------------- */
void function_call(char *name, cJSON *payload_value, functions *function_map1, int size)
{
    printf("Size of the function_map  %u\n", size);
    //for (int i = 0; i < (sizeof(function_map1) / sizeof(function_map1[0])); i++)
    for (int i = 0; i < size; i++)
    {
        if (!strcmp(function_map1[i].name, name))
        {
            function_map1[i].fp(payload_value);
            return;
        }
    }
    printf("%s %s \n", name, "function doesn't exist");
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