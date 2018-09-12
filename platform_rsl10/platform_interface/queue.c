//
// Created by Mustafa Alshehab on 8/17/18.
//

#include <stdlib.h>
#include <stdio.h>
#include "queue.h"
#include "dispatch.h"


void list_init(){

    g_list = (linked_list_t*)malloc(sizeof(linked_list_t));

    g_list->head = NULL;
    g_list->tail = NULL;
    g_list->size = 0;

}

void push(char *data) {

    node_t *new_node = (node_t*)malloc(sizeof(node_t));

    new_node->data = data;
    new_node->next = NULL;


    if (g_list->head == NULL)
    {
        g_list->size = 0;
        g_list->head = g_list->tail = new_node;

    }
    if (g_list->size == 1)
    {

        g_list->tail = new_node;
        g_list->head->next = g_list->tail;
    }
    if (g_list->size > 1)
    {
        g_list->temp = g_list->tail;
        g_list->tail = new_node;
        g_list->temp->next =  new_node;

    }
    g_list->size++;

}

void print_list()
{
    printf("Current liked g_list size %zu \n", g_list->size);
    printf("The g_list consists of ");
    g_list->temp = g_list->head;
    while (g_list->temp != NULL)
    {
        printf(" %s %s ", g_list->temp->data, "-->");
        g_list->temp = g_list->temp->next;
    }
    printf("NULL\n");
}
/**
 * call dispatch function to dispatch commands on the queue & remove it after
 * it being executed by calling pop function
 **/
void execute()
{
    dispatch(g_list->head->data);
    pop();
}

void pop()
{
    if (g_list->head)
    {

        g_list->temp = g_list->head->next;
        free(g_list->head);
        g_list->head = g_list->temp;
        g_list->size--;
        print_list();

    }
}

