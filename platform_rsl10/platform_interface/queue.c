//
// Created by Mustafa Alshehab on 8/17/18.
//

#include <stdlib.h>
#include <stdio.h>
#include "queue.h"
#include "dispatch.h"

/* ----------------------------------------------------------------------------
 * Function      : void push(char *data, linked_list *list);
 * ----------------------------------------------------------------------------
 * Description   : Add a new element at the end of the list if a list already exist.
 *                 otherwise, it will add the first element. It takes two arguments,
 *                 first, will be a pointer to data, which will be the json command
 *                 and second is a pointer to the list itself to store the data in
 *                 each node.
 * ------------------------------------------------------------------------- */
void push(char *data, linked_list *list) {

    node *new_node = (node*)malloc(sizeof(node));

    new_node->data = data;
    new_node->next = NULL;


    if (list->head == NULL)
    {
        list->size = 0;
        list->head = list->tail = new_node;

    }
    if (list->size == 1)
    {

        list->tail = new_node;
        list->head->next = list->tail;
    }
    if (list->size > 1)
    {
        list->temp = list->tail;
        list->tail = new_node;
        list->temp->next =  new_node;

    }
    list->size++;

}

//Function      : void print_list(linked_list *list);
//Description   : print out the list for debugging purposes.
void print_list(linked_list *list)
{
    printf("Current liked list size %d \n", list->size);
    printf("The list consists of ");
    list->temp = list->head;
    while (list->temp != NULL)
    {
        printf(" %s %s ", list->temp->data, "-->");
        list->temp = list->temp->next;
    }
    printf("NULL\n");
}
/* ----------------------------------------------------------------------------
 * Function      : execute(linked_list *list, command_handler command_handlers[], int size);
 * ----------------------------------------------------------------------------
 * Description   : call dispatch function to dispatch commands on the queue.
 * ------------------------------------------------------------------------- */
void execute(linked_list *list, command_handler command_handlers[], int size)
{
    dispatch(list->head->data, command_handlers, size);
    pop(list, command_handlers, size);
}
/* ----------------------------------------------------------------------------
 * Function      : pop(linked_list *list, command_handler *command_handlers, int size);
 * ----------------------------------------------------------------------------
 * Description   : remove commands already executed
 * ------------------------------------------------------------------------- */
void pop(linked_list *list, command_handler *command_handlers, int size)
{
    if (list->head)
    {

        list->temp = list->head->next;
        free(list->head);
        list->head = list->temp;
        list->size--;
        print_list(list);
        execute(list,command_handlers, size);

    }
}