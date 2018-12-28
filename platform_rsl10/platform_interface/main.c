#include <stdlib.h>
#include <printf.h>
#include "cJSON.h"
#include "platform_command_dispatcher.h"




int main( ) {
    //initialize queue
    queue_t *queue1 = queue_init();

    /* the size of the node struct is 8 bytes, so if you
     * want a command size of 8 bytes, then it will be 16
     * in total. The compiler will account for 8 each time.
     * e.g. if you put a command length of 2 bytes the total
     * will be 16 anyway. In that case you will need to specify
     * 16 anyway
     * I need to find a good automated solution for this */

    // initialize memory pool memory_pool_init(# of blocks, size of each block)
    memory_pool_t *pool = memory_pool_init(5, 81);
    // this should fail -- size limit exceeded
    push("{\"cmd\":\"request_platform_id\", \"{\\\"nak\\\":\\\"\\\",\\\"payload\\\":{\\\"return_value\\\":false,\\\"return_string\\\":\\\"json error: this now should be the maximum length\\\"}}\"}", queue1, pool);
   // memory_pool_dump(pool);
    push("{\"cmd\" : \"whatever\"}", queue1, pool);
    push("{\"cmd\":\"request_echo\"}", queue1, pool);
    push("Hello world!", queue1, pool);
    push("{\"cmd\" : \"general_purpose\"}", queue1, pool);
    //memory_pool_dump(pool);
    print_list(queue1);
    while (commands_in_queue(queue1) == true) {
        execute(queue1,pool);
    }
    memory_pool_dump(pool);
    //free queue and memory pool memory
    queue_and_memory_pool_destroy(queue1,pool);
    printf("END\n");
    return 0;
}
