#ifndef HOSTCONTROLLERCLIENT_H
#define HOSTCONTROLLERCLIENT_H

#include <iostream>
#include <string>
#include <stdlib.h>
#include <zhelpers.hpp>
#include <zmq_addon.hpp>

// TODO move this to a configuration file

//  // Remote connection support
//  #define HOST_CONTROLLER_SERVICE_IN_ADDRESS "tcp://127.0.0.1:5563"

namespace Spyglass {

class HostControllerClient {

public:
    HostControllerClient(const char* net_in_address);
    ~HostControllerClient();

    inline bool sendCmd(const std::string& cmd)
    {
        return s_send(*notificationSocket_, cmd.c_str());
    }

    inline std::string receiveCommandAck()
    {
        return std::string(s_recv(*notificationSocket_));
    }

    inline std::string receiveNotification()
    {
        return std::string(s_recv(*notificationSocket_));
    }

private:
    zmq::context_t *context_;
    zmq::socket_t *sendCmdSocket_;
    zmq::socket_t *notificationSocket_;

};

}

#endif // HOSTCONTROLLERCLIENT_H
