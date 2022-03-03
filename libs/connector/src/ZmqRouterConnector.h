/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include "ZmqConnector.h"

namespace strata::connector
{
class ZmqRouterConnector : public ZmqConnector
{
public:
    ZmqRouterConnector();
    virtual ~ZmqRouterConnector();

    bool open(const std::string& ip_address) override;
    bool send(const std::string& message) override;
    bool read(std::string& notification) override;
    bool blockingRead(std::string& notification) override;
};

}  // namespace strata::connector
