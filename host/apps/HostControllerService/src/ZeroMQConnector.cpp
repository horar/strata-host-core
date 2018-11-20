/*
 * zeroMQConnector.cpp
 *
 *  Created on: Jul 20, 2017
 *      Author: abhishek
 */

#include "ZeroMQConnector.h"

using namespace std;

//Constructor
ZeroMQConnector::ZeroMQConnector() {}

//Destructor
ZeroMQConnector::~ZeroMQConnector() {}

/*!
 *  send notification feed to HostControllerClient
 * 	receive command request from HostControllerClient
 */
bool ZeroMQConnector::sendAck(messageProperty message,void *service)
{
	zmq::socket_t *soc = (zmq::socket_t *)service;

	s_sendmore(*soc,message.nodeId);
	s_send (*soc,message.message);
	return true;
}

bool ZeroMQConnector::sendNotification(messageProperty message,void *service)
{
	lock_zmq_.lock();
	zmq::socket_t *soc = (zmq::socket_t *)service;
	s_sendmore(*soc,"ONSEMI");
	s_send (*soc,message.message);
	lock_zmq_.unlock();
	// cout << "----> Notification to UI = "<< message.message << endl;
	return true;
}

/*!
 *  receive command request from HostControllerClient
 */
Connector::messageProperty ZeroMQConnector::emulatorReceive(void *service)
{
	zmq::socket_t *soc = (zmq::socket_t *)service;
	Connector::messageProperty message;
	string jsonCommandString ="";
	while(!(jsonCommandString=="\n")) {
		string nodeid = s_recv (*soc);
		jsonCommandString = s_recv(*soc);
		message.nodeId= nodeid;
		message.message.append(jsonCommandString);
	}
		// cout << "received message "<<message.message<<endl;
	return message;
}

/*!
 *  send command from HCS to emulator
 *  ZMTP to non ZMTP
 */
bool ZeroMQConnector::emulatorSend(messageProperty message,void *service)
{
	zmq::socket_t *soc = (zmq::socket_t *)service;
	uint8_t id [256];
	size_t id_size = 256;
	// lock_zmq_.lock();
	soc->getsockopt(ZMQ_IDENTITY,&id,&id_size);
	soc->send(id,id_size,ZMQ_SNDMORE);
	message.message.append("\n");
	bool success = s_send(*soc,message.message);
	// lock_zmq_.unlock();
	return success;
}

Connector::messageProperty ZeroMQConnector::receive(void *service)
{
	zmq::socket_t *soc = (zmq::socket_t *)service;
	Connector::messageProperty message;
	string nodeid = s_recv (*soc);
	string jsonCommandString = s_recv(*soc);
	message.nodeId= nodeid;
	message.message= jsonCommandString;
	cout << "received message "<<message.message<<endl;
	return message;
}
/*!
 *  To be used in future, currently no use case available
 */
bool ZeroMQConnector::connectivitycheck(string address)
{
	cout << "Connectivity check from ZMQConnector" <<endl;
	return true;
}
