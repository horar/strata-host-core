#pragma once

#include <Connector.h>

#include <memory>
#include <string>

namespace strata::hcc
{
class HostControllerClient
{
public:
    HostControllerClient(const std::string &net_in_address);
    ~HostControllerClient();

    bool close();
    bool sendCmd(const std::string &cmd);

    std::string receiveCommandAck();
    std::string receiveNotification();

private:
    std::unique_ptr<strata::connector::Connector> connector_;
};

}  // namespace strata::hcc
