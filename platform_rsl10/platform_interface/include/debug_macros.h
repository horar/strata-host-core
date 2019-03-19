//
// Created by Mustafa Alshehab on 3/19/19.
//

#ifndef PLATFORM_INTERFACE_DEBUG_MACROS_H
#define PLATFORM_INTERFACE_DEBUG_MACROS_H

#include <printf.h>

/* MACROS FOR DEBUG PURPOSES */
#if 1
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

#endif //PLATFORM_INTERFACE_DEBUG_MACROS_H
