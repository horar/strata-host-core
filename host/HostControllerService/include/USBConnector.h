/*
 * USBConnector.h
 *
 *  Created on: Jul 20, 2017
 *      Author: abhishek
 */

#ifndef USBCONNECTOR_H_
#define USBCONNECTOR_H_

#include "Connector.h"

/*!
 * Class to handle functionality of USB connection
 */
class USBConnector : public Connector {

public :
	USBConnector();

	bool sendAck(messageProperty,void *);
	bool sendNotification(messageProperty,void *);
	messageProperty receive(void *);
	bool connectivitycheck(std::string address);

	virtual ~USBConnector();
private:
	std::vector<char> response;
};

#endif // USBCONNECTOR_H_
