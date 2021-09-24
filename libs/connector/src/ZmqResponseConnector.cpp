/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
                << "' (ID: 0x" << QByteArray::fromStdString(getDealerID()).toHex() << ")";
        return true;
    }

    qCCritical(logCategoryZmqResponseConnector).nospace().noquote()
            << "Unable to configure and/or connect to server socket '"
            << QString::fromStdString(ip_address) << "'";
    close();
    return false;
}

} // namespace strata::connector
