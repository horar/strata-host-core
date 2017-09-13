/*
 * USBConnector.cpp
 *
 *  Created on: Jul 20, 2017
 *      Author: abhishek
 */

#include "USBConnector.h"
#include "HostControllerService.h"


/*!
 * 	\brief:
 * 		Initializes responseUSB vector char with static size
 */
USBConnector::USBConnector() {

	responseUSB.reserve(512);
}

/*!
 * \brief :
 * 		Destructor
 */
USBConnector::~USBConnector(){}

/*!
 * \brief:
 * 		Not used, currently used by ZMQConnector only
 */
bool USBConnector::sendAck(messageProperty message,void *HCS) {
	//Not used
	return true;
}

/*!
 * \brief:
 * 		Command to ZMQConnector is notification to USB
 * 		Command received from HostControllerClient is reported to Platform
 * 	@params:
 * 		message :struct of type messageProperty
 * 		HCS		:Object of type HostControllerService
 */
bool USBConnector::sendNotification(messageProperty message,void *HCS) {

	HostControllerService * obj = (HostControllerService *)HCS;

	string cmd = message.message + "\n";
	const char *msg={cmd.c_str()};
	int bytes=0;
	bytes = write(obj->_platformSocket,(void *)msg,strlen(msg));

	if(bytes > 0) {

		cout << "Command = " << message.message <<endl;
		return true;
	} else {

		cout << "Command Send failed (Platform)" <<endl;
		cout << "Failed Command = " << message.message <<endl;
		return false;
	}
}

/*!
 * \brief:
 * 		Receives notification updates from platform
 * 	@params:
 * 		HCS		:Object of type HostControllerService
 */
Connector::messageProperty USBConnector::receive(void *HCS) {

	HostControllerService *obj =(HostControllerService *)HCS;
	Connector::messageProperty message;

	char temp = '\0';
	int pos;
	int pointer=0;

	fd_set read_fds,write_fds,except_fds;

	FD_ZERO(&read_fds);
	FD_ZERO(&write_fds);
	FD_ZERO(&except_fds);
	FD_SET(obj->_platformSocket,&read_fds);

	struct timeval timeout;
	timeout.tv_sec = 1;
	timeout.tv_usec = 0;

	if (select(obj->_platformSocket+1, &read_fds,&write_fds, &except_fds,&timeout) == 1) {

		pos= read(obj->_platformSocket,&temp,1);

		if(pos == 0) {

			message.message = "DISCONNECTED";
			//cout << "PLATFORM DISCONNECTED "<< endl;
			dbgprint(LOG_DEBUG,"PLATFORM DISCONNECTED ");
			close(obj->_platformSocket);
			return message;
		}

		if(temp != '\n' && temp != '\0') {

			responseUSB.push_back(temp);
			temp='\0';
		} else if(temp == '\n') {

			string newString(responseUSB.begin(),responseUSB.end());
			message.message = newString;
			//cout << "Received Message over serial port = " << message.message <<endl;
			dbgprint(LOG_WARNING, string(string("Received Message over serial port = ")+message.message).c_str());
			responseUSB.clear();
			return message;
		}

		message.message="";
		return message;
	} else {

		//cout <<"time out Error " <<endl;
		dbgprint(LOG_DEBUG,"time out Error ");
		message.message="";
		return message;
	}
}
/*!
 * \brief:
 * 		Not used
 */


bool USBConnector::connectivitycheck(string address) {

	return true;
}


