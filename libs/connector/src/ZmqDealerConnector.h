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
class ZmqDealerConnector : public ZmqConnector
{
public:
    ZmqDealerConnector();
    virtual ~ZmqDealerConnector();

    bool open(const std::string& ip_address) override;
};

}  // namespace strata::connector
