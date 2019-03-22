//
// Created by Mustafa Alshehab on 8/17/18.
//
#include "../include/platfrom_interface/platform_interface_implementation.h"
#include "../include/platform_command_implementation.h"
#include "../include/debug_macros.h"

/**  An example of json format
  * payload arguments could be anything you want
  * this examples have a number and string arguments
  *
  *  "{\"cmd\" : \"command_A\", \"payload\" : {\"number_argument\" : 1, \"string_argument\" : \"whatever}\"}"
  *   OR
  *  "{\"cmd\" : \"command_B\", \"payload\" : \"{whatever_payload}\"}"
  *   OR (a payload of 0 in case of platform_id request)
  *  "{\"cmd\" : \"command_C\", \"payload\" : \"{0}\"}"
  **/

#define COMMAND_LENGTH_IN_BYTES 150

// This could be change to full stack size or whatever appropriate
#define COMMAND_MAX_LENGTH 2000

typedef struct node {
    char data[COMMAND_LENGTH_IN_BYTES];
    struct node *next;
} node_t;

struct queue {
    node_t *head;
    node_t *tail;
    node_t *temp;
    size_t size;
};

queue_t *queue_init(void) {
    queue_t *queue = (queue_t *) malloc(sizeof(queue_t));

    queue->head = NULL;
    queue->tail = NULL;
    queue->temp = NULL;
    queue->size = 0;

    return queue;
}

bool is_command_within_length(char *data) {
    size_t i = 0;
    for ( ; (*(data + i) != '\n' && i < COMMAND_MAX_LENGTH); i++ );

    if ( i <= COMMAND_LENGTH_IN_BYTES ) {
        return true;
    } else {
        return false;
    }
}

/**
* Add a new element at the end of the list if a list already exist.
* otherwise, it will add the first element. It takes two arguments,
* first, will be a pointer to data, which will be the json command
* and the second argument is a pointer to the list itself to store
* the data in each node.
**/
void push(char *data, queue_t *queue, memory_pool_t *pool) {
    bool length = is_command_within_length(data);

    if ( length == true ) {
        node_t *new_node = (node_t *) memory_pool_acquire(pool);
        memcpy(new_node->data, data, strlen(data));
        new_node->next = NULL;

        if ( queue->head == NULL) {
            queue->head = queue->tail = new_node;
        } else if ( queue->size == 1 ) {
            queue->tail = new_node;
            queue->head->next = queue->tail;
        } else {
            queue->temp = queue->tail;
            queue->tail = new_node;
            queue->temp->next = new_node;
        }
        queue->size++;
    } else {
        LOG_ERROR("The command %s%s ", data, " has exceeded the specified length limit\n");
        emit(response_string[LONG_COMMAND]);
    }
}

void execute(queue_t *queue, memory_pool_t *pool) {
    dispatch(queue->head->data);
    pop(queue, pool);
}

void pop(queue_t *queue, memory_pool_t *pool) {
    if ( queue->head ) {
        queue->temp = queue->head->next;
        memory_pool_release(pool, queue->head);
        queue->head = queue->temp;
        queue->size--;
    }
}

/**
 * check for proper json command and command validation, call the
 * right function for each command by calling call_command_handler function.
 **/

void dispatch(char *data) {
    char *parse_string = data;
    LOG_DEBUG("Command being parsed is: %s \n", parse_string);

    cJSON *json = NULL;
    cJSON *cmd = NULL;
    cJSON *payload = NULL;
    json = cJSON_Parse(parse_string);

    // check for proper json string code goes here before cJSON_GetObjectItem gets called
    if ( json == NULL) {
        const char *error_ptr = cJSON_GetErrorPtr();
        if ( error_ptr != NULL) {
            LOG_ERROR("%s %s", error_ptr, " is invalid json");
            emit(response_string[BAD_JSON]);
        }
        /* warning: memory is allocated to store the parsed JSON and
         * must be freed by cJSON_Delete(json); to prevent memory lea */
        cJSON_Delete(json);
        return;
    }

    cmd = cJSON_GetObjectItem(json, "cmd");
    payload = cJSON_GetObjectItem(json, "payload");

    if ( cmd == NULL) {
        /* warning: memory is allocated to store the parsed JSON and
         * must be freed by cJSON_Delete(json); to prevent memory leaK */
        LOG_ERROR("cmd argument is NULL\n");
        emit(response_string[COMMAND_NOT_FOUND]);
        cJSON_Delete(json);
        return;
    }
    if ( payload == NULL) {
        /* warning: memory is allocated to store the parsed JSON and
         * must be freed by cJSON_Delete(json); to prevent memory leaK */
        LOG_ERROR("payload argument is NULL\n");
        emit(response_string[PAYLOAD_NOT_FOUND]);
        cJSON_Delete(json);
        return;
    }
    char *cmd_value = cmd->valuestring;

    /* check for command type and call the right function if exist */
    call_command_handler(cmd_value, payload);

    /* warning: memory is allocated to store the parsed JSON and
         * must be freed by cJSON_Delete(json); to prevent memory lea */
    cJSON_Delete(json);
}

void queue_and_memory_pool_destroy(queue_t *queue, memory_pool_t *pool) {
    memory_pool_destroy(pool);
    free(queue);
}

bool commands_in_queue(queue_t *queue) {
    if ( queue->head ) {
        return true;
    }
    return false;
}

size_t size_of_node_struct() {
    return sizeof(node_t);
}

void print_list(queue_t *queue) {
    LOG_DEBUG("Current liked_list size is: %zu ", queue->size);
    LOG_DEBUG("Commands queue consists of: ");
    queue->temp = queue->head;
    while ( queue->temp != NULL) {
        LOG_DEBUG("%s %s ", queue->temp->data, "-->");
        queue->temp = queue->temp->next;
    }
    LOG_DEBUG("NULL\n");
}
