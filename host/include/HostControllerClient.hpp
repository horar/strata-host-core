#ifndef HOSTCONTROLLERCLIENT_H
#define HOSTCONTROLLERCLIENT_H

#include <iostream>
#include <string>
#include <stdlib.h>
#include "zhelpers.hpp"
#include "zmq_addon.hpp"

// TODO move this to a configuration file


#define LOCAL_HOST_CONTROLLER_SERVICE 0
#if LOCAL_HOST_CONTROLLER_SERVICE
// local support
#define HOST_CONTROLLER_SERVICE_OUT_ADDRESS "tcp://127.0.0.1:5564"
#define HOST_CONTROLLER_SERVICE_IN_ADDRESS "tcp://127.0.0.1:5563"


namespace Spyglass {

class HostControllerClient {

public:
    inline HostControllerClient()
    {
        context = new zmq::context_t;
        sendCmdSocket = new zmq::socket_t(*context,ZMQ_DEALER);
        sendCmdSocket->connect(HOST_CONTROLLER_SERVICE_OUT_ADDRESS);
        sendCmdSocket->setsockopt(ZMQ_IDENTITY,"ONSEMI",sizeof("ONSEMI"));

        notificationSocket = new zmq::socket_t(*context,ZMQ_SUB);
        notificationSocket->connect(HOST_CONTROLLER_SERVICE_IN_ADDRESS);
        notificationSocket->setsockopt(ZMQ_SUBSCRIBE,"ONSEMI",strlen("ONSEMI"));

#if (defined (WIN32))
        s_set_id(*sendCmdSocket, (intptr_t)1);
#else
        s_set_id(*sendCmdSocket);
#endif

        // TODO: [prasanth] Sending the platform id request is vital in this version
        // The platform id notification is required by UI to know if board is connected
        // On UI launch this message is sent to HCS and then HCS sends back the platform
        //id notification
        std::string cmd= "{\"cmd\":\"request_platform_id\"}";
        s_send(*sendCmdSocket,cmd.c_str());
    }

    inline ~HostControllerClient() {}

    inline bool sendCmd(std::string cmd)
    {
        if(s_send(*sendCmdSocket,cmd.c_str())) {
            return true;
        }
        else {
            return false;
        }
    }

    inline std::string receiveCommandAck()
    {
        return std::string(s_recv(*sendCmdSocket));
    }

    inline std::string receiveNotification()
    {
        return std::string(s_recv(*notificationSocket));
    }

    zmq::context_t *context;
    zmq::socket_t *sendCmdSocket;
    zmq::socket_t *notificationSocket;
};
}

#else
// Remote connection support
#define HOST_CONTROLLER_SERVICE_IN_ADDRESS "tcp://127.0.0.1:5563"


namespace Spyglass {

class HostControllerClient {

public:
    inline HostControllerClient()
    {
        context = new zmq::context_t;

        notificationSocket = new zmq::socket_t(*context,ZMQ_DEALER);
        notificationSocket->connect(HOST_CONTROLLER_SERVICE_IN_ADDRESS);
//        notificationSocket->setsockopt(ZMQ_SUBSCRIBE,"ONSEMI",strlen("ONSEMI"));

#if (defined (WIN32))
        s_set_id(*notificationSocket, (intptr_t)1);
#else
        s_set_id(*notificationSocket);
#endif

        // TODO: [prasanth] Sending the platform id request is vital in this version
        // The platform id notification is required by UI to know if board is connected
        // On UI launch this message is sent to HCS and then HCS sends back the platform
        //id notification
//        std::string cmd= "{\"cmd\":\"request_platform_id\"}";
//        s_send(*notificationSocket,cmd.c_str());
    }

    inline ~HostControllerClient() {}

    inline bool sendCmd(std::string cmd)
    {
        if(s_send(*notificationSocket,cmd.c_str())) {
            return true;
        }
        else {
            return false;
        }
    }

    inline std::string receiveCommandAck()
    {
        return std::string(s_recv(*notificationSocket));
    }

    inline std::string receiveNotification()
    {
        return std::string(s_recv(*notificationSocket));
    }

    zmq::context_t *context;
    zmq::socket_t *sendCmdSocket;
    zmq::socket_t *notificationSocket;
};
}
#endif
#endif // HOSTCONTROLLERCLIENT_H
