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
    if (false == socketAndContextOpen()) {
        qCCritical(logCategoryZmqPublisherConnector) << "Unable to open socket";
        return false;
    }

    int linger = 0;
    if (socketSetOptInt(zmq::sockopt::linger, linger) &&
        socketBind(ip_address)) {
        setConnectionState(true);
        qCInfo(logCategoryZmqPublisherConnector).nospace().noquote()
                << "Connected to the server socket '" << QString::fromStdString(ip_address)
                << "' (ID: " << QString::fromStdString(getDealerID()) << ")";
        return true;
    }

    qCCritical(logCategoryZmqPublisherConnector).nospace().noquote()
            << "Unable to configure and/or connect to server socket '" << QString::fromStdString(ip_address) << "'";
    close();
    return false;
}

bool ZmqPublisherConnector::read(std::string&)
{
    assert(false);
    return false;
}

bool ZmqPublisherConnector::send(const std::string& message)
{
    if (false == socketValid()) {
        qCCritical(logCategoryZmqPublisherConnector) << "Unable to send messages, socket not open";
        return false;
    }

    for (const std::string& dealerID : mSubscribers_) {
        if ((false == socketSendMore(dealerID)) || (false == socketSend(message))) {
            qCWarning(logCategoryZmqPublisherConnector).nospace().noquote()
                    << "Failed to send message: '" << QString::fromStdString(message) << "' (ID: " << QString::fromStdString(getDealerID()) << ")";
            return false;
        }
        qCDebug(logCategoryZmqPublisherConnector).nospace().noquote()
                << "Tx'ed message: '" << QString::fromStdString(message) << "' (ID: " << QString::fromStdString(getDealerID()) << ")";
    }

    return true;
}

void ZmqPublisherConnector::addSubscriber(const std::string& dealerID)
{
    mSubscribers_.insert(dealerID);
    qCDebug(logCategoryZmqPublisherConnector).noquote() << "Added subscriber:" << QString::fromStdString(getDealerID());
}

}
