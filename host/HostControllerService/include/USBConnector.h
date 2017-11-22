/*
 * USBConnector.h
 *
 *  Created on: Jul 20, 2017
 *      Author: abhishek
 */

#ifndef LIB_USBCONNECTOR_H_
#define LIB_USBCONNECTOR_H_

#include "Connector.h"




/*!
 * Class to handle functionality of USB connection
 */
class USBConnector : public Connector{

public :
	USBConnector();

	bool sendAck(messageProperty,void *);
	bool sendNotification(messageProperty,void *);
	messageProperty receive(void *);
	bool connectivitycheck(string address);

	virtual ~USBConnector();
private:
	vector<char> response;
};

#endif /* LIB_USBCONNECTOR_H_ */
