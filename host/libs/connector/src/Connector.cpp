
#include "SerialConnector.h"
#include "ZmqDealerConnector.h"
#include "ZmqPublisherConnector.h"
#include "ZmqRequestConnector.h"
#include "ZmqResponseConnector.h"
#include "ZmqRouterConnector.h"
#include "ZmqSubscriberConnector.h"

void Connector::addSubscriber(const std::string&)
{
    assert(false);
}

void Connector::setDealerID(const std::string& id)
{
    dealer_id_ = id;
}

std::string Connector::getDealerID() const
{
    return dealer_id_;
}

void Connector::setPlatformUUID(const std::string& id)
{
    platform_uuid_ = id;
}

std::string Connector::getPlatformUUID() const
{
    return platform_uuid_;
}

bool Connector::isSpyglassPlatform() const
{
    return spyglass_platform_connected_;
}

void Connector::setConnectionState(bool connection_state)
{
    connection_state_ = connection_state;
}

bool Connector::isConnected() const
{
    return connection_state_;
}

void Connector::setPlatformConnected(bool state)
{
    spyglass_platform_connected_ = state;
}

std::ostream& operator<<(std::ostream& stream, const Connector& c)
{
    std::cout << "Connector: " << std::endl;
    std::cout << "  server: " << c.server_ << std::endl;
    return stream;
}

namespace ConnectorFactory
{
Connector* getConnector(const CONNECTOR_TYPE type)
{
    CONNECTOR_DEBUG_LOG("ConnectorFactory::getConnector type: %d", type);
    switch (type) {
        case CONNECTOR_TYPE::SERIAL:
            return static_cast<Connector*>(new SerialConnector);
            break;
        case CONNECTOR_TYPE::ROUTER:
            return static_cast<Connector*>(new ZmqRouterConnector());
            break;
        case CONNECTOR_TYPE::DEALER:
            return static_cast<Connector*>(new ZmqDealerConnector());
            break;
        case CONNECTOR_TYPE::PUBLISHER:  // not used yet
            return static_cast<Connector*>(new ZmqPublisherConnector());
            break;
        case CONNECTOR_TYPE::SUBSCRIBER:
            return static_cast<Connector*>(new ZmqSubscriberConnector());
            break;
        case CONNECTOR_TYPE::REQUEST:
            return static_cast<Connector*>(new ZmqRequestConnector());
            break;
        case CONNECTOR_TYPE::RESPONSE:  // not used yet
            return static_cast<Connector*>(new ZmqResponseConnector());
            break;
        default:
            CONNECTOR_DEBUG_LOG("ERROR: ConnectorFactory::getConnector - %d (unknown interface).",
                                type);
            break;
    }
    return nullptr;
}

}  // namespace ConnectorFactory
