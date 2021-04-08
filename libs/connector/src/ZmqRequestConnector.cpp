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
        qCInfo(logCategoryZmqRequestConnector).nospace().noquote()
                << "Connected to the server socket '" << QString::fromStdString(ip_address)
                << "' (ID: 0x" << QByteArray::fromStdString(getDealerID()).toHex() << ")";
        return true;
    }

    qCCritical(logCategoryZmqRequestConnector).nospace().noquote()
            << "Unable to configure and/or connect to server socket '"
            << QString::fromStdString(ip_address) << "'";
    close();
    return false;
}

} // namespace strata::connector
