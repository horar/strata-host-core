//
// Created by Mustafa Alshehab on 8/17/18.
//

#ifndef PLATFORM_INTERFACE_QUEUE_H
#define PLATFORM_INTERFACE_QUEUE_H

#include "cJSON.h"
#include <stdlib.h>
#include "memory_pool.h"

typedef struct node {
    char data[128];
    struct node *next;
} node_t;

typedef struct {
    node_t *head;
    node_t *tail;
    node_t *temp;
    size_t size;
}queue_t;

typedef struct {
    char  *name;
    void (*fp)(cJSON *payload_value);
}command_handler_t;

// global queue, g indicates global
queue_t *g_queue;
memory_pool_t *pool;

void queue_memory_pool_init(void);
void push(char *data);
void pop(void);
void execute(void);
void queue_memory_pool_destroy(void);

// helper function
void print_list(void);

#endif //PLATFORM_INTERFACE_QUEUE_H
