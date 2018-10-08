//
//  memory_pool.h
//
//  Created by Mustafa Alshehab on 9/18/18.
//  Copyright © 2018 Mustafa Alshehab. All rights reserved.
//

#ifndef PLATFORM_INTERFACE_MEMORY_POOL_H
#define PLATFORM_INTERFACE_MEMORY_POOL_H

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include "queue.h"

// PUBLIC: declared in header file
typedef uint64_t memory_pool_handle_t;


//* function declaration */
bool memory_pool_init();
void memory_pool_dump();
bool memory_pool_acquire(memory_pool_handle_t *handle);
bool memory_pool_release(memory_pool_handle_t handle);
void memory_pool_destroy();

/* accessors declaration */

void * memory_pool_data(memory_pool_handle_t handle );
size_t memory_pool_size(memory_pool_handle_t handle );
bool memory_pool_valid(memory_pool_handle_t handle );
size_t memory_pool_available();
void *set_data( memory_pool_handle_t handle);


#endif /* mem_pool_h */
