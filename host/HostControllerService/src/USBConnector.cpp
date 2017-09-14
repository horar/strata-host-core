/*
* USBConnector.cpp
*
*  Created on: Jul 20, 2017
*      Author: abhishek
*/

#include "USBConnector.h"
#include "HostControllerService.h"



USBConnector::USBConnector() {

  response.reserve(512);
}

USBConnector::~USBConnector(){}

bool USBConnector::sendAck(messageProperty message,void *HCS) {
  //Not used
  return true;
}

bool USBConnector::sendNotification(messageProperty message,void *HCS) {

  HostControllerService * obj = (HostControllerService *)HCS;

  string cmd = message.message + "\n";

  lock_serial_.lock();
  obj->error = sp_blocking_write(obj->platform_socket_,(void *)cmd.c_str(),cmd.length(),5);
  lock_serial_.unlock();

  if(obj->error  > 0 ) {

    return true;
  } else {

    return false;
  }
}

Connector::messageProperty USBConnector::receive(void *HCS) {

  HostControllerService *obj =(HostControllerService *)HCS;
  Connector::messageProperty message;

  char temp = '\0';
  sp_wait(obj->ev, 0);
  //sp_blocking_read_next(obj->platform_socket_,(void *)&temp,1,0);
	obj->error = sp_nonblocking_read(obj->platform_socket_,(void *)&temp,1);

	if(obj->error <= 0) {

    cout << "Platform Disconnected " <<endl;
		message.message="DISCONNECTED";
		return message;
	}

  if(temp!= '\n' && temp != '\0') {

    response.push_back(temp);
    message.message="";
    return message;
  } else if(temp == '\n') {

    string new_string(response.begin(),response.end());
    cout << "Received Message = " << new_string  << endl;
    response.clear();
    message.message = new_string;
    return message;
  } else {

    //cout << "cout returning else " <<endl;
    message.message="";
    return message;
  }
}



bool USBConnector::connectivitycheck(string address) {

  return true;
}
