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
