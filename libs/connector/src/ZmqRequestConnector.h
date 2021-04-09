#pragma once

#include "ZmqConnector.h"

namespace strata::connector
{
class ZmqRequestConnector : public ZmqConnector
{
public:
    ZmqRequestConnector();
    virtual ~ZmqRequestConnector();

    bool open(const std::string& ip_address) override;
};

}  // namespace strata::connector
