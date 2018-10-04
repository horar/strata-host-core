/*
 * author: iancain
 */

// Memory pool of fixed sized blocks
// Objective: speed operations of malloc/free and adapt idiomatically and separate memory
//           management from other data storage patterns such as linked lists, stacks,
//           double buffer
// Limitations: Fixed sized memory blocks. Due to the O(1) requirement only fixed sized
//                memory allocation can be performed. Memory fragmentation and
//                collection/collating operations are not desired due to performance demands
//
// Support O(1) operation in acquire and release operations
// Strategy:
// stack object to manage memory blocks
// acquire = pop_front  (acquire block off the first/bottom of stack)
// release = push_back  (release block by putting on back/top of stack)
//
#include <memory.h>
#include "memory_pool.h"



bool memory_pool_init()
{
    // if you change block_size make sure to change data array size in queue.h as well
    // to block_size - 16
    size_t number_of_blocks = 5, block_size = 138;

    memory_pool_node_t *last;
    // Mus - compound literals
    g_pool = (memory_pool_t){0};   // zero/null all elements of pool structure
    int n =0;

    printf("MEMORY POOL INIT:(number_of_blocks=%zu, block_size=%zu)\n", number_of_blocks, block_size);

    for( n = 0; n < number_of_blocks; ++n ) {

        memory_pool_node_t * node = (memory_pool_node_t *) malloc (sizeof(memory_pool_node_t));
        if( node == NULL){
            printf("OOM ERROR.\n");
            return false;
        }

        node->data = malloc ((block_size));

        if( node->data == NULL) {
            printf("OOM ERROR.\n");
            return false;
        }

        node->magic = NODE_MAGIC;  // set the magic for data integrity checks
        node->size = block_size;
        node->inuse = false;
        node->prev = NULL;   // may not need to be double linked
        node->next = NULL;

        if( g_pool.pool == NULL ) {
            g_pool.pool = node;  // pool is empty set first node
            g_pool.top = node;
            g_pool.temp = g_pool.top;
            last = node;

            printf("MEMORY POOL INIT: i=%d, node=%p block_size=%zu, data=%p, prev=%p, next=%p, magic = 0x%x\n",
                   n, node, node->size, node->data, node->prev, node->next, node->magic);
            continue;
        }
        // add new node to stack
        last->next = node;
        node->prev = last;
        last = node;

        // DEBUG : TODO remove
        printf("MEMORY POOL INIT: i=%d, node=%p block_size=%zu, data=%p, prev=%p, next=%p, magic = 0x%x\n",
               n, node, node->size, node->data, node->prev, node->next, node->magic);
    }

    printf ("MEMORY POOL INIT: g_pool.top = %p\n", g_pool.top );
    g_pool.number_of_blocks = number_of_blocks;
    g_pool.block_size = block_size;
    g_pool.available = number_of_blocks;

    return n == number_of_blocks ? true : false;
}

void memory_pool_dump()
{
    printf("memory_pool_dump(number_of_blocks=%zu, available=%zu, block_size=%zu, magic = 0x%x)\n",
           g_pool.number_of_blocks, g_pool.available, g_pool.block_size, g_pool.pool->magic);

    memory_pool_node_t * node = g_pool.pool;
    for(int n = 0; node != NULL; ++n ) {
        printf("memory_pool_dump POOL: i=%d, inuse=%s, node=%p block_size=%zu, data=%p, prev=%p, next=%p, magic = 0x%x\n",
               n, node->inuse ? "true":"false", node, node->size, node->data, node->prev, node->next, node->magic);
        node = node->next;
    }
}
bool memory_pool_acquire(memory_pool_handle_t *handle)
{
    if( g_pool.temp == NULL ) {
        g_pool.temp = g_pool.top;
        if (g_pool.temp->inuse){
            printf("memory_pool_acquire: ERROR: no available memory blocks\n");
            return false;
        }else{
            *handle = (memory_pool_handle_t) g_pool.temp;
            g_pool.temp->inuse = true;
            g_pool.temp = g_pool.temp->next;
            g_pool.available --;
            printf("MEMORY POOL ACQUIRE: handle = 0x%llx\n", *handle);
            return true;
        }
    }
    while (!g_pool.temp->inuse){
        *handle = (memory_pool_handle_t) g_pool.temp;
        g_pool.temp->inuse = true;
        g_pool.temp = g_pool.temp->next;
        g_pool.available --;

        printf("MEMORY POOL ACQUIRE: handle = 0x%llx\n", *handle);
        return true;
    }
    return false;
}

bool memory_pool_release(memory_pool_handle_t handle)
{
    if( handle == 0 ) {
        printf("memory_pool_release: ERROR: bad handle. NULL\n");
        return false;
    }

    memory_pool_node_t * node = (memory_pool_node_t *)handle;
    printf("MEMORY_POOL_RELEASE: content of node->magic is %x\n", node->magic);
    if( node->magic != NODE_MAGIC ) {
        printf("memory_pool_release: ERROR: bad handle magic. You lost the magic\n");
        return false;
    }

    printf("memory_pool_release: handle = 0x%llx\n", handle);
    node->inuse = false;
    memset(node->data,0,strlen(node->data));
    g_pool.available ++;

    return true;
}

void memory_pool_destroy()
{
    memory_pool_node_t * node = g_pool.pool;
    for(int n = 0; node != NULL; ++n ) {
        printf("memory_pool_destroy: i=%d, node=0x%p block_size=%zu, data=0x%p, prev=0x%p, next=0x%p\n",
               n, node, node->size, node->data, node->prev, node->next);

        memory_pool_node_t * tmp = node; // save off node to free memory
        node = node->next;

        tmp->magic = 0;  // lose the magic
        free(tmp->data);
        free(tmp);
    }

    g_pool = (memory_pool_t){0};
}

