#ifndef ZmqSubscriberConnector_H
#define ZmqSubscriberConnector_H

#include "ZmqConnector.h"

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
};

#endif  // ZmqPublisherConnector_H
