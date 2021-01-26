#include "ZmqRequestConnector.h"
#include <zmq.hpp>

namespace strata::connector
{

ZmqRequestConnector::ZmqRequestConnector() : ZmqConnector(ZMQ_REQ)
{
    CONNECTOR_DEBUG_LOG("%s Creating connector object\n", "ZMQ_REQ");
}

ZmqRequestConnector::~ZmqRequestConnector()
{
}

bool ZmqRequestConnector::open(const std::string& ip_address)
{
    if (false == socketConnected()) {
        return false;
    }

    int linger = 0;
    if (0 == socketSetOptInt(zmq::sockopt::linger, linger) &&
        0 == socketConnect(ip_address)) {
        setConnectionState(true);
        CONNECTOR_DEBUG_LOG("%s Connecting to the server socket %s(ID:%s)\n", "ZMQ_REQ",
                            ip_address.c_str(), getDealerID().c_str());
        return true;
    }

    return false;
}

}  // namespace strata::connector
