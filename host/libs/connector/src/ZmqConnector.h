#pragma once

#include <memory>
#include <zmq.hpp> // https://github.com/zeromq/cppzmq
#include "Connector.h"
#include "logging/LoggingQtCategories.h"

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
    } catch (const zmq::error_t& zErr) {
        qCCritical(logCategoryZmqConnector).nospace()
                << "Unable to set string socket option to value '" << val.c_str()
                << "', reason: " << zErr.what();
    } catch (const std::exception& sErr) {
        qCCritical(logCategoryZmqConnector).nospace()
                << "Unable to set string socket option to value '" << val.c_str()
                << "', unexpected reason: " << sErr.what();
    } catch (...) {
        qCCritical(logCategoryZmqConnector).nospace()
                << "Unable to set string socket option to value '" << val.c_str()
                << "', unhandled exception";
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
    } catch (const zmq::error_t& zErr) {
        qCCritical(logCategoryZmqConnector).nospace()
                << "Unable to set int socket option to value '" << val
                << "', reason: " << zErr.what();
    } catch (const std::exception& sErr) {
        qCCritical(logCategoryZmqConnector).nospace()
                << "Unable to set int socket option to value '" << val
                << "', unexpected reason: " << sErr.what();
    } catch (...) {
        qCCritical(logCategoryZmqConnector).nospace()
                << "Unable to set int socket option to value '" << val
                << "', unhandled exception";
    }

    return false;
}

// Get an integer-based socket option
template<int Opt, class T, bool BoolUnit>
T ZmqConnector::socketGetOpt(zmq::sockopt::integral_option<Opt, T, BoolUnit> opt, T defaultVal)
{
    try {
        return socket_->get(opt);
    } catch (const zmq::error_t& zErr) {
        qCCritical(logCategoryZmqConnector).nospace()
                << "Unable to get integer socket option, reason: " << zErr.what();
    } catch (const std::exception& sErr) {
        qCCritical(logCategoryZmqConnector).nospace()
                << "Unable to get integer socket option, unexpected reason: " << sErr.what();
    } catch (...) {
        qCCritical(logCategoryZmqConnector).nospace()
                << "Unable to get integer socket option, unhandled exception";
    }

    return defaultVal;
}

}  // namespace strata::connector
