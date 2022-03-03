/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include <assert.h>

#include "ZmqDealerConnector.h"
#include "ZmqPublisherConnector.h"
#include "ZmqRequestConnector.h"
#include "ZmqResponseConnector.h"
#include "ZmqRouterConnector.h"
#include "ZmqSubscriberConnector.h"
#include "logging/LoggingQtCategories.h"

namespace strata::connector
{
void Connector::addSubscriber(const std::string&)
{
    assert(false);
}

bool Connector::hasReadEvent()
{
    assert(false);
    return false;
}

bool Connector::hasWriteEvent()
{
    assert(false);
    return false;
}

void Connector::setDealerID(const std::string& id)
{
    // As a historical note, ZeroMQ v2.2 and earlier use UUIDs as identities.
    // ZeroMQ v3.0 and later generate a 5 byte identity by default (0 + a random 32bit integer).
    dealer_id_ = id;
}

std::string Connector::getDealerID() const
{
    return dealer_id_;
}

void Connector::setConnectionState(bool connection_state)
{
    connection_state_ = connection_state;
}

bool Connector::isConnected() const
{
    return connection_state_;
}

std::ostream& operator<<(std::ostream& stream, const Connector& c)
{
    std::cout << "Connector: " << std::endl;
    std::cout << "  server: " << c.server_ << std::endl;
    return stream;
}

std::unique_ptr<Connector> Connector::getConnector(const CONNECTOR_TYPE type)
{
    qCDebug(lcConnector) << "ConnectorFactory::getConnector type:" << (int)type;
    switch (type) {
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
            qCCritical(lcConnector)
                << "ConnectorFactory::getConnector, unknown interface:" << (int)type;
            break;
    }
    return nullptr;
}

} // namespace strata::connector
