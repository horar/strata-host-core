#include "../include/platform_command_dispatcher.h"
#include "../include/debug_macros.h"


int main( ) {

    size_t size_of_each_memory_block = size_of_node_struct();

    //initialize queue
    queue_t *queue1 = queue_init();
    // initialize memory pool memory_pool_init(# of blocks, size of each block)
    memory_pool_t *pool = memory_pool_init(5, size_of_each_memory_block);
    // this should fail -- size limit exceeded
    push("{\"cmd\":\"request_platform_id\", \"{\\\"THIS SHOULD EXCEED THE SPECIFIED LIMIT\\\"}\"}", queue1, pool);
     /* memory_pool_dump(pool) will not work if debug messages in memory pool is set to off
        that also applies to print_list */
    memory_pool_dump(pool);
    push("{\"cmd\" : \"whatever\"}", queue1, pool);
    push("{\"cmd\":\"request_echo\"}", queue1, pool);
    push("Hello world!", queue1, pool);
    push("{\"cmd\" : \"general_purpose\"}", queue1, pool);
    memory_pool_dump(pool);
    print_list(queue1);

    while (commands_in_queue(queue1) == true) {
        execute(queue1,pool);
        print_list(queue1);
    }

    memory_pool_dump(pool);
    //free queue and memory pool memory
    queue_and_memory_pool_destroy(queue1,pool);
    LOG_DEBUG("END\n");

    return 0;
}
