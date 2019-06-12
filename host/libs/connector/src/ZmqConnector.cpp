#include "ZmqConnector.h"

#include <iomanip>
#include <sstream>
#include <zhelpers.hpp>

ZmqConnector::ZmqConnector(int type)
    : Connector(), context_(new zmq::context_t()), socket_(new zmq::socket_t(*context_, type))
{
}

ZmqConnector::~ZmqConnector()
{
    close();
}

bool ZmqConnector::open(const std::string&)
{
    assert(false && "This is base class. open() is not allowed here");
    return false;
}

bool ZmqConnector::close()
{
    if (false == socket_->valid()) {
        return false;
    }
    socket_->close();
    setConnectionState(false);
    return true;
}

int ZmqConnector::getFileDescriptor()
{
    if (false == socket_->valid()) {
        return false;
    }

#ifdef _WIN32
    unsigned long long int server_socket_file_descriptor;
#else
    int server_socket_file_descriptor = 0;
#endif
    size_t server_socket_file_descriptor_size = sizeof(server_socket_file_descriptor);
    socket_->getsockopt(ZMQ_FD, &server_socket_file_descriptor,
                        &server_socket_file_descriptor_size);
    return server_socket_file_descriptor;
}

bool ZmqConnector::read(std::string& message,ReadMode read_mode)
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
            CONNECTOR_DEBUG_LOG("[Socket] read failed\n",);
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
