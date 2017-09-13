/*
 * connectorInterface.h
 *
 *  Created on: Jul 20, 2017
 *      Author: abhishek
 */
#include <iostream>
#include <string>
#include <stdlib.h>
#include <syslog.h>
#include <event2/event.h>
#include <event.h>
#include <thread>
#include <mutex>
#include <condition_variable>
#include <thread>
#include <cstdio>
#include <cstring>
#include <vector>
#include <termios.h>

#include "ZeroMQConnector.h"
#include "zmq.hpp"
#include "zmq_addon.hpp"
#include "zhelpers.hpp"

using namespace std;

#ifndef LIB_CONNECTOR_H_
#define LIB_CONNECTOR_H_

#define DEBUG
#ifdef DEBUG
#define DBGLEVEL LOG_DEBUG
#define SYSLOGLEVEL LOG_WARNING
#define dbgprint(level, ...) {\
	if(level <= SYSLOGLEVEL) syslog(LOG_WARNING, __VA_ARGS__);\
	if(level <= DBGLEVEL) printf(__VA_ARGS__); putchar('\n');\
}

#else // DEBUG
#define dbgprint(...)
#endif // DEBUG

/*!
 * Interface class defining basic functionality of HostControllerService
 */
class Connector {

public :

	struct messageProperty {

		string nodeId;
		string message;
	};

	virtual bool  sendAck(messageProperty,void *)= 0;
	virtual bool  sendNotification(messageProperty,void *)= 0;
	virtual messageProperty receive(void *)=0;
	virtual bool connectivitycheck(string address)=0;

	virtual ~Connector(){}
};


#endif /* LIB_CONNECTORINTERFACE_H_ */
