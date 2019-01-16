
#ifndef CONNECTOR_IMPL_H__
#define CONNECTOR_IMPL_H__

#include <iostream>
#include <string>
#include <stdlib.h>

#include <libserialport.h>
#include <thread>
#include <mutex>
#include <condition_variable>
#include <cstdio>
#include <cstring>
#include <vector>
#include <chrono>

#include "Connector.h"
#include "rapidjson/document.h"

#include "zmq.hpp"
#include "zmq_addon.hpp"
#include "zhelpers.hpp"
#include <fcntl.h>   // File control definitions
#include <errno.h>   // Error number definitions


#ifdef _WIN32
#include <winsock2.h>
#include <windows.h>
#define sleep(n) Sleep(n*1000);
#endif

// console prints
// DEBUG is used for showing the debug print messages on console.
// 0 - turn off debug and 1 - turn on debug
#define DEBUG 1
#define LOG_DEBUG(lvl, fmt, ...)						\
	do { if (lvl>0) fprintf(stderr, fmt, __VA_ARGS__); } while (0)

class SerialConnector : public Connector {
public:
    SerialConnector();
    SerialConnector(const std::string&) {}
    virtual ~SerialConnector();

    bool open(const std::string&);

    bool close();
    void openPlatform();

    // non-blocking calls
    bool send(const std::string& message);
    bool sendSmallChunks(const std::string& message, const unsigned int chunk_limit);

    bool read(std::string& notification);

    int getFileDescriptor();

    void windowsPlatformReadHandler();
    bool getPlatformID(std::string);
    bool isPlatformConnected();

private:
    struct sp_port *platform_socket_;
    struct sp_event_set *event_;
    int serial_fd_;	//file descriptor for serial ports
#ifdef _WIN32
    std::thread *windows_thread_; // this thread will be used only in windows for port read and write
#endif
    std::thread *open_platform_thread_; // thread to detect and open the spyglass platforms
    std::condition_variable producer_consumer_;
    std::string platform_port_name_;
    // two bool variables used for producer consumer model required for windows
    bool produced_;
    bool consumed_;
    // integer variable used for wait timeout // required only for serial to socket
    int serial_wait_timeout_;

#ifdef _WIN32
    zmq::context_t* context_;
    zmq::socket_t* write_socket_;   // After serial port read, writes to this socket
    zmq::socket_t* read_socket_;
#endif
};

class ZMQConnector : public Connector {
public:
    ZMQConnector(const std::string&);
    virtual ~ZMQConnector();

    bool open(const std::string&);
    bool close();

    // non-blocking calls
    bool send(const std::string& message);
    bool sendSmallChunks(const std::string& message, const unsigned int chunk_limit) { return false; }
    bool read(std::string& notification);

    int getFileDescriptor();

private:
    ZMQConnector() = delete;

private:
    zmq::context_t* context_;
    zmq::socket_t* socket_;
    std::string connection_interface_;
};

class RequestReplyConnector : public Connector {
public:
    RequestReplyConnector();
    RequestReplyConnector(const std::string&);
    virtual ~RequestReplyConnector();

    bool open(const std::string&);
    bool close();

    // non-blocking calls
    bool send(const std::string& message);
    bool sendSmallChunks(const std::string& message, const unsigned int chunk_limit) { return false; }
    bool read(std::string& notification);

    int getFileDescriptor();

private:
    zmq::context_t* context_;
    zmq::socket_t* socket_;
    std::string connection_interface_;
};

class PublisherSubscriberConnector : public Connector {
public:
    PublisherSubscriberConnector(const std::string&);
    virtual ~PublisherSubscriberConnector();

    bool open(const std::string&);
    bool close();

    // non-blocking calls
    bool send(const std::string& message);
    bool sendSmallChunks(const std::string& message, const unsigned int chunk_limit) { return false; }
    bool read(std::string& notification);

    int getFileDescriptor();

private:
    PublisherSubscriberConnector() = delete;

private:
    zmq::context_t* context_;
    zmq::socket_t* socket_;
    std::string connection_interface_;
};

#endif //CONNECTOR_IMPL_H__
