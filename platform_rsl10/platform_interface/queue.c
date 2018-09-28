//
// Created by Mustafa Alshehab on 8/17/18.
//

#include <stdlib.h>
#include <stdio.h>
#include <memory.h>
#include "queue.h"
#include "dispatch.h"
#include "memory_pool.h"


void list_init()
{
    g_queue = (queue_t*)malloc(sizeof(queue_t));

    g_queue->head = NULL;
    g_queue->tail = NULL;
    g_queue->size = 0;
}

void push(char *data)
{
        printf("PUSH: Size of DATA is: %lu\n", strlen(data));
        memory_pool_handle_t b = 0;
        node_t *new_node;
        printf("PUSH: value of b before is: %p\n", b);
        memory_pool_acquire(&b);
        printf("PUSH: value of b after is: %p\n", b);
        new_node = b;
        printf("PUSH: value of new_node is: %p\n", new_node);
        new_node->data = data;
        new_node->next = NULL;
        set_data(new_node,b);

    //printf("PUSH: value of magic node is: %x\n", g_pool.pool->magic);

//        new_node->data = data; //set_data(data,(memory_pool_handle_t )new_node);
//        printf("PUSH: Size of DATA is: %lu\n", strlen(new_node->data));
//        //new_node->next = NULL;
//
        if (g_queue->head == NULL) {
            g_queue->size = 0;
            g_queue->head = g_queue->tail = new_node;
            printf("PUSH: address of g_queue head is %p\n", g_queue->head);
        }

        if (g_queue->size == 1) {

            g_queue->tail = new_node;
            g_queue->head->next = g_queue->tail;
            printf("PUSH: address of g_queue tail is %p\n", g_queue->tail);
        }
        if (g_queue->size > 1) {
            g_queue->temp = g_queue->tail;
            g_queue->tail = new_node;
            g_queue->temp->next =  new_node;
            printf("PUSH: address of g_queue old_tail is %p\n", g_queue->temp);
            printf("PUSH: address of g_queue new_tail is %p\n", g_queue->tail);
        }
//    }
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
      //  memory_pool_release((memory_pool_handle_t*)g_queue->head);
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
