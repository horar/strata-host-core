
#include "ZmqPublisherConnector.h"
#include <zhelpers.hpp>

ZmqPublisherConnector::ZmqPublisherConnector() : ZmqConnector(ZMQ_PUB), mSubscribers_()
{
    CONNECTOR_DEBUG_LOG("%s Creating connector object\n", "ZMQ_PUB");
}

ZmqPublisherConnector::~ZmqPublisherConnector()
{
}

bool ZmqPublisherConnector::open(const std::string& ip_address)
{
    if (false == socket_->init()) {
        return false;
    }

    int linger = 0;
    if (0 == socket_->setsockopt(ZMQ_LINGER, &linger, sizeof(linger)) &&
        0 == socket_->bind(ip_address.c_str())) {
        setConnectionState(true);
        CONNECTOR_DEBUG_LOG("%s Open server socket %s(ID:%s)\n", "ZMQ_PUB", ip_address.c_str(),
                            getDealerID().c_str());
        return true;
    }
    return false;
}

bool ZmqPublisherConnector::read(std::string&)
{
    assert(false);
    return false;
}

bool ZmqPublisherConnector::send(const std::string& message)
{
    if (false == socket_->valid()) {
        return false;
    }

    for (const std::string& dealerID : mSubscribers_) {
        if (false == s_sendmore(*socket_, dealerID) || false == s_send(*socket_, message)) {
            return false;
        }

        CONNECTOR_DEBUG_LOG("%s [Socket] Tx'ed message (ID: %s): %s\n", "ZMQ_PUB", dealerID.c_str(),
                            message.c_str());
    }

    return true;
}

void ZmqPublisherConnector::addSubscriber(const std::string& dealerID)
{
    mSubscribers_.insert(dealerID);
}
