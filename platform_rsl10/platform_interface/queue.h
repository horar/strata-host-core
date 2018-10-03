//
// Created by Mustafa Alshehab on 8/17/18.
//

#ifndef PLATFORM_INTERFACE_QUEUE_H
#define PLATFORM_INTERFACE_QUEUE_H

#include "cJSON.h"

typedef struct node {
    char data[122];
    struct node *next;
} node_t;

typedef struct {
    node_t *head;
    node_t *tail;
    node_t *temp; // used when add, remove, and print out the list
    size_t size;
}queue_t;

typedef struct {
    char  *name;
    void (*fp)(cJSON *payload_value);
}command_handler_t;

// global queue, g indicates global
queue_t *g_queue;


void list_init(void);
void push(char *data);
void pop(void);
void execute(void);

// helper function
void print_list(void);

#endif //PLATFORM_INTERFACE_QUEUE_H
