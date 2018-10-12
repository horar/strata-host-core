#include <stdlib.h>
#include <printf.h>
#include "cJSON.h"
#include "queue.h"
#include "dispatch.h"



int main( ) {
    //initialize queue and memory pool memory
    list_init();
    push("{\"cmd\":\"request_platform_id\", \"{\\\"nak\\\":\\\"\\\",\\\"payload\\\":{\\\"return_value\\\":false,\\\"return_string\\\":\\\"json error: this now should be the maximum length\\\"}}\"}");
    memory_pool_dump(pool);
    push("{\"cmd\" : \"whatever\"}");
    push("{\"cmd\":\"request_echo\"}");
    push("Hello world!");
    push("{\"cmd\" : \"general_purpose\"}");
    memory_pool_dump(pool);
    print_list();
    while (g_queue->head != NULL) {
        execute();
    }
    memory_pool_dump(pool);
    //free queue and memory pool memory
    queue_destroy();
    printf("END\n");
    return 0;
}
