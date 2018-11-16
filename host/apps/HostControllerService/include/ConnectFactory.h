/*
 * ConnectFactory.h
 */

#ifndef CONNECTFACTORY_H_
#define CONNECTFACTORY_H_

#include "Connector.h"
#include "USBConnector.h"
#include "ZeroMQConnector.h"

/*!
 * Class to obtain the service/platform object
 */
class ConnectFactory {

public:
	ConnectFactory();
	Connector *getServiceTypeObject(std::string type);
	~ConnectFactory();
};

#endif /* CONNECTFACTORY_H_ */
