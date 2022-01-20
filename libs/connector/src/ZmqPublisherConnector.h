/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <set>
#include "ZmqConnector.h"

namespace strata::connector
{
class ZmqPublisherConnector : public ZmqConnector
{
public:
    ZmqPublisherConnector();
    virtual ~ZmqPublisherConnector();

    bool open(const std::string& ip_address) override;
    /**
     * @brief read - not allowed -> assert()
     * @return
     */
    bool read(std::string&) override;
    bool send(const std::string& message) override;
    /**
     * dealerID is ID of ZmqSubscriberConnector
     * if no dealerID is addded then no messages are send to ZmqSubscriberConnector
     */
    void addSubscriber(const std::string& dealerID) override;

private:
    std::set<std::string> mSubscribers_;
};

}  // namespace strata::connector
