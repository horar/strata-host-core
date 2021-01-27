#include "ZmqPublisherConnector.h"

namespace strata::connector
{

ZmqPublisherConnector::ZmqPublisherConnector() : ZmqConnector(ZMQ_PUB), mSubscribers_()
{
    qCInfo(logCategoryZmqPublisherConnector) << "ZMQ_PUB Creating connector object";
}

ZmqPublisherConnector::~ZmqPublisherConnector()
{
}

bool ZmqPublisherConnector::open(const std::string& ip_address)
{
    if (false == socketOpen()) {
        qCCritical(logCategoryZmqPublisherConnector) << "Unable to open socket";
        return false;
    }

    int linger = 0;
    if (socketSetOptInt(zmq::sockopt::linger, linger) &&
        socketBind(ip_address)) {
        setConnectionState(true);
        qCInfo(logCategoryZmqPublisherConnector).nospace()
                << "Connected to the server socket '" << ip_address.c_str()
                << "' (ID: " << getDealerID().c_str() << ")";
        return true;
    }

    qCCritical(logCategoryZmqPublisherConnector).nospace()
            << "Unable to configure and/or connect to server socket '" << ip_address.c_str() << "'";

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
        qCCritical(logCategoryZmqPublisherConnector) << "Unable to send messages, socket not open";
        return false;
    }

    for (const std::string& dealerID : mSubscribers_) {
        if ((false == socketSendMore(dealerID)) || (false == socketSend(message))) {
            qCWarning(logCategoryZmqPublisherConnector).nospace()
                    << "Failed to send message: " << message.c_str() << " (ID: " << getDealerID().c_str() << ")";
            return false;
        }
        qCDebug(logCategoryZmqPublisherConnector).nospace()
                << "Tx'ed message: " << message.c_str() << " (ID: " << getDealerID().c_str() << ")";
    }

    return true;
}

void ZmqPublisherConnector::addSubscriber(const std::string& dealerID)
{
    mSubscribers_.insert(dealerID);
    qCDebug(logCategoryZmqPublisherConnector) << "Added subscriber:" << dealerID.c_str();
}

}
