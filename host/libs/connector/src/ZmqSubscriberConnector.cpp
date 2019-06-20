#include "ZmqSubscriberConnector.h"
#include <zhelpers.hpp>

ZmqSubscriberConnector::ZmqSubscriberConnector() : ZmqConnector(ZMQ_SUB)
{
    CONNECTOR_DEBUG_LOG("Creating ZMQ %s connector object\n", "ZMQ_SUB");
}

ZmqSubscriberConnector::~ZmqSubscriberConnector()
{
}

bool ZmqSubscriberConnector::open(const std::string& ip_address)
{
    if (false == socket_->init()) {
        return false;
    }

    int linger = 0;
    if (0 == socket_->setsockopt(ZMQ_LINGER, &linger, sizeof(linger)) &&
        0 == socket_->setsockopt(ZMQ_SUBSCRIBE, getDealerID().c_str(), getDealerID().size()) &&
        0 == socket_->connect(ip_address.c_str())) {
        setConnectionState(true);
        CONNECTOR_DEBUG_LOG("%s Connecting to the server socket %s with filter '%s'\n", "ZMQ_SUB",
                            ip_address.c_str(), getDealerID().c_str());
        return true;
    }

    return false;
}

bool ZmqSubscriberConnector::send(const std::string&)
{
    assert(false);
    return false;
}

bool ZmqSubscriberConnector::read(std::string& message)
{
    if (false == socket_->valid()) {
        return false;
    }

    zmq::pollitem_t items = {*socket_, 0, ZMQ_POLLIN, 0};
    if (-1 == zmq::poll(&items, 1, REQUEST_SOCKET_TIMEOUT)) {
        return false;
    }
    if (items.revents & ZMQ_POLLIN) {
        std::string identity;

        if (s_recv(*socket_, identity) && s_recv(*socket_, message)) {
            setDealerID(identity);
            CONNECTOR_DEBUG_LOG("%s [Socket] Rx'ed message : %s(ID: %s)\n", "ZMQ_SUB",
                                message.c_str(), getDealerID().c_str());
            return true;
        }
    }

    return false;
}
