
#include "ZmqRouterConnector.h"
#include <zhelpers.hpp>

ZmqRouterConnector::ZmqRouterConnector() : ZmqConnector(ZMQ_ROUTER)
{
    CONNECTOR_DEBUG_LOG("Creating ZMQ %s connector object\n", "ZMQ_ROUTER");
}

ZmqRouterConnector::~ZmqRouterConnector()
{
}

bool ZmqRouterConnector::open(const std::string& ip_address)
{
    if (false == socket_->init()) {
        return false;
    }

    int linger = 0;
    if (0 == socket_->setsockopt(ZMQ_LINGER, &linger, sizeof(linger)) &&
        0 == socket_->bind(ip_address.c_str())) {
        setConnectionState(true);
        return true;
    }
    return false;
}

bool ZmqRouterConnector::read(std::string& message)
{
    if (false == socket_->valid()) {
        return false;
    }

    zmq::pollitem_t items = {*socket_, 0, ZMQ_POLLIN, 0};
    if (-1 == zmq::poll(&items, 1, SOCKET_POLLING_TIMEOUT)) {
        return false;
    }
    if (items.revents & ZMQ_POLLIN) {
        std::string identity;

        if (s_recv(*socket_, identity) && s_recv(*socket_, message)) {
            setDealerID(identity);
            CONNECTOR_DEBUG_LOG("%s [Socket] Rx'ed message : %s(ID: %s)\n", "ZMQ_ROUTER",
                                message.c_str(), getDealerID().c_str());
            return true;
        }
    }
    return false;
}

bool ZmqRouterConnector::blockingRead(std::string& message)
{
    if (false == socket_->valid()) {
        return false;
    }

    std::string identity;
    if (s_recv(*socket_, identity) && s_recv(*socket_, message)) {
        setDealerID(identity);
        CONNECTOR_DEBUG_LOG("%s [Socket] Rx'ed message : %s(ID: %s)\n", "ZMQ_ROUTER",
                            message.c_str(), getDealerID().c_str());
        return true;
    }
    return false;
}

bool ZmqRouterConnector::send(const std::string& message)
{
    if (false == socket_->valid()) {
        return false;
    }

    if (false == s_sendmore(*socket_, getDealerID()) || false == s_send(*socket_, message)) {
        return false;
    }

    CONNECTOR_DEBUG_LOG("%s [Socket] Tx'ed message : %s(ID: %s)\n", "ZMQ_ROUTER", message.c_str(),
                        getDealerID().c_str());

    return true;
}
