#include "ZmqRouterConnector.h"

namespace strata::connector
{
ZmqRouterConnector::ZmqRouterConnector() : ZmqConnector(ZMQ_ROUTER)
{
    CONNECTOR_DEBUG_LOG("Creating ZMQ %s connector object\n", "ZMQ_ROUTER");
}

ZmqRouterConnector::~ZmqRouterConnector()
{
}

bool ZmqRouterConnector::open(const std::string& ip_address)
{
    if (false == socketOpen()) {
        return false;
    }

    int linger = 0;
    if (0 == socketSetOptInt(zmq::sockopt::linger, linger) &&
        0 == socketBind(ip_address)) {
        setConnectionState(true);
        return true;
    }
    return false;
}

bool ZmqRouterConnector::read(std::string& message)
{
    if (false == socketConnected()) {
        return false;
    }

    zmq::pollitem_t items = {*socket_, 0, ZMQ_POLLIN, 0};
    if (false == socketPoll(&items)) {
        return false;
    }
    if (items.revents & ZMQ_POLLIN) {
        std::string identity;

        if (socketRecv(identity) && socketRecv(message)) {
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
    if (false == socketConnected()) {
        return false;
    }

    std::string identity;
    if (socketRecv(identity) && socketRecv(message)) {
        setDealerID(identity);
        CONNECTOR_DEBUG_LOG("%s [Socket] Rx'ed message : %s(ID: %s)\n", "ZMQ_ROUTER",
                            message.c_str(), getDealerID().c_str());
        return true;
    }
    return false;
}

bool ZmqRouterConnector::send(const std::string& message)
{
    if (false == socketConnected()) {
        return false;
    }

    if ((false == socketSendMore(getDealerID())) || (false == socketSend(message))) {
        return false;
    }

    CONNECTOR_DEBUG_LOG("%s [Socket] Tx'ed message : %s(ID: %s)\n", "ZMQ_ROUTER", message.c_str(),
                        getDealerID().c_str());

    return true;
}

}  // namespace strata::connector
