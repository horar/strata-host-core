
#include "Connector_impl.h"

void Connector::setDealerID(const std::string& id)
{
    dealer_id_ = id;
}

void Connector::setPlatformUUID(const std::string& id)
{
    platform_uuid_ = id;
}

void Connector::setConnectionState(bool connection_state)
{
    connection_state_ = connection_state;
}

void Connector::setPlatformConnected(bool state)
{
    spyglass_platform_connected_ = state;
}

namespace ConnectorFactory {

Connector* getConnector(const std::string& type)
{
    std::cout << "ConnectorFactory::getConnector type:" << type << std::endl;
    if( type == "router") {
        return static_cast<Connector*>(new ZMQConnector("router"));
    }
    else if( type == "dealer") {
        return static_cast<Connector*>(new ZMQConnector("dealer"));
    }
    else if( type == "platform") {
        return static_cast<Connector*>(new SerialConnector);
    }
    else if( type == "request") {
        return static_cast<Connector*>(new  RequestReplyConnector);
    }
    else if( type == "subscriber") {
        return static_cast<Connector*>(new  PublisherSubscriberConnector("subscribe"));
    }
    else {
        std::cout << "ERROR: ConnectorFactory::getConnector - unknown interface. " << type << std::endl;
    }
    return nullptr;
}

}
