
#include "ZmqResponseConnector.h"
#include <zmq.hpp>

ZmqResponseConnector::ZmqResponseConnector() : ZmqConnector(ZMQ_REP)
{
    CONNECTOR_DEBUG_LOG("%s Creating connector object\n", "ZMQ_REP");
}

ZmqResponseConnector::~ZmqResponseConnector()
{
}

bool ZmqResponseConnector::open(const std::string& ip_address)
{
    if (false == socket_->init()) {
        return false;
    }

    int linger = 0;
    if (0 == socket_->setsockopt(ZMQ_LINGER, &linger, sizeof(linger)) &&
        0 == socket_->bind(ip_address.c_str())) {
        setConnectionState(true);
        CONNECTOR_DEBUG_LOG("%s Open server socket %s(ID:%s)\n", "ZMQ_REP", ip_address.c_str(),
                            getDealerID().c_str());
        return true;
    }

    return false;
}
