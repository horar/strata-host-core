//
// Created by Ian Cain on 2/26/18.
//

#ifndef HOSTCONTROLLERSERVICE_LOGGER_H
#define HOSTCONTROLLERSERVICE_LOGGER_H

#define WRAPQUOTE(key)  #key
#define RED_TEXT_START WRAPQUOTE(\033[1;31m)
#define RED_TEXT_END WRAPQUOTE(\033[0m)

#define __EXTRACT_FILE(__path) (strrchr(__path, '/') ? strrchr(__path, '/') + 1 : __path)
#define __FLE __EXTRACT_FILE(__FILE__)

#define PDEBUG(log,__format, ...) do {\
	if(log>0) {\
		printf("<%s:%s(%d)>: ",__FLE,__func__,__LINE__ );\
		printf(__format,##__VA_ARGS__);\
		printf("\n");\
	}\
} while(0)



#endif //HOSTCONTROLLERSERVICE_LOGGER_H
