#ifndef ZmqRequestConnector_H
#define ZmqRequestConnector_H

#include "ZmqConnector.h"

class ZmqRequestConnector : public ZmqConnector
{
public:
    ZmqRequestConnector();
    virtual ~ZmqRequestConnector();

    bool open(const std::string& ip_address) override;
};

#endif  // ZmqRequestConnector_H
