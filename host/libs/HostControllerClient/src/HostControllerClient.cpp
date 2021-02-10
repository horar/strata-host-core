#include "HostControllerClient.hpp"

namespace strata::hcc {

using Connector = strata::connector::Connector;

HostControllerClient::HostControllerClient(const std::string& net_in_address)
    : connector_(Connector::getConnector(Connector::CONNECTOR_TYPE::DEALER))
{
    // will be a random 5 byte identity by default (0 + a random 32bit integer)
    //connector_->setDealerID("HostControllerClient");
    connector_->open(net_in_address);
}

HostControllerClient::~HostControllerClient()
{
}

bool HostControllerClient::close()
{
    // interupts the blocking read on messages in the notification_thread_
    return connector_->shutdown();
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
