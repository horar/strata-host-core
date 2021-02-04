#include "ZmqDealerConnector.h"

namespace strata::connector
{

ZmqDealerConnector::ZmqDealerConnector() : ZmqConnector(ZMQ_DEALER)
{
    qCInfo(logCategoryZmqDealerConnector) << "ZMQ_DEALER Creating connector object";
}

ZmqDealerConnector::~ZmqDealerConnector()
{
}

bool ZmqDealerConnector::open(const std::string& ip_address)
{
    if (false == socketAndContextOpen()) {
        qCCritical(logCategoryZmqDealerConnector) << "Unable to open socket";
        return false;
    }

    int linger = 0;
    const std::string& id = getDealerID();
    if ((id.empty() || socketSetOptString(zmq_identity, id)) &&
        socketSetOptInt(zmq::sockopt::linger, linger) &&
        socketConnect(ip_address)) {
        setConnectionState(true);
        qCInfo(logCategoryZmqDealerConnector).nospace().noquote()
                << "Connected to the server socket '" << QString::fromStdString(ip_address)
                << "' (ID: " << QString::fromStdString(getDealerID()) << ")";
        return true;
    }

    qCCritical(logCategoryZmqDealerConnector).nospace().noquote()
            << "Unable to configure and/or connect to server socket '" << QString::fromStdString(ip_address) << "'";
    close();
    return false;
}

}  // namespace strata::connector
