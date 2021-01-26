#include "ZmqPublisherConnector.h"

namespace strata::connector
{

ZmqPublisherConnector::ZmqPublisherConnector() : ZmqConnector(ZMQ_PUB), mSubscribers_()
{
    CONNECTOR_DEBUG_LOG("%s Creating connector object\n", "ZMQ_PUB");
}

ZmqPublisherConnector::~ZmqPublisherConnector()
{
}

bool ZmqPublisherConnector::open(const std::string& ip_address)
{
    if (false == socketConnected()) {
        return false;
    }

    int linger = 0;
    if (0 == socketSetOptInt(zmq::sockopt::linger, linger) &&
        0 == socketBind(ip_address)) {
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
    if (false == socketConnected()) {
        return false;
    }

    for (const std::string& dealerID : mSubscribers_) {
        if ((false == socketSendMore(dealerID)) || (false == socketSend(message))) {
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

}
