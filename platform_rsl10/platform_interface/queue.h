//
// Created by Mustafa Alshehab on 8/17/18.
//

#ifndef PLATFORM_INTERFACE_QUEUE_H
#define PLATFORM_INTERFACE_QUEUE_H

#include "cJSON.h"

typedef struct node{
    char *data;  // to do: needs to be dynamic
    struct node *next;
} node;

typedef struct {
    node *head;
    node *tail;
    node *old_tail; // we use this when we add to keep track of the list
    node *new_head; // we use this when we remove to keep pointing to the current head of the list
    node *traverse; // we use this pointer to traverse through the list and print it out
    int size;
}linked_list;

typedef struct
{
    char  *name;
    void (*fp)(cJSON *payload_value);

}functions;

void list_init();
void push(char *data, linked_list *list);
void print_list(linked_list *list);
void pop(linked_list *list, functions *function_map, int size);
void execute(linked_list *list, functions function_map1[], int size);



#endif //PLATFORM_INTERFACE_QUEUE_H
