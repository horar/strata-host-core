/*
 * HostControllerService.cpp
 *
 *  Created on: Aug 14, 2017
 *      Author: abhishek
 */

#include "USBConnector.h"
#include "ZeroMQConnector.h"
#include "Connector.h"
#include "ConnectFactory.h"
#include "ArduinoJson.h"
#include <libserialport.h>

#ifndef LIB_HOSTCONTROLLERSERVICE_H_
#define LIB_HOSTCONTROLLERSERVICE_H_

void callbackServiceHandler(evutil_socket_t fd ,short what, void* hostP );
void callbackConnectionHandler(evutil_socket_t fd ,short what, void* hostP);

class HostControllerService {

public:

	struct host_packet {

		zmq::socket_t* command;
		zmq::socket_t* notify;

		Connector *platform;
		Connector *service;
		HostControllerService *hcs;

		event_base *base;
	}hostP;

	HostControllerService(string ipRouter, string ipPub);
	~HostControllerService();

	friend void callbackServiceHandler(evutil_socket_t fd ,short what, void* hostP);
	void callbackPlatformHandler(void* hostP);

	string setupHostControllerService(string ipRouter, string ipPub);
	bool openPlatformSocket();
	void initPlatformSocket();
	bool verifyReceiveCommand(string command, string *response);

	bool _connect;
	std::string disconnect;
	struct sp_port *platform_socket_;
  struct sp_event_set *ev;
  sp_return error;

private :

	ConnectFactory *conObj;
	zmq::context_t* context;
	zmq::socket_t* commandAck;
	zmq::socket_t* notifyAll;
};

#endif
