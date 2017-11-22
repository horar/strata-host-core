/*
 * zeroMQConnector.h
 *
 *  Created on: Jul 20, 2017
 *      Author: abhishek
 */

#ifndef LIB_ZEROMQCONNECTOR_H_
#define LIB_ZEROMQCONNECTOR_H_

#include "Connector.h"
#include <event2/event.h>
#include <event.h>
#include <string.h>

//verify received JsonCommand object and return JsonAck

class ZeroMQConnector : public Connector{

public :

	ZeroMQConnector();

	bool sendAck(messageProperty message, void *service);
	bool sendNotification(messageProperty message, void *service);
	messageProperty receive(void *service);
	bool connectivitycheck(string address);

	virtual ~ZeroMQConnector();
};

#endif /* LIB_ZEROMQCONNECTOR_H_ */
