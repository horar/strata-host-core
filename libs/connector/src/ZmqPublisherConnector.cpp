/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "ZmqPublisherConnector.h"

namespace strata::connector
{

ZmqPublisherConnector::ZmqPublisherConnector() : ZmqConnector(ZMQ_PUB), mSubscribers_()
{
    qCInfo(lcZmqPublisherConnector) << "ZMQ_PUB Creating connector object";
}

ZmqPublisherConnector::~ZmqPublisherConnector()
{
}

bool ZmqPublisherConnector::open(const std::string& ip_address)
{
    if (false == socketAndContextOpen()) {
        qCCritical(lcZmqPublisherConnector) << "Unable to open socket";
        return false;
    }

    int linger = 0;
    if (socketSetOptInt(zmq::sockopt::linger, linger) &&
        socketBind(ip_address)) {
        setConnectionState(true);
        qCInfo(lcZmqPublisherConnector).nospace().noquote()
                << "Connected to the server socket '" << QString::fromStdString(ip_address)
                << "' (ID: 0x" << QByteArray::fromStdString(getDealerID()).toHex() << ")";
        return true;
    }

    qCCritical(lcZmqPublisherConnector).nospace().noquote()
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
        qCCritical(lcZmqPublisherConnector) << "Unable to send messages, socket not open";
        return false;
    }

    for (const std::string& dealerID : mSubscribers_) {
        if ((false == socketSendMore(dealerID)) || (false == socketSend(message))) {
            qCWarning(lcZmqPublisherConnector).nospace().noquote()
                    << "Failed to send message: '" << QString::fromStdString(message)
                    << "' (ID: 0x" << QByteArray::fromStdString(getDealerID()).toHex() << ")";
            return false;
        }
        qCDebug(lcZmqPublisherConnector).nospace().noquote()
                << "Tx'ed message: '" << QString::fromStdString(message)
                << "' (ID: 0x" << QByteArray::fromStdString(getDealerID()).toHex() << ")";
    }

    return true;
}

void ZmqPublisherConnector::addSubscriber(const std::string& dealerID)
{
    mSubscribers_.insert(dealerID);
    qCDebug(lcZmqPublisherConnector).nospace().noquote()
            << "Added subscriber: 0x" << QByteArray::fromStdString(getDealerID()).toHex();
}

} // namespace strata::connector
