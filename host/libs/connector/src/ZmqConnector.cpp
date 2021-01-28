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
    qCInfo(logCategoryZmqConnector).nospace() << "0MQ API version: " << major << "." << minor << "." << patch;
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
    if (false == contextValid()) {
        return false;
    }

    // this boolean MUST be set first, the close operations first emit the interrupt
    // and THEN they invalidate themselves, which has issues in multithreaded operations
    // because they still can be considered valid - for which we need this boolean
    setConnectionState(false);

    socketClose();
    contextClose();

    // Note: this function can (and will) be called from other threads
    // it will interrupt any ongoing sending or receiving of messages
    // or any other related activity which will throw ETERM error

    return true;
}

bool ZmqConnector::send(const std::string& message)
{
    if (false == socketValid()) {
        qCCritical(logCategoryZmqConnector) << "Unable to send messages, socket not open";
        return false;
    }

    if (false == socketSend(message)) {
        qCWarning(logCategoryZmqConnector) << "Failed to send message:" << message.c_str();
        return false;
    }

    qCDebug(logCategoryZmqConnector) << "Tx'ed message:" << message.c_str();
    return true;
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
            qCCritical(logCategoryZmqConnector) << "Invalid read mode, read failed";
            break;
    }
    return false;
}

bool ZmqConnector::read(std::string& message)
{
    if (false == socketValid()) {
        qCCritical(logCategoryZmqConnector) << "Unable to read messages, socket not open";
        return false;
    }

    zmq::pollitem_t items = {*socket_, 0, ZMQ_POLLIN, 0};
    if (false == socketPoll(&items)) {
        qCWarning(logCategoryZmqConnector) << "Failed to poll items";
        return false;
    }

    if (items.revents & ZMQ_POLLIN) {
        if (socketRecv(message)) {
            qCDebug(logCategoryZmqConnector) << "Rx'ed message:" << message.c_str();
            return true;
        } else {
            qCWarning(logCategoryZmqConnector) << "Failed to read messages";
        }
    }

    return false;
}

bool ZmqConnector::blockingRead(std::string& message)
{
    if (false == socketValid()) {
        qCCritical(logCategoryZmqConnector) << "Unable to blocking read messages, socket not open";
        return false;
    }

    if (socketRecv(message)) {
        qCDebug(logCategoryZmqConnector) << "Rx'ed blocking message:" << message.c_str();
        return true;
    }

    if(false == socketValid()) {
        qCDebug(logCategoryZmqConnector) << "Context was terminated, blocking read was interupted";
    } else {
        qCWarning(logCategoryZmqConnector) << "Failed to blocking read messages";
    }

    return false;
}


connector_handle_t ZmqConnector::getFileDescriptor()
{
#if defined(_WIN32)
        connector_handle_t defaultHandle = 0;
#else
        connector_handle_t defaultHandle = -1;
#endif

    if (false == socketValid()) {
        qCCritical(logCategoryZmqConnector) << "Unable to acquire File Descriptor handle, socket not open";
        return defaultHandle;
    }

    connector_handle_t server_socket_file_descriptor = socketGetOpt(zmq::sockopt::fd, defaultHandle);
    return server_socket_file_descriptor;
}

bool ZmqConnector::socketValid() const
{
    return (isConnected() && (nullptr != socket_) && socket_->connected());
}

bool ZmqConnector::contextValid() const
{
    return ((nullptr != context_) && (nullptr != context_->handle()));
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
    } catch (const zmq::error_t& zErr) {
        if (zErr.num() == ETERM) {
            qCInfo(logCategoryZmqConnector).nospace()
                    << "Receive of messages was interrupted (flags: " << (int)flags << "), reason: " << zErr.what();
        } else {
            qCCritical(logCategoryZmqConnector).nospace()
                    << "Unable to receive message (flags: " << (int)flags << "), reason: " << zErr.what();
        }
    } catch (const std::exception& sErr) {
        qCCritical(logCategoryZmqConnector).nospace()
                << "Unable to receive message (flags: " << (int)flags << "), unexpected reason: " << sErr.what();
    } catch (...) {
        qCCritical(logCategoryZmqConnector).nospace()
                << "Unable to receive message (flags: " << (int)flags << "), unhandled exception";
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
    } catch (const zmq::error_t& zErr) {
        if (zErr.num() == ETERM) {
            qCInfo(logCategoryZmqConnector).nospace()
                    << "Sending of message was interrupted '" << istring.c_str()
                    << "' (flags: " << (int)flags << "), reason: " << zErr.what();
        } else {
            qCCritical(logCategoryZmqConnector).nospace()
                    << "Unable to send message '" << istring.c_str()
                    << "' (flags: " << (int)flags << "), reason: " << zErr.what();
        }
    } catch (const std::exception& sErr) {
        qCCritical(logCategoryZmqConnector).nospace()
                << "Unable to send message '" << istring.c_str()
                << "' (flags: " << (int)flags << "), unexpected reason: " << sErr.what();
    } catch (...) {
        qCCritical(logCategoryZmqConnector).nospace()
                << "Unable to send message '" << istring.c_str()
                << "' (flags: " << (int)flags << "), unhandled exception";
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
    } catch (const zmq::error_t& zErr) {
        if (zErr.num() == ETERM) {
            qCInfo(logCategoryZmqConnector).nospace()
                    << "Sending of multipart message was interrupted '" << istring.c_str() << "', reason: " << zErr.what();
        } else {
            qCCritical(logCategoryZmqConnector).nospace()
                    << "Unable to send multipart message '" << istring.c_str() << "', reason: " << zErr.what();
        }

    } catch (const std::exception& sErr) {
        qCCritical(logCategoryZmqConnector).nospace()
                << "Unable to send multipart message '" << istring.c_str() << "', unexpected reason: " << sErr.what();
    } catch (...) {
        qCCritical(logCategoryZmqConnector).nospace()
                << "Unable to send multipart message '" << istring.c_str() << "', unhandled exception";
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
    } catch (const zmq::error_t& zErr) {
        qCCritical(logCategoryZmqConnector).nospace()
                << "Unable to set legacy socket option (len: " << valLen << "), reason: " << zErr.what();
    } catch (const std::exception& sErr) {
        qCCritical(logCategoryZmqConnector).nospace()
                << "Unable to set legacy socket option (len: " << valLen << "), unexpected reason: " << sErr.what();
    } catch (...) {
        qCCritical(logCategoryZmqConnector).nospace()
                << "Unable to set legacy socket option (len: " << valLen << "), unhandled exception";
    }

    return false;
}

bool ZmqConnector::socketConnect(const std::string & address)
{
    try {
        socket_->connect(address);
        return true;
    } catch (const zmq::error_t& zErr) {
        qCCritical(logCategoryZmqConnector).nospace()
                << "Unable to connect socket to address '" << address.c_str()
                << "', reason: " << zErr.what();
    } catch (const std::exception& sErr) {
        qCCritical(logCategoryZmqConnector).nospace()
                << "Unable to connect socket to address '" << address.c_str()
                << "', unexpected reason: " << sErr.what();
    } catch (...) {
        qCCritical(logCategoryZmqConnector).nospace()
                << "Unable to connect socket to address '" << address.c_str()
                << "', unhandled exception";
    }

    return false;
}

bool ZmqConnector::socketBind(const std::string & address)
{
    try {
        socket_->bind(address);
        return true;
    } catch (const zmq::error_t& zErr) {
        qCCritical(logCategoryZmqConnector).nospace()
                << "Unable to bind socket to address '" << address.c_str()
                << "', reason: " << zErr.what();
    } catch (const std::exception& sErr) {
        qCCritical(logCategoryZmqConnector).nospace()
                << "Unable to bind socket to address '" << address.c_str()
                << "', unexpected reason: " << sErr.what();
    } catch (...) {
        qCCritical(logCategoryZmqConnector).nospace()
                << "Unable to bind socket to address '" << address.c_str()
                << "', unhandled exception";
    }

    return false;
}

bool ZmqConnector::socketPoll(zmq::pollitem_t *items)
{
    try {
        if (-1 != zmq::poll(items, 1, SOCKET_POLLING_TIMEOUT)) {
            return true;
        }
    } catch (const zmq::error_t& zErr) {
        qCCritical(logCategoryZmqConnector).nospace() << "Unable to poll items, reason: " << zErr.what();
    } catch (const std::exception& sErr) {
        qCCritical(logCategoryZmqConnector).nospace() << "Unable to poll items, unexpected reason: " << sErr.what();
    } catch (...) {
        qCCritical(logCategoryZmqConnector).nospace() << "Unable to poll items, unhandled exception";
    }

    return false;
}

bool ZmqConnector::socketAndContextOpen()
{
    if (isConnected()) {
        return false;
    }

    try {
        // erase them in this order
        socket_.release();
        context_.release();
        // will init socket and context
        context_.reset(new zmq::context_t());
        socket_.reset(new zmq::socket_t(*context_, socketType));
        qCDebug(logCategoryZmqConnector) << "Socket and context was open";
        return true;
    } catch (const zmq::error_t& zErr) {
        qCCritical(logCategoryZmqConnector).nospace() << "Unable to open socket, reason: " << zErr.what();
    } catch (const std::exception& sErr) {
        qCCritical(logCategoryZmqConnector).nospace() << "Unable to open socket, unexpected reason: " << sErr.what();
    } catch (...) {
        qCCritical(logCategoryZmqConnector).nospace() << "Unable to open socket, unhandled exception";
    }

    // release these objects in case it failed to allocate them
    socket_.release();
    context_.release();
    return false;
}

void ZmqConnector::socketClose()
{
    // will not close assigned context
    if (nullptr != socket_) {
        socket_->close();   // will assert if it fails
    }
}

void ZmqConnector::contextClose()
{
    // will also close all sockets that use this context and if there was
    // ongoing read/write operation, it will terminate with: 'Context was terminated'
    if (nullptr != context_) {
        context_->close();  // will assert if it fails
    }
}

}  // namespace strata::connector
