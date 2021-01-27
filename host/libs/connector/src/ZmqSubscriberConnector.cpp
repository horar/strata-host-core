#include "ZmqSubscriberConnector.h"

namespace strata::connector
{

ZmqSubscriberConnector::ZmqSubscriberConnector() : ZmqConnector(ZMQ_SUB)
{
    CONNECTOR_DEBUG_LOG("Creating ZMQ %s connector object\n", "ZMQ_SUB");
}

ZmqSubscriberConnector::~ZmqSubscriberConnector()
{
}

bool ZmqSubscriberConnector::open(const std::string& ip_address)
{
    if (false == socketOpen()) {
        return false;
    }

    int linger = 0;
    if (socketSetOptInt(zmq::sockopt::linger, linger) &&
        socketSetOptString(zmq::sockopt::subscribe, getDealerID()) &&
        socketConnect(ip_address)) {
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
            CONNECTOR_DEBUG_LOG("%s [Socket] Rx'ed message : %s(ID: %s)\n", "ZMQ_SUB",
                                message.c_str(), getDealerID().c_str());
            return true;
        }
    }

    return false;
}

bool ZmqSubscriberConnector::blockingRead(std::string& message)
{
    if (false == socketConnected()) {
        return false;
    }

    std::string identity;

    if (socketRecv(identity) && socketRecv(message)) {
        setDealerID(identity);
        CONNECTOR_DEBUG_LOG("%s [Socket] Rx'ed message : %s(ID: %s)\n", "ZMQ_SUB",
                            message.c_str(), getDealerID().c_str());
        return true;
    }
    return false;
}

}  // namespace strata::connector
