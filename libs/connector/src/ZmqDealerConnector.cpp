/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "ZmqDealerConnector.h"

namespace strata::connector
{

ZmqDealerConnector::ZmqDealerConnector() : ZmqConnector(ZMQ_DEALER)
{
    qCInfo(lcZmqDealerConnector) << "ZMQ_DEALER Creating connector object";
}

ZmqDealerConnector::~ZmqDealerConnector()
{
}

bool ZmqDealerConnector::open(const std::string& ip_address)
{
    if (false == socketAndContextOpen()) {
        qCCritical(lcZmqDealerConnector) << "Unable to open socket";
        return false;
    }

    int linger = 0;
    const std::string& id = getDealerID();
    if ((id.empty() || socketSetOptString(zmq_identity, id)) &&
        socketSetOptInt(zmq::sockopt::linger, linger) &&
        socketConnect(ip_address)) {
        setConnectionState(true);
        qCInfo(lcZmqDealerConnector).nospace().noquote()
                << "Connected to the server socket '" << QString::fromStdString(ip_address)
                << "' (ID: 0x" << QByteArray::fromStdString(getDealerID()).toHex() << ")";
        return true;
    }

    qCCritical(lcZmqDealerConnector).nospace().noquote()
            << "Unable to configure and/or connect to server socket '"
            << QString::fromStdString(ip_address) << "'";
    close();
    return false;
}

} // namespace strata::connector
