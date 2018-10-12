/*
 * Author:
 * Ian Cain         date: 10/1/2018
 * Updated:
 * Mustafa Alshehab date: 10/10/2018
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <memory.h>
#include "memory_pool.h"

/* MACROS for debug purposes */
#define DEBUG_MESSAGES 1  // 1 to enable debug/error print messages

#if DEBUG_MESSAGES
  #define MAX_MSG_SIZE 500
  #define FLE (strrchr(__FILE__, '/') ? strrchr(__FILE__, '/') + 1 : __FILE__)
  #define LOG_DEBUG(format, args...) do { \
    char msg[MAX_MSG_SIZE]; \
    sprintf(msg,format,##args);  \
    printf("<%s:%s(%d)> %s\n",FLE,__func__,__LINE__,msg); \
  } while(0)
  #define LOG_ERROR(format, args...) do { \
    char msg[MAX_MSG_SIZE]; \
    sprintf(msg,format,##args);  \
    printf("<%s:%s(%d)> ERROR: %s\n",FLE,__func__,__LINE__,msg); \
  } while(0)
#else
#define LOG_DEBUG(format, args...)
#define LOG_ERROR(format, args...)
#endif

#define BREAK_IF(exp, format,args...) \
    { if(exp) { \
    LOG_ERROR(format, ##args); \
    break; \
    } \
  }
// HTODB = header to data block
//     converts header pointer to container data block
//
#define MEMORY_POOL_HTODB(_header_, _block_size_) ((void *)_header_ - _block_size_)

// DBTOH = data block to header
//     convert data block pointer to point to embedded header information block
//
#define MEMORY_POOL_DBTOH(_data_block_, _block_size_) ((memory_pool_block_header_t *)(_data_block_ + _block_size_))

// magic value to check for data corruption
#define NODE_MAGIC 0xBAADA555

// PRIVATE: declared inside *.c file
typedef struct memory_pool_block_header {

    uint32_t magic;      // NODE_MAGIC
    size_t size;
    bool inuse;      // true = currently allocated. Protects against double free.

    struct memory_pool_block_header * next;
} memory_pool_block_header_t;

struct memory_pool {

    size_t count;         // total elements
    size_t block_size;   // size of each block
    size_t available;
    struct memory_pool_block_header * pool;   // working pool
    void ** shadow;    // shadow stack for destroy/book keeping
};

memory_pool_t * memory_pool_init(size_t count, size_t block_size)
{
    memory_pool_t *mp = NULL;
    memory_pool_block_header_t * last;
    void * block = NULL;
    size_t n = 0;

    mp = (memory_pool_t*) malloc (sizeof(memory_pool_t));
    if( mp == NULL ) {
        LOG_ERROR("unable to malloc memory_pool_t. OOM");
        return NULL;
    }

    mp->pool = NULL;
    mp->block_size = 0;
    mp->available = 0;
    mp->count = 0;

    // create shadow array of data blocks for memory clean up during destory
    mp->shadow = (void**) malloc(sizeof(void *) * count);
    if( mp->shadow == NULL ) {
        LOG_ERROR("unable to malloc shadow. OOM");
        return NULL;
    }

    for( n = 0; n < count; ++n ) {
        // allocate data block
        //   data block size + header siz
        //
        size_t total_size = block_size + sizeof(memory_pool_block_header_t);
        block = malloc (total_size);
        BREAK_IF( block == NULL, "OOM ERROR.");

        mp->shadow[n] = block;  // save shadow

        // move to end of data block to create header
        //
        memory_pool_block_header_t *header = MEMORY_POOL_DBTOH(block, block_size);
        header->magic = NODE_MAGIC;  // set the magic for data integrity checks
        header->size = block_size;
        header->inuse = false;
        header->next = NULL;

        if( mp->pool == NULL ) {
            mp->pool = header;  // pool is empty set first node
            last = header;

            LOG_DEBUG("MEMORY_POOL: i=%zu, data=%p, header=%p, block_size=%zu, next=%p",
                      n, block, header, header->size, header->next);
            continue;
        }

        // add new node to stack
        last->next = header;
        last = header;

        LOG_DEBUG("MEMORY_POOL: i=%zu, data=%p, header=%p, block_size=%zu, next=%p",
                  n, block, header, header->size, header->next);
    }

    LOG_DEBUG("memory_pool_init(mp=%p, count=%zu, block_size=%zu)", mp, count, block_size);

    mp->count = count;
    mp->block_size = block_size;
    mp->available = count;

    return n == count ? mp : NULL;
}

bool memory_pool_destroy(memory_pool_t *mp)
{
    if( mp == NULL ) {
        LOG_ERROR(" memory_pool handle == NULL");
        return false;
    }

    LOG_DEBUG("mp = %p, count=%zu, block_size=%zu)", mp, mp->count, mp->block_size);

    for(size_t n = 0; n < mp->count; ++n ) {
        LOG_DEBUG(" + block: i=%zu, data=%p", n, mp->shadow[n]);
        memory_pool_block_header_t * header = MEMORY_POOL_DBTOH(mp->shadow[n], mp->block_size);

        header->magic = 0;  // lose the magic
        header->size = 0;
        header->inuse = 0;

        free(mp->shadow[n]);
    }

    mp->count = 0;
    mp->block_size = 0;
    mp->available = 0;
    free(mp->shadow);
    free(mp);

    return true;
}

void * memory_pool_acquire(memory_pool_t * mp)
{
    if( mp == NULL ) {
        LOG_ERROR(" memory pool invalid.");
        return false;
    }

    if( ! mp->available ) {
        LOG_ERROR(" mp=%p, memory pool empty.", mp);
        return false;
    }

    memory_pool_block_header_t *header = mp->pool;

    // get data block from header
    void * data = MEMORY_POOL_HTODB(header, mp->block_size);

    mp->pool->inuse = true;
    mp->pool = mp->pool->next;               // pop stack item
    mp->available --;
    LOG_DEBUG(" mp=%p, data=%p, magic =%x", mp, data, header->magic);
    return data;
}

bool memory_pool_release(memory_pool_t *mp, void * data)
{

    if( mp == NULL ) {
        LOG_ERROR(" memory pool invalid.");
        return false;
    }

    if( data == NULL ) {
        LOG_ERROR("ERROR: memory_pool_release: bad handle. NULL");
        return false;
    }

    memory_pool_block_header_t * header = MEMORY_POOL_DBTOH(data, mp->block_size);

    if( ! header->inuse ) {
        LOG_ERROR("mp=%p, data=%p, double release of data block", mp, data);
        return false;
    }

    if( header->magic != NODE_MAGIC ) {
        LOG_ERROR("bad handle magic. You lost the magic");
        return false;
    }

    LOG_DEBUG("data=%p, header=%p, block_size=%zu, next=%p", data, header, header->size, header->next);

    // push on stack
    header->next = mp->pool;
    header->inuse = false;

    mp->pool = header;
    mp->available ++;

    return true;
}

size_t memory_pool_available(memory_pool_t *mp)
{
    if( mp == NULL ) {
        LOG_ERROR("memory pool invalid");
        return 0;
    }
    return mp->available;
}

void memory_pool_dump(memory_pool_t *mp)
{
    if( mp == NULL ) {
        LOG_ERROR(" memory pool invalid");
        return;
    }

    LOG_DEBUG("mp = %p, count=%zu, available=%zu, block_size=%zu)",
              mp, mp->count, mp->available, mp->block_size);

    memory_pool_block_header_t * header = mp->pool;

    for( size_t n = 0; n < mp->available; ++n, header = header->next ) {
        void * data_block = MEMORY_POOL_HTODB(header, mp->block_size);
        LOG_DEBUG(" + block: data=%p, shadow=%p, header=%p, inuse=%s, block_size=%zu, next=%p, magic %x",
                  data_block, mp->shadow[n], header, header->inuse ? "TRUE":"FALSE", header->size, header->next, header->magic);

    }
}
