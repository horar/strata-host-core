/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <memory>
#include <zmq.hpp> // https://github.com/zeromq/cppzmq
#include "Connector.h"
#include "logging/LoggingQtCategories.h"

namespace strata::connector {

#define ZMQ_DEFINE_CUSTOM_ARRAY_OPT(OPT, NAME)          \
    using NAME##_t = zmq::sockopt::array_option<OPT>;   \
    ZMQ_INLINE_VAR ZMQ_CONSTEXPR_VAR NAME##_t NAME {}

// cppzmq is missing the ZMQ IDENTITY
ZMQ_DEFINE_CUSTOM_ARRAY_OPT(ZMQ_IDENTITY, zmq_identity);

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
    bool shutdown() override;

    // non-blocking send
    bool send(const std::string& message) override;

    // choose blocking or non-blocking read mode
    bool read(std::string& notification, ReadMode read_mode) override;

    // non-blocking read
    bool read(std::string& notification) override;

    // blocking read
    bool blockingRead(std::string& notification) override;

    connector_handle_t getFileDescriptor() override;
    bool socketValid() const;
    bool contextValid() const;

    bool hasReadEvent() override;
    bool hasWriteEvent() override;

private:
    std::unique_ptr<zmq::context_t> context_; // there is 1-N relationship between context-socket
    const int socketType;

protected:
    bool socketRecv(std::string & ostring, zmq::recv_flags flags = zmq::recv_flags::none);
    bool socketSend(const std::string & istring, zmq::send_flags flags = zmq::send_flags::none);
    bool socketSendMore(const std::string & istring);
    template<int Opt, int NullTerm>
    bool socketSetOptString(zmq::sockopt::array_option<Opt, NullTerm> opt, const std::string & val);
    template<int Opt, class T, bool BoolUnit>
    bool socketSetOptInt(zmq::sockopt::integral_option<Opt, T, BoolUnit> opt, int val);
    template<int Opt, class T, bool BoolUnit>
    bool socketGetOptInt(zmq::sockopt::integral_option<Opt, T, BoolUnit> opt, T & val);
    bool socketConnect(const std::string & address);
    bool socketBind(const std::string & address);
    bool socketPoll(zmq::pollitem_t *items);
    bool socketAndContextOpen();
    void socketClose();
    void contextClose();
    void contextShutdown();

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
        qCCritical(lcZmqConnector).nospace().noquote()
                << "Unable to set string socket option to value '" << QString::fromStdString(val)
                << "', reason: " << zErr.what();
    } catch (const std::exception& sErr) {
        qCCritical(lcZmqConnector).nospace().noquote()
                << "Unable to set string socket option to value '" << QString::fromStdString(val)
                << "', unexpected reason: " << sErr.what();
    } catch (...) {
        qCCritical(lcZmqConnector).nospace().noquote()
                << "Unable to set string socket option to value '" << QString::fromStdString(val)
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
        qCCritical(lcZmqConnector).nospace()
                << "Unable to set int socket option to value '" << val
                << "', reason: " << zErr.what();
    } catch (const std::exception& sErr) {
        qCCritical(lcZmqConnector).nospace()
                << "Unable to set int socket option to value '" << val
                << "', unexpected reason: " << sErr.what();
    } catch (...) {
        qCCritical(lcZmqConnector).nospace()
                << "Unable to set int socket option to value '" << val
                << "', unhandled exception";
    }

    return false;
}

// Get an integer-based socket option
template<int Opt, class T, bool BoolUnit>
bool ZmqConnector::socketGetOptInt(zmq::sockopt::integral_option<Opt, T, BoolUnit> opt, T & val)
{
    try {
        val = socket_->get(opt);
        return true;
    } catch (const zmq::error_t& zErr) {
        qCCritical(lcZmqConnector)
                << "Unable to get int socket option, reason:" << zErr.what();
    } catch (const std::exception& sErr) {
        qCCritical(lcZmqConnector)
                << "Unable to get int socket option, unexpected reason:" << sErr.what();
    } catch (...) {
        qCCritical(lcZmqConnector)
                << "Unable to get int socket option, unhandled exception";
    }

    return false;
}

}  // namespace strata::connector
