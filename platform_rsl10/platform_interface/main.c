#include <stdlib.h>
#include "cJSON.h"
#include "queue.h"
#include "dispatch.h"
#include "memory_pool.h"


int main( ) {

    memory_pool_init();
    list_init();
//    memory_pool_dump();
//    push("{\"cmd\":\"request_platform_id\"}");
//    push("{\"cmd\" : \"whatever\", \"payload\" : {\"number_argument\" : 1, \"string_argument\" : \"0x000000FF\"}}");
//    push("{\"cmd\" : \"general_purpose\", \"payload\" : {\"number_argument\" : 1, \"string_argument\" : \"0x000000FF\"}}");
    push("{\"cmd\":\"request_echo\"}");
    push("Hello world!");
    memory_pool_dump();
    push("{\"cmd\" : \"general_purpose\", \"payload\" : {\"number_argument\" : 1, \"string_argument\" : \"0x000000FF\"}}");
    push("{\"cmd\" : \"general_purpose\", \"payload\" : {\"number_argument\" : 1, \"string_argument\" : \"0x000000FF\"}}");
    push("{\"cmd\" : \"general_purpose\", \"payload\" : {\"number_argument\" : 1, \"string_argument\" : \"0x000000FF\"}}");

//    memory_pool_dump();
   // print_list();
    memory_pool_dump();
//    while (g_queue->head != NULL) {
//        execute();
//    }
    //memory_pool_dump();
   // printf("MAIN: content of g_queue head is %s\n", g_queue->head->data);
    print_list();
    //memory_pool_destroy();
    memory_pool_dump();
    printf("END\n");
    return 0;
}
