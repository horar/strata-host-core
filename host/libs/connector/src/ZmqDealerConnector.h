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
