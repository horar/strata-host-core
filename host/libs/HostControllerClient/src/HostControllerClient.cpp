#include "HostControllerClient.hpp"

namespace strata::hcc {

using Connector = strata::connector::Connector;

HostControllerClient::HostControllerClient(const std::string& net_in_address)
    : connector_(Connector::getConnector(Connector::CONNECTOR_TYPE::DEALER))
{
    connector_->open(net_in_address);
}

HostControllerClient::~HostControllerClient()
{
}

bool HostControllerClient::close()
{
    return connector_->close();
}

bool HostControllerClient::closeContext()
{
    return connector_->closeContext();
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
    return (connector_->read(message, strata::connector::ReadMode::BLOCKING) ? message : std::string());
}

}  // namespace
