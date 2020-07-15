#pragma once

#include <Connector.h>

#include <memory>
#include <string>

// TODO move this to a configuration file

//  // Remote connection support
//  #define HOST_CONTROLLER_SERVICE_IN_ADDRESS "tcp://127.0.0.1:5563"

namespace strata::hcc {

class HostControllerClient
{
public:
    HostControllerClient(const char *net_in_address);
    ~HostControllerClient();

    bool close();
    bool closeContext();
    bool sendCmd(const std::string &cmd);

    std::string receiveCommandAck();
    std::string receiveNotification();

private:
    std::unique_ptr<Connector> connector_;
};

}  // namespace
