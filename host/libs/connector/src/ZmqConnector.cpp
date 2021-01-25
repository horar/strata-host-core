#include "ZmqConnector.h"

#include <iomanip>
#include <sstream>
#include <zhelpers.hpp>

namespace strata::connector
{

ZmqConnector::ZmqConnector(int type)
    : Connector(), context_(new zmq::context_t()), socket_(new zmq::socket_t(*context_, type))
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
    if (false == socket_->connected()) {
        return false;
    }

    socket_->close();
    setConnectionState(false);
    return true;
}

bool ZmqConnector::closeContext()
{
    if (nullptr != context_->handle()) {
        return false;
    }

    context_->close();
    return true;
}

connector_handle_t ZmqConnector::getFileDescriptor()
{
    if (false == socket_->connected()) {
#if defined(_WIN32)
        return 0;
#else
        return -1;
#endif
    }

    connector_handle_t server_socket_file_descriptor;
    size_t server_socket_file_descriptor_size = sizeof(server_socket_file_descriptor);
    socket_->getsockopt(ZMQ_FD, &server_socket_file_descriptor,
                        &server_socket_file_descriptor_size);
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
    if (false == socket_->valid()) {
        return false;
    }

    if (s_recv(*socket_, message)) {
        CONNECTOR_DEBUG_LOG("[Socket] Rx'ed message : %s\n", message.c_str());
        return true;
    }
    return false;
}

bool ZmqConnector::read(std::string& message)
{
    if (false == socket_->valid()) {
        return false;
    }

    zmq::pollitem_t items = {*socket_, 0, ZMQ_POLLIN, 0};
    if (-1 == zmq::poll(&items, 1, SOCKET_POLLING_TIMEOUT)) {
        return false;
    }
    if (items.revents & ZMQ_POLLIN) {
        if (s_recv(*socket_, message)) {
            CONNECTOR_DEBUG_LOG("[Socket] Rx'ed message : %s\n", message.c_str());

            return true;
        }
    }
    return false;
}

bool ZmqConnector::send(const std::string& message)
{
    if (false == socket_->valid()) {
        return false;
    }

    if (false == s_send(*socket_, message)) {
        return false;
    }

    CONNECTOR_DEBUG_LOG("[Socket] Tx'ed message : %s\n", message.c_str());

    return true;
}

}  // namespace strata::connector
