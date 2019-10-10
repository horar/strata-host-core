#ifndef ZmqResponseConnector_H
#define ZmqResponseConnector_H

#include "ZmqConnector.h"

class ZmqResponseConnector : public ZmqConnector
{
public:
    ZmqResponseConnector();
    virtual ~ZmqResponseConnector();

    bool open(const std::string& ip_address) override;
};

#endif  // ZmqResponseConnector_H
