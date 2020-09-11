#pragma once

#include "ZmqConnector.h"

namespace strata::connector
{
class ZmqSubscriberConnector : public ZmqConnector
{
public:
    ZmqSubscriberConnector();
    virtual ~ZmqSubscriberConnector();

    bool open(const std::string& ip_address) override;
    /**
     * @brief send - not allowed -> assert()
     * @return
     */
    bool send(const std::string&) override;
    bool read(std::string& message) override;
    bool blockingRead(std::string& message) override;
};

}  // namespace strata::connector
