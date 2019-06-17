#ifndef HOSTCONTROLLERCLIENT_H
#define HOSTCONTROLLERCLIENT_H

#include <Connector.h>

#include <memory>
#include <string>

// TODO move this to a configuration file

//  // Remote connection support
//  #define HOST_CONTROLLER_SERVICE_IN_ADDRESS "tcp://127.0.0.1:5563"

namespace Spyglass
{
class HostControllerClient
{
public:
    HostControllerClient(const char *net_in_address);
    ~HostControllerClient();

    bool sendCmd(const std::string &cmd);

    std::string receiveCommandAck();
    std::string receiveNotification();

private:
    std::unique_ptr<Connector> connector_;
};

}  // namespace Spyglass

#endif  // HOSTCONTROLLERCLIENT_H
