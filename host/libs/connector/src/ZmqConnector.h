#ifndef ZmqConnector_H
#define ZmqConnector_H

#include <memory>
#include "Connector.h"

namespace zmq
{
class context_t;
class socket_t;
}  // namespace zmq

class ZmqConnector : public Connector
{
public:
    ZmqConnector() = delete;
    ZmqConnector(const ZmqConnector& rhs) = delete;
    ZmqConnector& operator=(const ZmqConnector& rhs) = delete;

    explicit ZmqConnector(int type);
    virtual ~ZmqConnector();

    bool open(const std::string& ip_address) override;
    bool close() override;

    // non-blocking calls
    bool send(const std::string& message) override;
    bool read(std::string& notification) override;

    int getFileDescriptor() override;

private:
    std::unique_ptr<zmq::context_t> context_;

protected:
    // timeout for request socket in milli seconds
    const int32_t REQUEST_SOCKET_TIMEOUT{5000};

    std::unique_ptr<zmq::socket_t> socket_;
};

#endif  // ZmqConnector_H
