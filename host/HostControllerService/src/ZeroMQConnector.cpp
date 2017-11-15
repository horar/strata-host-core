/*
 * zeroMQConnector.cpp
 *
 *  Created on: Jul 20, 2017
 *      Author: abhishek
 */

#include "ZeroMQConnector.h"

//Constructor
ZeroMQConnector::ZeroMQConnector() {}

//Destructor
ZeroMQConnector::~ZeroMQConnector() {}


/*!
 *  send notification feed to HostControllerClient
 * 	receive command request from HostControllerClient
 */
bool ZeroMQConnector::sendAck(messageProperty message,void *service) {

	zmq::socket_t *soc = (zmq::socket_t *)service;

	s_sendmore(*soc,message.nodeId);
	s_send (*soc,message.message);
	return true;
}

bool ZeroMQConnector::sendNotification(messageProperty message,void *service) {

	zmq::socket_t *soc = (zmq::socket_t *)service;
	s_sendmore(*soc,"ONSEMI");
	s_send (*soc,message.message);
	//cout << "----> Notification to UI = "<< message.message << endl;
	return true;
}

/*!
 *  receive command request from HostControllerClient
 */
Connector::messageProperty ZeroMQConnector::receive(void *service) {

	zmq::socket_t *soc = (zmq::socket_t *)service;
	Connector::messageProperty message;
	string nodeid = s_recv (*soc);
	string jsonCommandString = s_recv(*soc);
	message.nodeId= nodeid;
	message.message= jsonCommandString;
	cout << "received message"<<message.message;
	return message;
}

/*!
 *  To be used in future, currently no use case available
 */
bool ZeroMQConnector::connectivitycheck(string address) {

	cout << "Connectivity check from ZMQConnector" <<endl;
	return true;
}
