#include "ZmqResponseConnector.h"

namespace strata::connector
{

ZmqResponseConnector::ZmqResponseConnector() : ZmqConnector(ZMQ_REP)
{
    CONNECTOR_DEBUG_LOG("%s Creating connector object\n", "ZMQ_REP");
}

ZmqResponseConnector::~ZmqResponseConnector()
{
}

bool ZmqResponseConnector::open(const std::string& ip_address)
{
    if (false == socketOpen()) {
        return false;
    }

    int linger = 0;
    if (socketSetOptInt(zmq::sockopt::linger, linger) &&
        socketBind(ip_address)) {
        setConnectionState(true);
        CONNECTOR_DEBUG_LOG("%s Open server socket %s(ID:%s)\n", "ZMQ_REP", ip_address.c_str(),
                            getDealerID().c_str());
        return true;
    }

    return false;
}

}  // namespace strata::connector
