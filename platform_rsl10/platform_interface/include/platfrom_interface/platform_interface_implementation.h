//
// Created by Mustafa Alshehab on 12/26/18.
//

#ifndef PLATFORM_INTERFACE_INCLUDE_PLATFORM_COMMAND_DISPATCHER_H
#define PLATFORM_INTERFACE_INCLUDE_PLATFORM_COMMAND_DISPATCHER_H

#include <stdlib.h>
#include <memory_pool/memory_pool.h>

// forward declaration
typedef struct queue queue_t;

// list of core functions
queue_t *queue_init(void);

bool is_command_within_length(char *);

void push(char *data, queue_t *, memory_pool_t *);

void execute(queue_t *, memory_pool_t *);

void dispatch(char *data);

void pop(queue_t *, memory_pool_t *);

void queue_and_memory_pool_destroy(queue_t *, memory_pool_t *);

// accessors functions
bool commands_in_queue(queue_t *);

size_t size_of_node_struct();

// helper function
void print_list(queue_t *);


#endif //PLATFORM_INTERFACE_INCLUDE_PLATFORM_COMMAND_DISPATCHER_H
