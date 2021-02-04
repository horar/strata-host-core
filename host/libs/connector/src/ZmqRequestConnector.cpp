#include "ZmqRequestConnector.h"

namespace strata::connector
{

ZmqRequestConnector::ZmqRequestConnector() : ZmqConnector(ZMQ_REQ)
{
    qCInfo(logCategoryZmqRequestConnector) << "ZMQ_REQ Creating connector object";
}

ZmqRequestConnector::~ZmqRequestConnector()
{
}

bool ZmqRequestConnector::open(const std::string& ip_address)
{
    if (false == socketAndContextOpen()) {
        qCCritical(logCategoryZmqRequestConnector) << "Unable to open socket";
        return false;
    }

    int linger = 0;
    if (socketSetOptInt(zmq::sockopt::linger, linger) &&
        socketConnect(ip_address)) {
        setConnectionState(true);
        qCInfo(logCategoryZmqRequestConnector).nospace()
                << "Connected to the server socket '" << ip_address.c_str()
                << "' (ID: " << getDealerID().c_str() << ")";
        return true;
    }

    qCCritical(logCategoryZmqRequestConnector).nospace()
            << "Unable to configure and/or connect to server socket '" << ip_address.c_str() << "'";
    close();
    return false;
}

}  // namespace strata::connector
