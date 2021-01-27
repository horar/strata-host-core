#include "ZmqRouterConnector.h"

namespace strata::connector
{
ZmqRouterConnector::ZmqRouterConnector() : ZmqConnector(ZMQ_ROUTER)
{
    qCInfo(logCategoryZmqRouterConnector) << "ZMQ_ROUTER Creating connector object";
}

ZmqRouterConnector::~ZmqRouterConnector()
{
}

bool ZmqRouterConnector::open(const std::string& ip_address)
{
    if (false == socketOpen()) {
        qCCritical(logCategoryZmqRouterConnector) << "Unable to open socket";
        return false;
    }

    int linger = 0;
    if (socketSetOptInt(zmq::sockopt::linger, linger) &&
        socketBind(ip_address)) {
        setConnectionState(true);
        qCInfo(logCategoryZmqRouterConnector).nospace()
                << "Connected to the server socket '" << ip_address.c_str()
                << "' (ID: " << getDealerID().c_str() << ")";
        return true;
    }

    qCCritical(logCategoryZmqRouterConnector).nospace()
            << "Unable to configure and/or connect to server socket '" << ip_address.c_str() << "'";

    return false;
}

bool ZmqRouterConnector::read(std::string& message)
{
    if (false == socketConnected()) {
        qCCritical(logCategoryZmqRouterConnector) << "Unable to read messages, socket not open";
        return false;
    }

    zmq::pollitem_t items = {*socket_, 0, ZMQ_POLLIN, 0};
    if (false == socketPoll(&items)) {
        qCWarning(logCategoryZmqRouterConnector) << "Failed to poll items";
        return false;
    }

    if (items.revents & ZMQ_POLLIN) {
        std::string identity;
        if (socketRecv(identity) && socketRecv(message)) {
            setDealerID(identity);
            qCDebug(logCategoryZmqRouterConnector).nospace()
                    << "Rx'ed message: " << message.c_str() << " (ID: " << getDealerID().c_str() << ")";
            return true;
        } else {
            qCWarning(logCategoryZmqRouterConnector) << "Failed to read messages";
        }
    }

    return false;
}

bool ZmqRouterConnector::blockingRead(std::string& message)
{
    if (false == socketConnected()) {
        qCCritical(logCategoryZmqRouterConnector) << "Unable to blocking read messages, socket not open";
        return false;
    }

    std::string identity;
    if (socketRecv(identity) && socketRecv(message)) {
        setDealerID(identity);
        qCDebug(logCategoryZmqRouterConnector).nospace()
                << "Rx'ed blocking message: " << message.c_str() << " (ID: " << getDealerID().c_str() << ")";
        return true;
    } else {
        qCWarning(logCategoryZmqRouterConnector) << "Failed to read blocking messages";
    }

    return false;
}

bool ZmqRouterConnector::send(const std::string& message)
{
    if (false == socketConnected()) {
        qCCritical(logCategoryZmqRouterConnector) << "Unable to send messages, socket not open";
        return false;
    }

    if ((false == socketSendMore(getDealerID())) || (false == socketSend(message))) {
        qCWarning(logCategoryZmqRouterConnector).nospace()
                << "Failed to send message: " << message.c_str() << " (ID: " << getDealerID().c_str() << ")";
        return false;
    }

    qCDebug(logCategoryZmqRouterConnector).nospace()
            << "Tx'ed message: " << message.c_str() << " (ID: " << getDealerID().c_str() << ")";

    return true;
}

}  // namespace strata::connector
