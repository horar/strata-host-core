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
#include <fcntl.h>   // File control definitions
#include <errno.h>   // Error number definitions
#include <termios.h> // POSIX terminal control definitionss

#ifndef LIB_HOSTCONTROLLERSERVICE_H_
#define LIB_HOSTCONTROLLERSERVICE_H_

//#define DEFAULT_SERIAL_PATH  "/dev/ttyACM0"
#define DEFAULT_SERIAL_PATH  "/dev/ttyUSB0"

void callbackServiceHandler(evutil_socket_t fd ,short what, void* hostP );
void callbackPlatformHandler(evutil_socket_t fd ,short what, void* hostP);

class HostControllerService {

public:

	struct host_packet {

		int _plat;
		int _service;

		zmq::socket_t* command;
		zmq::socket_t* notify;

		Connector *platform;
		Connector *service;
		HostControllerService *hcs;
		event_base *base;
	}hostP;

	HostControllerService(string ipRouter, string ipPub);
	~HostControllerService();

	friend void callbackServiceHandler(evutil_socket_t fd ,short what, void* hostP );
	friend void callbackPlatformHandler(evutil_socket_t fd ,short what, void* hostP);

	string setupHostControllerService(string ipRouter, string ipPub);
	bool openPlatformSocket();
	void initPlatformSocket();
	bool verifyReceiveCommand(string command, string *response);

	bool _connect;
	int _platformSocket;
	struct termios _options;

private :

	ConnectFactory *conObj;
	string disconnect;
	zmq::context_t* context;
	zmq::socket_t* commandAck;
	zmq::socket_t* notifyAll;
};

#endif
