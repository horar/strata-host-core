//
//  memory_pool.h
//
//  Created by Mustafa Alshehab on 9/18/18.
//  Copyright © 2018 Mustafa Alshehab. All rights reserved.
//

#ifndef mem_pool_h
#define mem_pool_h

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include "queue.h"

#define NODE_MAGIC 0xBAADA555

// PUBLIC: declared in header file
typedef uint64_t memory_pool_handle_t;

typedef struct memory_pool_node {
    uint32_t magic;      // NODE_MAGIC = 0xBAADA555
    size_t size;
    void *data;
    bool inuse;      // true = currently allocated
    struct memory_pool_node * prev;
    struct memory_pool_node * next;

} memory_pool_node_t;

//* function declaration */
bool memory_pool_init();
void memory_pool_dump();
bool memory_pool_acquire(memory_pool_handle_t *handle);
bool memory_pool_release(memory_pool_handle_t handle);
void memory_pool_destroy();

/* accessors declaration */

// accessors
// prevent memory pool clients from directly accessing internal state
// prevents clients from breaking memory pool
// allows memory pool to changing internal state without breaking API

static inline void * memory_pool_data(memory_pool_handle_t handle )
{
    return ((memory_pool_node_t*)handle)->data;
}

static inline size_t memory_pool_size(memory_pool_handle_t handle )
{
    return ((memory_pool_node_t*)handle)->size;
}

static inline bool memory_pool_valid(memory_pool_handle_t handle )
{
    if( ((memory_pool_node_t*)handle)->magic == NODE_MAGIC || handle != 0 )
        return true;

    return false;
}

//static inline size_t memory_pool_available()
//{
//    return g_pool.available;
//}

static inline void *set_data( memory_pool_handle_t handle){
    return ((memory_pool_node_t*)handle)->data;
}
#endif /* mem_pool_h */
