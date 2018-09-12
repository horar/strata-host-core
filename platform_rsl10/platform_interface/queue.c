//
// Created by Mustafa Alshehab on 8/17/18.
//

#include <stdlib.h>
#include <stdio.h>
#include "queue.h"
#include "dispatch.h"


void list_init() {
    g_queue = (queue_t*)malloc(sizeof(queue_t));

    g_queue->head = NULL;
    g_queue->tail = NULL;
    g_queue->size = 0;
}

void push(char *data) {
    node_t *new_node = (node_t*)malloc(sizeof(node_t));

    new_node->data = data;
    new_node->next = NULL;


    if (g_queue->head == NULL) {
        g_queue->size = 0;
        g_queue->head = g_queue->tail = new_node;

    }
    if (g_queue->size == 1) {

        g_queue->tail = new_node;
        g_queue->head->next = g_queue->tail;
    }
    if (g_queue->size > 1) {
        g_queue->temp = g_queue->tail;
        g_queue->tail = new_node;
        g_queue->temp->next =  new_node;

    }
    g_queue->size++;
}

/**
 * call dispatch function to dispatch commands on the queue & remove it after
 * it being executed by calling pop function
 **/
void execute() {
    dispatch(g_queue->head->data);
    pop();
}

void pop() {
    if (g_queue->head) {

        g_queue->temp = g_queue->head->next;
        free(g_queue->head);
        g_queue->head = g_queue->temp;
        g_queue->size--;
        print_list();
    }
}

void print_list() {
    printf("Current liked g_queue size %zu \n", g_queue->size);
    printf("The g_queue consists of ");
    g_queue->temp = g_queue->head;
    while (g_queue->temp != NULL) {
        printf(" %s %s ", g_queue->temp->data, "-->");
        g_queue->temp = g_queue->temp->next;
    }
    printf("NULL\n");
}
