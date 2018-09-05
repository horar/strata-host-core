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
    node *temp; // used when add, remove, and print out the list
    int size;
}linked_list;

typedef struct
{
    char  *name;
    void (*fp)(cJSON *payload_value);

}command_handler;

void list_init();
void push(char *data, linked_list *list);
void print_list(linked_list *list);
void pop(linked_list *list, command_handler *command_handlers, int size);
void execute(linked_list *list, command_handler command_handlers[], int size);



#endif //PLATFORM_INTERFACE_QUEUE_H
