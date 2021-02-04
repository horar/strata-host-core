#include "ZmqResponseConnector.h"

namespace strata::connector
{

ZmqResponseConnector::ZmqResponseConnector() : ZmqConnector(ZMQ_REP)
{
    qCInfo(logCategoryZmqResponseConnector) << "ZMQ_REP Creating connector object";
}

ZmqResponseConnector::~ZmqResponseConnector()
{
}

bool ZmqResponseConnector::open(const std::string& ip_address)
{
    if (false == socketAndContextOpen()) {
        qCCritical(logCategoryZmqResponseConnector) << "Unable to open socket";
        return false;
    }

    int linger = 0;
    if (socketSetOptInt(zmq::sockopt::linger, linger) &&
        socketBind(ip_address)) {
        setConnectionState(true);
        qCInfo(logCategoryZmqResponseConnector).nospace().noquote()
                << "Connected to the server socket '" << QString::fromStdString(ip_address)
                << "' (ID: " << QString::fromStdString(getDealerID()) << ")";
        return true;
    }

    qCCritical(logCategoryZmqResponseConnector).nospace().noquote()
            << "Unable to configure and/or connect to server socket '" << QString::fromStdString(ip_address) << "'";
    close();
    return false;
}

}  // namespace strata::connector
