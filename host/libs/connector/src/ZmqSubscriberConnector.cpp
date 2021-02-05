#include "ZmqSubscriberConnector.h"

namespace strata::connector
{

ZmqSubscriberConnector::ZmqSubscriberConnector() : ZmqConnector(ZMQ_SUB)
{
    qCInfo(logCategoryZmqSubscriberConnector) << "ZMQ_SUB Creating connector object";
}

ZmqSubscriberConnector::~ZmqSubscriberConnector()
{
}

bool ZmqSubscriberConnector::open(const std::string& ip_address)
{
    if (false == socketAndContextOpen()) {
        qCCritical(logCategoryZmqSubscriberConnector) << "Unable to open socket";
        return false;
    }

    int linger = 0;
    if (socketSetOptInt(zmq::sockopt::linger, linger) &&
        socketSetOptString(zmq::sockopt::subscribe, getDealerID()) &&
        socketConnect(ip_address)) {
        setConnectionState(true);
        qCInfo(logCategoryZmqSubscriberConnector).nospace().noquote()
                << "Connected to the server socket '" << QString::fromStdString(ip_address)
                << "' with filter '0x" << QByteArray::fromStdString(getDealerID()).toHex() << "'";
        return true;
    }

    qCCritical(logCategoryZmqSubscriberConnector).nospace().noquote()
            << "Unable to configure and/or connect to server socket '"
            << QString::fromStdString(ip_address) << "'";
    close();
    return false;
}

bool ZmqSubscriberConnector::send(const std::string&)
{
    assert(false);
    return false;
}

bool ZmqSubscriberConnector::read(std::string& message)
{
    if (false == socketValid()) {
        qCCritical(logCategoryZmqSubscriberConnector) << "Unable to read messages, socket not open";
        return false;
    }

    zmq::pollitem_t items = {*socket_, 0, ZMQ_POLLIN, 0};
    if (false == socketPoll(&items)) {
        qCWarning(logCategoryZmqSubscriberConnector) << "Failed to poll items";
        return false;
    }

    if (items.revents & ZMQ_POLLIN) {
        std::string identity;
        if (socketRecv(identity) && socketRecv(message)) {
            setDealerID(identity);
            qCDebug(logCategoryZmqSubscriberConnector).nospace().noquote()
                    << "Rx'ed message: '" << QString::fromStdString(message)
                    << "' (ID: 0x" << QByteArray::fromStdString(getDealerID()).toHex() << ")";
            return true;
        } else {
            qCWarning(logCategoryZmqSubscriberConnector) << "Failed to read messages";
        }
    }

    return false;
}

bool ZmqSubscriberConnector::blockingRead(std::string& message)
{
    if (false == socketValid()) {
        qCCritical(logCategoryZmqSubscriberConnector) << "Unable to blocking read messages, socket not open";
        return false;
    }

    std::string identity;
    if (socketRecv(identity) && socketRecv(message)) {
        setDealerID(identity);
        qCDebug(logCategoryZmqSubscriberConnector).nospace().noquote()
                << "Rx'ed blocking message: '" << QString::fromStdString(message)
                << "' (ID: 0x" << QByteArray::fromStdString(getDealerID()).toHex() << ")";
        return true;
    } else {
        if(false == socketValid()) {
            qCDebug(logCategoryZmqSubscriberConnector) << "Context was terminated, blocking read was interrupted";
        } else {
            qCWarning(logCategoryZmqSubscriberConnector) << "Failed to blocking read messages";
        }
    }

    return false;
}

}  // namespace strata::connector
