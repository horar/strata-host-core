#ifndef ZmqRouterConnector_H
#define ZmqRouterConnector_H

#include "ZmqConnector.h"

class ZmqRouterConnector : public ZmqConnector
{
public:
    ZmqRouterConnector();
    virtual ~ZmqRouterConnector();

    bool open(const std::string& ip_address) override;

    bool send(const std::string& message) override;

    bool read(std::string& notification) override;
};

#endif  // ZmqRouterConnector_H
