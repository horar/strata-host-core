#include "HostControllerClient.hpp"

namespace Spyglass
{
HostControllerClient::HostControllerClient(const char* net_in_address)
    : connector_(ConnectorFactory::getConnector(ConnectorFactory::CONNECTOR_TYPE::DEALER))
{
    connector_->open(net_in_address);
}

HostControllerClient::~HostControllerClient()
{
}

bool HostControllerClient::sendCmd(const std::string& cmd)
{
    return connector_->send(cmd);
}

std::string HostControllerClient::receiveCommandAck()
{
    std::string message;
    return (connector_->read(message) ? message : std::string());
}

std::string HostControllerClient::receiveNotification()
{
    std::string message;
    return (connector_->read(message,ReadMode::BLOCKING) ? message : std::string());
}

}  // namespace Spyglass
