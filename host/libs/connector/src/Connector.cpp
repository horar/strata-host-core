#include <assert.h>

//#include "SerialConnector.h"
#include "ZmqDealerConnector.h"
#include "ZmqPublisherConnector.h"
#include "ZmqRequestConnector.h"
#include "ZmqResponseConnector.h"
#include "ZmqRouterConnector.h"
#include "ZmqSubscriberConnector.h"

namespace strata::connector
{
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

bool Connector::isStrataPlatform() const
{
    return strata_platform_connected_;
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
    strata_platform_connected_ = state;
}

std::ostream& operator<<(std::ostream& stream, const Connector& c)
{
    std::cout << "Connector: " << std::endl;
    std::cout << "  server: " << c.server_ << std::endl;
    return stream;
}

std::unique_ptr<Connector> Connector::getConnector(const CONNECTOR_TYPE type)
{
    CONNECTOR_DEBUG_LOG("ConnectorFactory::getConnector type: %d\n", type);
    switch (type) {
            //        case CONNECTOR_TYPE::SERIAL:
            //            return std::make_unique<SerialConnector>();
        case CONNECTOR_TYPE::ROUTER:
            return std::make_unique<ZmqRouterConnector>();
        case CONNECTOR_TYPE::DEALER:
            return std::make_unique<ZmqDealerConnector>();
        case CONNECTOR_TYPE::PUBLISHER:  // not used yet
            return std::make_unique<ZmqPublisherConnector>();
        case CONNECTOR_TYPE::SUBSCRIBER:
            return std::make_unique<ZmqSubscriberConnector>();
        case CONNECTOR_TYPE::REQUEST:
            return std::make_unique<ZmqRequestConnector>();
        case CONNECTOR_TYPE::RESPONSE:  // not used yet
            return std::make_unique<ZmqResponseConnector>();
        default:
            CONNECTOR_DEBUG_LOG("ERROR: ConnectorFactory::getConnector - %d (unknown interface).",
                                type);
            break;
    }
    return nullptr;
}

}  // namespace strata::connector
