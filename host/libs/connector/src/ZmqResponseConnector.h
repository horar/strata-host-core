#pragma once

#include "ZmqConnector.h"

namespace strata::connector
{
class ZmqResponseConnector : public ZmqConnector
{
public:
    ZmqResponseConnector();
    virtual ~ZmqResponseConnector();

    bool open(const std::string& ip_address) override;
};

}  // namespace strata::connector
