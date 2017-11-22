/*
* USBConnector.cpp
*
*/

#include "USBConnector.h"
#include "HostControllerService.h"

USBConnector::USBConnector()
{
    response.reserve(512);
}

USBConnector::~USBConnector(){}

bool USBConnector::sendAck(messageProperty message,void *HCS)
{
    //Not used
    return true;
}

bool USBConnector::sendNotification(messageProperty message,void *HCS)
{
    HostControllerService * obj = (HostControllerService *)HCS;

    string cmd = message.message + "\n";

    lock_serial_.lock();
    obj->error = sp_blocking_write(obj->platform_socket_,(void *)cmd.c_str(),cmd.length(),5);
    lock_serial_.unlock();

    if(obj->error  > 0 ) {
      return true;
    }
    else {
      return false;
    }
}

Connector::messageProperty USBConnector::receive(void *HCS)
{
    HostControllerService *obj =(HostControllerService *)HCS;
    Connector::messageProperty message;

    char temp = '\0';
    sp_wait(obj->ev, 0);
    obj->error = sp_nonblocking_read(obj->platform_socket_,(void *)&temp,1);
    #ifndef _WIN32
    if(obj->error <= 0) {
      cout << "error = " << obj->error << "\n";
      cout << "Platform Disconnected " <<endl;
      message.message="DISCONNECTED";
      return message;
    }
    #else
    if(obj->error <= -1) {
        cout << "error = " << obj->error << "\n";
        cout << "Platform Disconnected " <<endl;
        message.message="DISCONNECTED";
        return message;
      }
    if (obj->error == 0) {
        Sleep(200);
        message.message="";
        return message;
    }
  #endif

    if(temp !='\n') {
      response.push_back(temp);
      message.message="";
      return message;
    }
    else {
      if(!response.empty()) {
          string new_string(response.begin(),response.end());
          cout << "Received Message = " << new_string  << endl;
          response.clear();
          message.message = new_string;
          return message;
      }
  }
}

bool USBConnector::connectivitycheck(string address)
{
  return true;
}
