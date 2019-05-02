#ifndef ZmqPublisherConnector_H
#define ZmqPublisherConnector_H

#include <set>
#include "ZmqConnector.h"

class ZmqPublisherConnector : public ZmqConnector
{
public:
    ZmqPublisherConnector();
    virtual ~ZmqPublisherConnector();

    bool open(const std::string& ip_address) override;
    /**
     * @brief read - not allowed -> assert()
     * @return
     */
    bool read(std::string&) override;
    bool send(const std::string& message) override;
    /**
     * dealerID is ID of ZmqSubscriberConnector
     * if no dealerID is addded then no messages are send to ZmqSubscriberConnector
     */
    void addSubscriber(const std::string& dealerID) override;

private:
    std::set<std::string> mSubscribers_;
};

#endif  // ZmqPublisherConnector_H
