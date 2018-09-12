#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdlib.h>
#include "cJSON.h"
#include "queue.h"
#include "dispatch.h"





int main( )
{
    list_init();
    push("{\"cmd\":\"request_platform_id\"}");
    push("{\"cmd\" : \"whatever\", \"payload\" : {\"number_argument\" : 1, \"string_argument\" : \"0x000000FF\"}}");
    push("{\"cmd\" : \"general_purpose\", \"payload\" : {\"number_argument\" : 1, \"string_argument\" : \"0x000000FF\"}}");
    push("{\"cmd\":\"request_echo\"}");
    push("Hello world!");

    print_list();

    while (g_list != NULL){
        execute();
    }

    return 0;
}
