
#include "ZmqDealerConnector.h"
#include <zmq.hpp>

ZmqDealerConnector::ZmqDealerConnector() : ZmqConnector(ZMQ_DEALER)
{
    CONNECTOR_DEBUG_LOG("%s Creating connector object\n", "ZMQ_DEALER");
}

ZmqDealerConnector::~ZmqDealerConnector()
{
}

bool ZmqDealerConnector::open(const std::string& ip_address)
{
    if (false == socket_->init()) {
        return false;
    }

    const std::string& id = getDealerID();
    if (false == id.empty() && 0 != socket_->setsockopt(ZMQ_IDENTITY, id.c_str(), id.length())) {
        return false;
    }

    int linger = 0;
    if (0 == socket_->setsockopt(ZMQ_LINGER, &linger, sizeof(linger)) &&
        0 == socket_->connect(ip_address.c_str())) {
        CONNECTOR_DEBUG_LOG("%s Connecting to the server socket %s(ID:%s)\n", "ZMQ_DEALER",
                            ip_address.c_str(), getDealerID().c_str());
        return true;
    }

    return false;
}
