//
// Created by Mustafa Alshehab on 8/17/18.
//

#include <stdlib.h>
#include <stdio.h>
#include <memory.h>
#include "queue.h"
#include "dispatch.h"


void queue_memory_pool_init()
{
    g_queue = (queue_t*)malloc(sizeof(queue_t));

    g_queue->head = NULL;
    g_queue->tail = NULL;
    g_queue->size = 0;

    pool = memory_pool_init(5, sizeof(node_t));
}
/**
* Add a new element at the end of the list if a list already exist.
* otherwise, it will add the first element. It takes two arguments,
* first, will be a pointer to data, which will be the json command
* and second is a pointer to the list itself to store the data in
* each node.
**/
void push(char *data)
{
    node_t *new_node = (node_t*)memory_pool_acquire(pool);

    memcpy(new_node->data, data, strlen(data));
    //new_node->data = data;
    new_node->next = NULL;
    /*
     * we could you use strncpy if we want to specify the size of
     * the array of data inside node struct
    ** strncpy(new_node->data, data, strlen(data));
     */

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
        g_queue->temp->next = new_node;
    }
    g_queue->size++;
}

/**
 * call dispatch function to dispatch commands on the queue & remove it after
 * it being executed by calling pop function
 **/
void execute()
{
    dispatch(g_queue->head->data);
    pop();
}

void pop()
{
    if (g_queue->head) {
        g_queue->temp = g_queue->head->next;
        memory_pool_release(pool,g_queue->head);
        g_queue->head = g_queue->temp;
        g_queue->size--;
        print_list();
    }
}

void print_list()
{
    printf("PRINT: Current liked g_queue size %zu \n", g_queue->size);
    printf("The g_queue consists of ");
    g_queue->temp = g_queue->head;
    while (g_queue->temp != NULL) {
        printf("%s %s ", g_queue->temp->data, "-->");
        g_queue->temp = g_queue->temp->next;
    }
    printf("NULL\n");
}
void queue_memory_pool_destroy(){

    memory_pool_destroy(pool);
    free(g_queue);
}