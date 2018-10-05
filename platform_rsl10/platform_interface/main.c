#include <stdlib.h>
#include "cJSON.h"
#include "queue.h"
#include "dispatch.h"
#include "memory_pool.h"


int main( ) {

    memory_pool_init();
    list_init();

   push("{\"cmd\":\"request_platform_id\"}");
//    push("{\"cmd\" : \"whatever\", \"payload\" : {\"number_argument\" : 1, \"string_argument\" : \"0x000000FF\"}}");
    push("{\"cmd\" : \"general_purpose\", \"payload\" : {\"number_argument\" : 1, \"string_argument\" : \"0x000000FF\"}}");
    push("{\"cmd\":\"request_echo\"}");
    push("Hello world!");
    push("{\"cmd\" : \"general_purpose\", \"payload\" : {\"number_argument\" : 1, \"string_argument\" : \"0x000000FF\"}}");

    memory_pool_dump();
    pop();
//    while (g_queue->head != NULL) {
//        execute();
//    }
    memory_pool_dump();
    push("{\"cmd\" : \"test1\", \"payload\" : {\"number_argument\" : 1, \"string_argument\" : \"0x000000FF\"}}");
    pop();
    pop();
    push("{\"cmd\" : \"general_purpose\", \"payload\" : {\"number_argument\" : 1, \"string_argument\" : \"0x000000FF\"}}");
    push("{\"cmd\":\"request_echo\"}");
    push("Hello world!");
    memory_pool_dump();
    push("{\"cmd\" : \"Ali\", \"payload\" : {\"number_argument\" : 1, \"string_argument\" : \"0x000000FF\"}}");
    while (g_queue->head != NULL) {
        pop();
    }
    push("{\"cmd\" : \"general_purpose\", \"payload\" : {\"number_argument\" : 1, \"string_argument\" : \"0x000000FF\"}}");
    memory_pool_dump();
    memory_pool_destroy();
   free(g_queue);
    printf("END\n");
    return 0;
}
