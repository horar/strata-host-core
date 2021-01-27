#pragma once

#include <memory>
#include <zmq.hpp> // https://github.com/zeromq/cppzmq
#include "Connector.h"

namespace strata::connector {

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
    bool closeContext() override;

    // non-blocking calls
    bool send(const std::string& message) override;
    bool read(std::string& notification) override;

    //blocking read
    bool read(std::string& notification, ReadMode read_mode) override;
    bool blockingRead(std::string& notification) override;

    connector_handle_t getFileDescriptor() override;

private:
    void contextClose();
    bool contextValid() const;

    std::unique_ptr<zmq::context_t> context_;
    const int socketType;

protected:
    bool socketRecv(std::string & ostring, zmq::recv_flags flags = zmq::recv_flags::none);
    bool socketSend(const std::string & istring, zmq::send_flags flags = zmq::send_flags::none);
    bool socketSendMore(const std::string & istring);
    bool socketSetOptLegacy(int opt, const void *val, size_t valLen);
    template<int Opt, int NullTerm>
    bool socketSetOptString(zmq::sockopt::array_option<Opt, NullTerm> opt, const std::string & val);
    template<int Opt, class T, bool BoolUnit>
    bool socketSetOptInt(zmq::sockopt::integral_option<Opt, T, BoolUnit> opt, int val);
    template<int Opt, class T, bool BoolUnit>
    T socketGetOpt(zmq::sockopt::integral_option<Opt, T, BoolUnit> opt, T defaultVal);
    bool socketConnect(const std::string & address);
    bool socketBind(const std::string & address);
    bool socketPoll(zmq::pollitem_t *items);
    bool socketOpen();
    void socketClose();
    bool socketConnected() const;

    // timeout for request socket in milli seconds
    const int32_t REQUEST_SOCKET_TIMEOUT{5000};
    // timeout for polling a socket in milliseconds
    const int32_t SOCKET_POLLING_TIMEOUT{10};

    std::unique_ptr<zmq::socket_t> socket_;
};

// Set a string-based socket option to given value
template<int Opt, int NullTerm>
bool ZmqConnector::socketSetOptString(zmq::sockopt::array_option<Opt, NullTerm> opt, const std::string & val)
{
    try {
        socket_->set(opt, val);
        return true;
    } catch (zmq::error_t zErr) {
        CONNECTOR_ERROR_LOG("ZMQ ERROR: Unable to set string socket option to value '%s', reason: %s\n",
                            val.c_str(), zErr.what());
    } catch (std::exception sErr) {
        CONNECTOR_ERROR_LOG("ZMQ ERROR: Unable to set string socket option to value '%s', unexpected reason: %s\n",
                            val.c_str(), sErr.what());
    } catch (...) {
        CONNECTOR_ERROR_LOG("ZMQ ERROR: Unable to set string socket option to value '%s', unhandled exception\n",
                            val.c_str());
    }
    return false;
}

// Set an integer-based socket option to given value
template<int Opt, class T, bool BoolUnit>
bool ZmqConnector::socketSetOptInt(zmq::sockopt::integral_option<Opt, T, BoolUnit> opt, int val)
{
    try {
        socket_->set(opt, val);
        return true;
    } catch (zmq::error_t zErr) {
        CONNECTOR_ERROR_LOG("ZMQ ERROR: Unable to set int socket option to value '%d', reason: %s\n",
                            val, zErr.what());
    } catch (std::exception sErr) {
        CONNECTOR_ERROR_LOG("ZMQ ERROR: Unable to set int socket option to value '%d', unexpected reason: %s\n",
                            val, sErr.what());
    } catch (...) {
        CONNECTOR_ERROR_LOG("ZMQ ERROR: Unable to set int socket option to value '%d', unhandled exception\n",
                            val);
    }
    return false;
}

// Get an integer-based socket option
template<int Opt, class T, bool BoolUnit>
T ZmqConnector::socketGetOpt(zmq::sockopt::integral_option<Opt, T, BoolUnit> opt, T defaultVal)
{
    try {
        return socket_->get(opt);
    } catch (zmq::error_t zErr) {
        CONNECTOR_ERROR_LOG("ZMQ ERROR: Unable to get integer socket option, reason: %s\n",
                            zErr.what());
    } catch (std::exception sErr) {
        CONNECTOR_ERROR_LOG("ZMQ ERROR: Unable to get integer socket option, unexpected reason: %s\n",
                            sErr.what());
    } catch (...) {
        CONNECTOR_ERROR_LOG("%s ERROR: Unable to get integer socket option, unhandled exception\n", "ZMQ");
    }
    return defaultVal;
}

}  // namespace strata::connector
