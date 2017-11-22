/*
 * zeroMQConnector.h
 *
 *  Created on: Jul 20, 2017
 *      Author: abhishek
 */

#ifndef ZEROMQCONNECTOR_H_
#define ZEROMQCONNECTOR_H_

#include <event2/event.h>
#include <event.h>
#include <string.h>

#include <Connector.h>

//verify received JsonCommand object and return JsonAck

class ZeroMQConnector : public Connector {

public :

	ZeroMQConnector();

	bool sendAck(messageProperty message, void *service);
	bool sendNotification(messageProperty message, void *service);
	messageProperty receive(void *service);
	bool connectivitycheck(std::string address);

	virtual ~ZeroMQConnector();
};

#endif // ZEROMQCONNECTOR_H_
