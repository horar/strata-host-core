#include "ZmqConnector.h"

#include <bitset>
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
    // and THEN they invalidate the pointer, which has issues in multithreaded operations
    // because they can still be considered valid - for which we need this boolean
    setConnectionState(false);

    socketClose();  // must be called before contextClose
    contextClose();

    qCDebug(logCategoryZmqConnector) << "Context was closed";
    return true;
}

bool ZmqConnector::shutdown()
{
    if (false == isConnected()) {
        return false;
    }

    setConnectionState(false);
    contextShutdown();          // will emit interrupt signal for all read/write operations

    qCDebug(logCategoryZmqConnector) << "Context was terminated";
    return true;
}

bool ZmqConnector::send(const std::string& message)
{
    if (false == socketValid()) {
        qCCritical(logCategoryZmqConnector) << "Unable to send messages, socket not open";
        return false;
    }

    if (false == socketSend(message)) {
        qCWarning(logCategoryZmqConnector).nospace().noquote()
                << "Failed to send message: '" << QString::fromStdString(message) << "'";
        return false;
    }

    qCDebug(logCategoryZmqConnector).nospace().noquote()
            << "Tx'ed message: '" << QString::fromStdString(message) << "'";
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

    if (true == hasReadEvent()) {
        if (socketRecv(message)) {
            qCDebug(logCategoryZmqConnector).nospace().noquote()
                    << "Rx'ed message: '" << QString::fromStdString(message) << "'";
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
        qCDebug(logCategoryZmqConnector).nospace().noquote()
                << "Rx'ed blocking message: '" << QString::fromStdString(message) << "'";
        return true;
    }

    if(false == socketValid()) {
        qCDebug(logCategoryZmqConnector) << "Context was terminated, blocking read was interrupted";
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

    connector_handle_t server_socket_file_descriptor;
    if (false == socketGetOptInt(zmq::sockopt::fd, server_socket_file_descriptor))
        return defaultHandle;

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

bool ZmqConnector::hasReadEvent()
{
    int event;
    socketGetOptInt(zmq::sockopt::events, event);
    return std::bitset<sizeof(int)>(event).test(ZMQ_POLLIN - 1);
}

bool ZmqConnector::hasWriteEvent()
{
    int event;
    socketGetOptInt(zmq::sockopt::events, event);
    return std::bitset<sizeof(int)>(event).test(ZMQ_POLLOUT - 1);
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
                    << "Receive of messages was interrupted (flags: "
                    << static_cast<int>(flags) << "), reason: " << zErr.what();
        } else {
            qCCritical(logCategoryZmqConnector).nospace()
                    << "Unable to receive message (flags: "
                    << static_cast<int>(flags) << "), reason: " << zErr.what();
        }
    } catch (const std::exception& sErr) {
        qCCritical(logCategoryZmqConnector).nospace()
                << "Unable to receive message (flags: "
                << static_cast<int>(flags) << "), unexpected reason: " << sErr.what();
    } catch (...) {
        qCCritical(logCategoryZmqConnector).nospace()
                << "Unable to receive message (flags: "
                << static_cast<int>(flags) << "), unhandled exception";
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
            qCInfo(logCategoryZmqConnector).nospace().noquote()
                    << "Sending of message was interrupted '" << QString::fromStdString(istring)
                    << "' (flags: " << static_cast<int>(flags) << "), reason: " << zErr.what();
        } else {
            qCCritical(logCategoryZmqConnector).nospace().noquote()
                    << "Unable to send message '" << QString::fromStdString(istring)
                    << "' (flags: " << static_cast<int>(flags) << "), reason: " << zErr.what();
        }
    } catch (const std::exception& sErr) {
        qCCritical(logCategoryZmqConnector).nospace().noquote()
                << "Unable to send message '" << QString::fromStdString(istring)
                << "' (flags: " << static_cast<int>(flags) << "), unexpected reason: " << sErr.what();
    } catch (...) {
        qCCritical(logCategoryZmqConnector).nospace().noquote()
                << "Unable to send message '" << QString::fromStdString(istring)
                << "' (flags: " << static_cast<int>(flags) << "), unhandled exception";
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
            qCInfo(logCategoryZmqConnector).nospace().noquote()
                    << "Sending of multipart message was interrupted '"
                    << QString::fromStdString(istring) << "', reason: " << zErr.what();
        } else {
            qCCritical(logCategoryZmqConnector).nospace().noquote()
                    << "Unable to send multipart message '"
                    << QString::fromStdString(istring) << "', reason: " << zErr.what();
        }

    } catch (const std::exception& sErr) {
        qCCritical(logCategoryZmqConnector).nospace().noquote()
                << "Unable to send multipart message '"
                << QString::fromStdString(istring) << "', unexpected reason: " << sErr.what();
    } catch (...) {
        qCCritical(logCategoryZmqConnector).nospace().noquote()
                << "Unable to send multipart message '"
                << QString::fromStdString(istring) << "', unhandled exception";
    }

    return false;
}

bool ZmqConnector::socketConnect(const std::string & address)
{
    try {
        socket_->connect(address);
        return true;
    } catch (const zmq::error_t& zErr) {
        qCCritical(logCategoryZmqConnector).nospace().noquote()
                << "Unable to connect socket to address '" << QString::fromStdString(address)
                << "', reason: " << zErr.what();
    } catch (const std::exception& sErr) {
        qCCritical(logCategoryZmqConnector).nospace().noquote()
                << "Unable to connect socket to address '" << QString::fromStdString(address)
                << "', unexpected reason: " << sErr.what();
    } catch (...) {
        qCCritical(logCategoryZmqConnector).nospace().noquote()
                << "Unable to connect socket to address '" << QString::fromStdString(address)
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
        qCCritical(logCategoryZmqConnector).nospace().noquote()
                << "Unable to bind socket to address '" << QString::fromStdString(address)
                << "', reason: " << zErr.what();
    } catch (const std::exception& sErr) {
        qCCritical(logCategoryZmqConnector).nospace().noquote()
                << "Unable to bind socket to address '" << QString::fromStdString(address)
                << "', unexpected reason: " << sErr.what();
    } catch (...) {
        qCCritical(logCategoryZmqConnector).nospace().noquote()
                << "Unable to bind socket to address '" << QString::fromStdString(address)
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
        qCCritical(logCategoryZmqConnector) << "Unable to poll items, reason:" << zErr.what();
    } catch (const std::exception& sErr) {
        qCCritical(logCategoryZmqConnector) << "Unable to poll items, unexpected reason:" << sErr.what();
    } catch (...) {
        qCCritical(logCategoryZmqConnector) << "Unable to poll items, unhandled exception";
    }

    return false;
}

bool ZmqConnector::socketAndContextOpen()
{
    if ((nullptr != socket_) || (nullptr != context_)) {
        if ((nullptr != socket_) && (nullptr != context_) &&
            (nullptr == context_->handle()) && (false == socket_->connected()) &&
            (false == isConnected())) {
            qCInfo(logCategoryZmqConnector) << "Reopening socket";
            // must be reset in this order
            socket_.reset();
            context_.reset();
        } else {
            qCCritical(logCategoryZmqConnector) << "Unable to open socket, it is already open";
            return false;
        }
    }

    try {
        // will init socket and context
        context_.reset(new zmq::context_t());
        socket_.reset(new zmq::socket_t(*context_, socketType));
        qCDebug(logCategoryZmqConnector) << "Socket and context was open";
        return true;
    } catch (const zmq::error_t& zErr) {
        qCCritical(logCategoryZmqConnector) << "Unable to open socket, reason:" << zErr.what();
    } catch (const std::exception& sErr) {
        qCCritical(logCategoryZmqConnector) << "Unable to open socket, unexpected reason:" << sErr.what();
    } catch (...) {
        qCCritical(logCategoryZmqConnector) << "Unable to open socket, unhandled exception";
    }

    socket_.reset();
    context_.reset();
    return false;
}

void ZmqConnector::socketClose()
{
    // should be followed by context closing to properly terminate all active operations
    // or preceded by terminating all read/write operations manually
    if (nullptr != socket_) {
        socket_->close();   // will assert if it fails
    }
}

void ZmqConnector::contextClose()
{
    // will terminate all read/write operations with: 'Context was terminated'
    // make sure to terminate all sockets that use this context BEFORE calling this
    // because it will get stuck FOREVER waiting for them to terminate
    if (nullptr != context_) {
        context_->close();  // will assert if it fails
    }
}

void ZmqConnector::contextShutdown()
{
    // will terminate all read/write operations with: 'Context was terminated'
    if (nullptr != context_) {
        context_->shutdown();  // will assert if it fails
    }
}

} // namespace strata::connector
