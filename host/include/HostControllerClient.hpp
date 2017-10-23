
#include <iostream>
#include <string>
#include <stdlib.h>
#include "zhelpers.hpp"
#include "zmq_addon.hpp"


#ifndef HOSTCONTROLLERCLIENT_H
#define HOSTCONTROLLERCLIENT_H

namespace hcc {

  class HostControllerClient {

  public:
    inline HostControllerClient() {

      context = new zmq::context_t;
      sendCmdSocket = new zmq::socket_t(*context,ZMQ_DEALER);
      sendCmdSocket->connect("tcp://127.0.0.1:5564");
      sendCmdSocket->setsockopt(ZMQ_IDENTITY,"ONSEMI",sizeof("ONSEMI"));

      notificationSocket = new zmq::socket_t(*context,ZMQ_SUB);
      notificationSocket->connect("tcp://127.0.0.1:5563");
      notificationSocket->setsockopt(ZMQ_SUBSCRIBE,"ONSEMI",strlen("ONSEMI"));

      //Unique Identity generator
      //Will be replaced by random generator sent by HostControllerService in future

      #if (defined (WIN32))
      s_set_id(*sendCmdSocket, (intptr_t)1);
      #else
      s_set_id(*sendCmdSocket);
      #endif

      //request platform-id first step before proceeding with further request
      std::string cmd= "{\"cmd\":\"request_platform_id\",\"Host_OS\":\"Linux\"}";
      s_send(*sendCmdSocket,cmd.c_str());
      s_recv(*sendCmdSocket);
    }
    inline ~HostControllerClient() {}

    inline bool sendCmd(std::string cmd) {
      s_send(*sendCmdSocket,cmd.c_str());
      std::cout << "Command Sent " << cmd <<std::endl;
      return true;
    }
    inline std::string receiveCommandAck() {
      std::string response = s_recv(*sendCmdSocket);
      return response;
    }
    inline std::string receiveNotification() {
      s_recv(*notificationSocket);
      std::string response = s_recv(*notificationSocket);
      std::cout << "Received String " << response <<std::endl;
      return response;
    }

  private:
    zmq::context_t *context;
    zmq::socket_t *sendCmdSocket;
    zmq::socket_t *notificationSocket;
  };
}
#endif // HOSTCONTROLLERCLIENT_H
