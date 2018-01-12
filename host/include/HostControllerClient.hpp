#ifndef HOSTCONTROLLERCLIENT_H
#define HOSTCONTROLLERCLIENT_H

#include <iostream>
#include <string>
#include <stdlib.h>
#include "zhelpers.hpp"
#include "zmq_addon.hpp"

// TODO move this to a configuration file
#define LOCAL_HOST_CONTROLLER_SERVICE 1
#if LOCAL_HOST_CONTROLLER_SERVICE
#define HOST_CONTROLLER_SERVICE_OUT_ADDRESS "tcp://127.0.0.1:5564"
#define HOST_CONTROLLER_SERVICE_IN_ADDRESS "tcp://127.0.0.1:5563"
#else
#define HOST_CONTROLLER_SERVICE_OUT_ADDRESS "tcp://192.168.1.64:5564"
#define HOST_CONTROLLER_SERVICE_IN_ADDRESS "tcp://192.168.1.64:5563"
#endif

namespace Spyglass {

class HostControllerClient {

public:
    inline HostControllerClient() {

        context = new zmq::context_t;
        sendCmdSocket = new zmq::socket_t(*context,ZMQ_DEALER);
        sendCmdSocket->connect(HOST_CONTROLLER_SERVICE_OUT_ADDRESS);
        sendCmdSocket->setsockopt(ZMQ_IDENTITY,"ONSEMI",sizeof("ONSEMI"));

        notificationSocket = new zmq::socket_t(*context,ZMQ_SUB);
        notificationSocket->connect(HOST_CONTROLLER_SERVICE_IN_ADDRESS);
        notificationSocket->setsockopt(ZMQ_SUBSCRIBE,"ONSEMI",strlen("ONSEMI"));

        //TODO Unique Identity generator which will be replaced by random generator sent by HostControllerService in future

#if (defined (WIN32))
        s_set_id(*sendCmdSocket, (intptr_t)1);
#else
        s_set_id(*sendCmdSocket);
#endif

        //request platform-id first step before proceeding with further request
        std::string cmd= "{\"cmd\":\"request_platform_id\",\"Host_OS\":\"Linux\"}";
        s_send(*sendCmdSocket,cmd.c_str());


    }

    inline ~HostControllerClient() {}

    inline bool sendCmd(std::string cmd) {
        if(s_send(*sendCmdSocket,cmd.c_str()))
        {
            return true;
        }
        else
            return false;
    }

    inline std::string receiveCommandAck() {
        std::string response = s_recv(*sendCmdSocket);
        return response;
    }

    inline std::string receiveNotification() {
        s_recv(*notificationSocket);
        std::string response = s_recv(*notificationSocket);
        return response;
    }

    zmq::context_t *context;
    zmq::socket_t *sendCmdSocket;
    zmq::socket_t *notificationSocket;
};
}
#endif // HOSTCONTROLLERCLIENT_H
