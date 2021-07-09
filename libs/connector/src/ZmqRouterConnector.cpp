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
    if (false == socketAndContextOpen()) {
        qCCritical(logCategoryZmqRouterConnector) << "Unable to open socket";
        return false;
    }

    int linger = 0;
    if (socketSetOptInt(zmq::sockopt::linger, linger) &&
        socketBind(ip_address)) {
        setConnectionState(true);
        qCInfo(logCategoryZmqRouterConnector).nospace().noquote()
                << "Connected to the server socket '" << QString::fromStdString(ip_address)
                << "' (ID: 0x" << QByteArray::fromStdString(getDealerID()).toHex() << ")";
        return true;
    }

    qCCritical(logCategoryZmqRouterConnector).nospace()
            << "Unable to configure and/or connect to server socket '"
            << QString::fromStdString(ip_address) << "'";
    close();
    return false;
}

bool ZmqRouterConnector::read(std::string& message)
{
    if (false == socketValid()) {
        qCCritical(logCategoryZmqRouterConnector) << "Unable to read messages, socket not open";
        return false;
    }

    if (true == hasReadEvent()) {
        std::string identity;
        if (socketRecv(identity) && socketRecv(message)) {
            setDealerID(identity);
            qCDebug(logCategoryZmqRouterConnector).nospace().noquote()
                    << "Rx'ed message: '" << QString::fromStdString(message)
                    << "' (ID: 0x" << QByteArray::fromStdString(getDealerID()).toHex() << ")";
            return true;
        } else {
            qCWarning(logCategoryZmqRouterConnector) << "Failed to read messages";
        }
    }

    return false;
}

bool ZmqRouterConnector::blockingRead(std::string& message)
{
    if (false == socketValid()) {
        qCCritical(logCategoryZmqRouterConnector) << "Unable to blocking read messages, socket not open";
        return false;
    }

    std::string identity;
    if (socketRecv(identity) && socketRecv(message)) {
        setDealerID(identity);
        qCDebug(logCategoryZmqRouterConnector).nospace().noquote()
                << "Rx'ed blocking message: '" << QString::fromStdString(message)
                << "' (ID: 0x" << QByteArray::fromStdString(getDealerID()).toHex() << ")";
        return true;
    } else {
        if(false == socketValid()) {
            qCDebug(logCategoryZmqRouterConnector) << "Context was terminated, blocking read was interrupted";
        } else {
            qCWarning(logCategoryZmqRouterConnector) << "Failed to blocking read messages";
        }
    }

    return false;
}

bool ZmqRouterConnector::send(const std::string& message)
{
    if (false == socketValid()) {
        qCCritical(logCategoryZmqRouterConnector) << "Unable to send messages, socket not open";
        return false;
    }

    if ((false == socketSendMore(getDealerID())) || (false == socketSend(message))) {
        qCWarning(logCategoryZmqRouterConnector).nospace().noquote()
                << "Failed to send message: '" << QString::fromStdString(message)
                << "' (ID: 0x" << QByteArray::fromStdString(getDealerID()).toHex() << ")";
        return false;
    }

    qCDebug(logCategoryZmqRouterConnector).nospace().noquote()
            << "Tx'ed message: '" << QString::fromStdString(message)
            << "' (ID: 0x" << QByteArray::fromStdString(getDealerID()).toHex() << ")";

    return true;
}

} // namespace strata::connector
