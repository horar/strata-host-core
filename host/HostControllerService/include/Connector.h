/*
 * Connector.h
 *
 */

#ifndef CONNECTOR_H__
#define CONNECTOR_H__

#include <iostream>
#include <string>
#include <stdlib.h>

#include <event2/event.h>
#include <event.h>
#include <libserialport.h>
#include <thread>
#include <mutex>
#include <condition_variable>
#include <cstdio>
#include <cstring>
#include <vector>

#include "zmq.hpp"
#include "zmq_addon.hpp"
#include "zhelpers.hpp"
#include <fcntl.h>   // File control definitions
#include <errno.h>   // Error number definitions

#ifdef _WIN32
#include <winsock2.h>
#include <windows.h>
#endif

/*!
 * Interface class defining basic functionality of HostControllerService
 */
class Connector {

public :

    struct messageProperty {
	    std::string nodeId;
        std::string message;
    };

    virtual bool  sendAck(messageProperty,void *)= 0;
    virtual bool  sendNotification(messageProperty,void *)= 0;
    virtual messageProperty receive(void *)=0;
    virtual messageProperty emulatorReceive(void *)=0;
    virtual bool  emulatorSend(messageProperty,void *)= 0;
    virtual bool connectivitycheck(std::string address)=0;

    virtual ~Connector(){}
    std::mutex lock_serial_;
    std::mutex lock_zmq_;
};


#endif /* LIB_CONNECTORINTERFACE_H_ */
