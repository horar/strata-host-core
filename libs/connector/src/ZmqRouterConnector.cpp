/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "ZmqRouterConnector.h"

namespace strata::connector
{
ZmqRouterConnector::ZmqRouterConnector() : ZmqConnector(ZMQ_ROUTER)
{
    qCInfo(lcZmqRouterConnector) << "ZMQ_ROUTER Creating connector object";
}

ZmqRouterConnector::~ZmqRouterConnector()
{
}

bool ZmqRouterConnector::open(const std::string& ip_address)
{
    if (false == socketAndContextOpen()) {
        qCCritical(lcZmqRouterConnector) << "Unable to open socket";
        return false;
    }

    int linger = 0;
    if (socketSetOptInt(zmq::sockopt::linger, linger) &&
        socketBind(ip_address)) {
        setConnectionState(true);
        qCInfo(lcZmqRouterConnector).nospace().noquote()
                << "Connected to the server socket '" << QString::fromStdString(ip_address)
                << "' (ID: 0x" << QByteArray::fromStdString(getDealerID()).toHex() << ")";
        return true;
    }

    qCCritical(lcZmqRouterConnector).nospace()
            << "Unable to configure and/or connect to server socket '"
            << QString::fromStdString(ip_address) << "'";
    close();
    return false;
}

bool ZmqRouterConnector::read(std::string& message)
{
    if (false == socketValid()) {
        qCCritical(lcZmqRouterConnector) << "Unable to read messages, socket not open";
        return false;
    }

    if (true == hasReadEvent()) {
        std::string identity;
        if (socketRecv(identity) && socketRecv(message)) {
            setDealerID(identity);
            qCDebug(lcZmqRouterConnector).nospace().noquote()
                    << "Rx'ed message: '" << QString::fromStdString(message)
                    << "' (ID: 0x" << QByteArray::fromStdString(getDealerID()).toHex() << ")";
            return true;
        } else {
            qCWarning(lcZmqRouterConnector) << "Failed to read messages";
        }
    }

    return false;
}

bool ZmqRouterConnector::blockingRead(std::string& message)
{
    if (false == socketValid()) {
        qCCritical(lcZmqRouterConnector) << "Unable to blocking read messages, socket not open";
        return false;
    }

    std::string identity;
    if (socketRecv(identity) && socketRecv(message)) {
        setDealerID(identity);
        qCDebug(lcZmqRouterConnector).nospace().noquote()
                << "Rx'ed blocking message: '" << QString::fromStdString(message)
                << "' (ID: 0x" << QByteArray::fromStdString(getDealerID()).toHex() << ")";
        return true;
    } else {
        if(false == socketValid()) {
            qCDebug(lcZmqRouterConnector) << "Context was terminated, blocking read was interrupted";
        } else {
            qCWarning(lcZmqRouterConnector) << "Failed to blocking read messages";
        }
    }

    return false;
}

bool ZmqRouterConnector::send(const std::string& message)
{
    if (false == socketValid()) {
        qCCritical(lcZmqRouterConnector) << "Unable to send messages, socket not open";
        return false;
    }

    if ((false == socketSendMore(getDealerID())) || (false == socketSend(message))) {
        qCWarning(lcZmqRouterConnector).nospace().noquote()
                << "Failed to send message: '" << QString::fromStdString(message)
                << "' (ID: 0x" << QByteArray::fromStdString(getDealerID()).toHex() << ")";
        return false;
    }

    qCDebug(lcZmqRouterConnector).nospace().noquote()
            << "Tx'ed message: '" << QString::fromStdString(message)
            << "' (ID: 0x" << QByteArray::fromStdString(getDealerID()).toHex() << ")";

    return true;
}

} // namespace strata::connector
