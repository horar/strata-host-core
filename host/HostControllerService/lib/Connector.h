/*
 * connectorInterface.h
 *
 *  Created on: Jul 20, 2017
 *      Author: abhishek
 */
#include <iostream>
#include <string>
#include <stdlib.h>

#include <event2/event.h>
#include <event.h>
#include<libserialport.h>
#include <thread>
#include <mutex>
#include <condition_variable>
#include <cstdio>
#include <cstring>
#include <vector>

#include "ZeroMQConnector.h"
#include "zmq.hpp"
#include "zmq_addon.hpp"
#include "zhelpers.hpp"
#include <fcntl.h>   // File control definitions
#include <errno.h>   // Error number definitions

using namespace std;

#ifndef LIB_CONNECTOR_H_
#define LIB_CONNECTOR_H_


#ifdef _WIN32
#include <winsock2.h>
#include <windows.h>
#endif

extern std::mutex lock_serial_;
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
