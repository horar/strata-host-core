#include "ZmqConnector.h"

#include <iomanip>
#include <sstream>

namespace strata::connector
{

ZmqConnector::ZmqConnector(int type)
    : Connector(), socketType(type)
{
    int major{0};
    int minor{0};
    int patch{0};
    zmq_version(&major, &minor, &patch);
    CONNECTOR_DEBUG_LOG("0MQ API version: %d.%d.%d\n", major, minor, patch);
}

ZmqConnector::~ZmqConnector()
{
    ZmqConnector::close();
}

bool ZmqConnector::open(const std::string&)
{
    assert(false && "This is base class. open() is not allowed here");
    return false;
}

bool ZmqConnector::close()
{
    if (false == socketConnected()) {
        return false;
    }

    socketClose();
    setConnectionState(false);
    return true;
}

bool ZmqConnector::closeContext()
{
    if (false == contextValid()) {
        return false;
    }

    contextClose();
    return true;
}

connector_handle_t ZmqConnector::getFileDescriptor()
{
#if defined(_WIN32)
        connector_handle_t defaultHandle = 0;
#else
        connector_handle_t defaultHandle = -1;
#endif

    if (false == socketConnected()) {
        return defaultHandle;
    }

    connector_handle_t server_socket_file_descriptor = socketGetOpt(zmq::sockopt::fd, defaultHandle);
    return server_socket_file_descriptor;
}

bool ZmqConnector::read(std::string& message, ReadMode read_mode)
{
    switch (read_mode)
    {
        case ReadMode::BLOCKING:
            if (blockingRead(message)) {
                return true;
            }
            break;
        case ReadMode::NONBLOCKING:
            if (read(message)) {
                return true;
            }
            break;
        default:
            CONNECTOR_DEBUG_LOG("%s", "[Socket] read failed\n");
            break;           
    }
    return false;
}

bool ZmqConnector::blockingRead(std::string& message)
{
    if (false == socketConnected()) {
        return false;
    }

    if (socketRecv(message)) {
        CONNECTOR_DEBUG_LOG("ZMQ [Socket] Rx'ed message : %s\n", message.c_str());
        return true;
    }

    return false;
}

bool ZmqConnector::read(std::string& message)
{
    if (false == socketConnected()) {
        return false;
    }

    zmq::pollitem_t items = {*socket_, 0, ZMQ_POLLIN, 0};
    if (false == socketPoll(&items)) {
        return false;
    }

    if (items.revents & ZMQ_POLLIN) {
        if (socketRecv(message)) {
            CONNECTOR_DEBUG_LOG("ZMQ [Socket] Rx'ed message : %s\n", message.c_str());
            return true;
        }
    }
    return false;
}

bool ZmqConnector::send(const std::string& message)
{
    if (false == socketConnected()) {
        return false;
    }

    if (false == socketSend(message)) {
        return false;
    }

    CONNECTOR_DEBUG_LOG("ZMQ [Socket] Tx'ed message : %s\n", message.c_str());

    return true;
}

// Receive 0MQ string from socket and convert to std::string
bool ZmqConnector::socketRecv(std::string & ostring, zmq::recv_flags flags)
{
    zmq::message_t message;
    try {
        const auto ret = socket_->recv(message, flags);
        if (ret != 0) {
            ostring = std::string(static_cast<char*>(message.data()), message.size());
            return true;
        }
    } catch (zmq::error_t zErr) {
        CONNECTOR_ERROR_LOG("ZMQ ERROR: Unable to receive message (flags: %d), reason: %s\n",
                            flags, zErr.what());
    } catch (std::exception sErr) {
        CONNECTOR_ERROR_LOG("ZMQ ERROR: Unable to receive message (flags: %d), unexpected reason: %s\n",
                            flags, sErr.what());
    } catch (...) {
        CONNECTOR_ERROR_LOG("ZMQ ERROR: Unable to receive message (flags: %d), unhandled exception\n",
                            flags);
    }

    return false;
}

// Convert std::string to 0MQ string and send to socket
bool ZmqConnector::socketSend(const std::string & istring, zmq::send_flags flags)
{
    zmq::message_t message(istring.data(), istring.size());
    try {
        const auto ret = socket_->send (message, flags);
        return (ret != 0);
    } catch (zmq::error_t zErr) {
        CONNECTOR_ERROR_LOG("ZMQ ERROR: Unable to send message '%s' (flags: %d), reason: %s\n",
                            istring.c_str(), flags, zErr.what());
    } catch (std::exception sErr) {
        CONNECTOR_ERROR_LOG("ZMQ ERROR: Unable to send message '%s' (flags: %d), unexpected reason: %s\n",
                            istring.c_str(), flags, sErr.what());
    } catch (...) {
        CONNECTOR_ERROR_LOG("ZMQ ERROR: Unable to send message '%s' (flags: %d), unhandled exception\n",
                            istring.c_str(), flags);
    }
    return false;
}

// Sends std::string as 0MQ string and send to socket as multipart non-terminal
bool ZmqConnector::socketSendMore(const std::string & istring)
{
    zmq::message_t message(istring.data(), istring.size());
    try {
        const auto ret = socket_->send (message, zmq::send_flags::sndmore);
        return (ret != 0);
    } catch (zmq::error_t zErr) {
        CONNECTOR_ERROR_LOG("ZMQ ERROR: Unable to send multipart message '%s', reason: %s\n",
                            istring.c_str(), zErr.what());
    } catch (std::exception sErr) {
        CONNECTOR_ERROR_LOG("ZMQ ERROR: Unable to send multipart message '%s', unexpected reason: %s\n",
                            istring.c_str(), sErr.what());
    } catch (...) {
        CONNECTOR_ERROR_LOG("ZMQ ERROR: Unable to send multipart message '%s', unhandled exception\n",
                            istring.c_str());
    }
    return false;
}

// Set a legacy socket option to given value
bool ZmqConnector::socketSetOptLegacy(int opt, const void *val, size_t valLen)
{
    // Use this function only if there is not another way to avoid it due to the deprecated notice
    try {
        #pragma warning(suppress: warning-code) // suppress warning 4996
        socket_->setsockopt(opt, val, valLen);
        return true;
    } catch (zmq::error_t zErr) {
        CONNECTOR_ERROR_LOG("ZMQ ERROR: Unable to set legacy socket option (len: %lu), reason: %s\n",
                            valLen, zErr.what());
    } catch (std::exception sErr) {
        CONNECTOR_ERROR_LOG("ZMQ ERROR: Unable to set legacy socket option (len: %lu), unexpected reason: %s\n",
                            valLen, sErr.what());
    } catch (...) {
        CONNECTOR_ERROR_LOG("ZMQ ERROR: Unable to set legacy socket option (len: %lu), unhandled exception\n",
                            valLen);
    }
    return false;
}

bool ZmqConnector::socketConnect(const std::string & address)
{
    try {
        socket_->connect(address);
        return true;
    } catch (zmq::error_t zErr) {
        CONNECTOR_ERROR_LOG("ZMQ ERROR: Unable to connect socket to address '%s', reason: %s\n",
                            address.c_str(), zErr.what());
    } catch (std::exception sErr) {
        CONNECTOR_ERROR_LOG("ZMQ ERROR: Unable to connect socket to address '%s', unexpected reason: %s\n",
                            address.c_str(), sErr.what());
    } catch (...) {
        CONNECTOR_ERROR_LOG("ZMQ ERROR: Unable to connect socket to address '%s', unhandled exception\n",
                            address.c_str());
    }
    return false;
}

bool ZmqConnector::socketBind(const std::string & address)
{
    try {
        socket_->bind(address);
        return true;
    } catch (zmq::error_t zErr) {
        CONNECTOR_ERROR_LOG("ZMQ ERROR: Unable to bind socket to address '%s', reason: %s\n",
                            address.c_str(), zErr.what());
    } catch (std::exception sErr) {
        CONNECTOR_ERROR_LOG("ZMQ ERROR: Unable to bind socket to address '%s', unexpected reason: %s\n",
                            address.c_str(), sErr.what());
    } catch (...) {
        CONNECTOR_ERROR_LOG("ZMQ ERROR: Unable to bind socket to address '%s', unhandled exception\n",
                            address.c_str());
    }
    return false;
}

bool ZmqConnector::socketPoll(zmq::pollitem_t *items)
{
    try {
        if (-1 != zmq::poll(items, 1, SOCKET_POLLING_TIMEOUT)) {
            return true;
        }
    } catch (zmq::error_t zErr) {
        CONNECTOR_ERROR_LOG("ZMQ ERROR: Unable to pool items, reason: %s\n",
                            zErr.what());
    } catch (std::exception sErr) {
        CONNECTOR_ERROR_LOG("ZMQ ERROR: Unable to pool items, unexpected reason: %s\n",
                            sErr.what());
    } catch (...) {
        CONNECTOR_ERROR_LOG("%s ERROR: Unable to pool items, unhandled exception\n", "ZMQ");
    }

    return false;
}

bool ZmqConnector::socketOpen()
{
    if (socketConnected() || contextValid()) {
        return false;
    }

    try {
        context_.reset(new zmq::context_t());
        socket_.reset(new zmq::socket_t(*context_, socketType));
        return true;
    } catch (zmq::error_t zErr) {
        CONNECTOR_ERROR_LOG("ZMQ ERROR: Unable to open socket, reason: %s\n",
                            zErr.what());
    } catch (std::exception sErr) {
        CONNECTOR_ERROR_LOG("ZMQ ERROR: Unable to open socket, unexpected reason: %s\n",
                            sErr.what());
    } catch (...) {
        CONNECTOR_ERROR_LOG("%s ERROR: Unable to open socket, unhandled exception\n", "ZMQ");
    }

    // release these objects in case it failed to allocate them
    context_.release();
    socket_.release();
    return false;
}

void ZmqConnector::socketClose()
{
    // will assert if it fails, no need to return anything
    socket_->close();
}

bool ZmqConnector::socketConnected() const
{
    return ((nullptr != socket_) && socket_->connected() && isConnected());
}

void ZmqConnector::contextClose()
{
    context_->close();
}

bool ZmqConnector::contextValid() const
{
    return ((nullptr != context_) && (nullptr != context_->handle()));
}

}  // namespace strata::connector
