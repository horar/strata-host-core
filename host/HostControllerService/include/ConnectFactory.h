/*
 * ConnectFactory.h
 *
 *  Created on: Jul 20, 2017
 *      Author: abhishek
 */

#ifndef LIB_CONNECTFACTORY_H_
#define LIB_CONNECTFACTORY_H_

#include "Connector.h"
#include "USBConnector.h"
#include "ZeroMQConnector.h"

/*!
 * Class to obtain the service/platform object
 */
class ConnectFactory {

public:
	ConnectFactory();
	Connector *getServiceTypeObject(string type);
	~ConnectFactory();
};

#endif /* LIB_CONNECTFACTORY_H_ */
