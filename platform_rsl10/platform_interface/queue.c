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
        list->old_tail = list->tail;
        list->tail = new_node;
        list->old_tail->next =  new_node;

    }
    list->size++;

}
/* ----------------------------------------------------------------------------
 * Function      : void print_list(linked_list *list);
 * ----------------------------------------------------------------------------
 * Description   : print out the list for debugging purposes.
 * ------------------------------------------------------------------------- */
void print_list(linked_list *list)
{
    printf("Current liked list size %d \n", list->size);
    printf("The list consists of ");
    list->traverse = list->head;
    while (list->traverse != NULL)
    {
        printf(" %s %s ", list->traverse->data, "-->");
        list->traverse = list->traverse->next;
    }
    printf("NULL\n");
}
/* ----------------------------------------------------------------------------
 * Function      : execute(linked_list *list, functions function_map1[], int size);
 * ----------------------------------------------------------------------------
 * Description   : call dispatch function to dispatch commands on the queue.
 * ------------------------------------------------------------------------- */
void execute(linked_list *list, functions function_map1[], int size)
{
    dispatch(list->head->data, function_map1, size);
    pop(list, function_map1, size);
}
/* ----------------------------------------------------------------------------
 * Function      : pop(linked_list *list, functions *function_map, int size);
 * ----------------------------------------------------------------------------
 * Description   : remove commands already executed
 * ------------------------------------------------------------------------- */
void pop(linked_list *list, functions *function_map, int size)
{
    if (list->head)
    {

        list->new_head = list->head->next;
        free(list->head);
        list->head = list->new_head;
        list->size--;
        print_list(list);
        execute(list,function_map, size);

    }
}