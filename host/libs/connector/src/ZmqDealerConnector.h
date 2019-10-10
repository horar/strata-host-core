#ifndef ZmqDealerConnector_H
#define ZmqDealerConnector_H

#include "ZmqConnector.h"

class ZmqDealerConnector : public ZmqConnector
{
public:
    ZmqDealerConnector();
    virtual ~ZmqDealerConnector();

    bool open(const std::string& ip_address) override;
};

#endif  // ZmqDealerConnector_H
