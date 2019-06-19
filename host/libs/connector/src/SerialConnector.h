
#ifndef SerialConnector_H
#define SerialConnector_H

#include <stdlib.h>
#include <iostream>
#include <string>

#include <libserialport.h>
#include <chrono>
#include <condition_variable>
#include <cstdio>
#include <cstring>
#include <mutex>
#include <thread>
#include <vector>

#include "Connector.h"
#include "rapidjson/document.h"

#include <errno.h>  // Error number definitions
#include <fcntl.h>  // File control definitions

#include "zmq.hpp"

#ifdef _WIN32
#include <windows.h>
#include <winsock2.h>
#define sleep(n) Sleep(n * 1000);
#endif

class SerialConnector : public Connector
{
public:
    SerialConnector();
    virtual ~SerialConnector();

    bool open(const std::string&) override;
    bool close() override;

    // non-blocking calls
    bool send(const std::string& message) override;
    bool read(std::string& notification) override;

    // blocking read
    bool read(std::string& notification, ReadMode read_mode) override;
    bool blockingRead(std::string& notification) override;

    connector_handle_t getFileDescriptor() override;

    void openPlatform();
    void windowsPlatformReadHandler();
    bool getPlatformID(std::string);
    bool isPlatformConnected();

private:
    struct sp_port* platform_socket_;
    struct sp_event_set* event_;
#ifdef _WIN32
    std::thread*
        windows_thread_;  // this thread will be used only in windows for port read and write
#endif
    std::thread* open_platform_thread_;  // thread to detect and open the spyglass platforms
    std::condition_variable producer_consumer_;
    std::string platform_port_name_;
    // two bool variables used for producer consumer model required for windows
#ifdef _WIN32
    bool produced_;
    bool consumed_;
#endif
    // integer variable used for wait timeout // required only for serial to socket
    int serial_wait_timeout_;

#ifdef _WIN32
    std::unique_ptr<zmq::context_t> context_;
    std::unique_ptr<zmq::socket_t> write_socket_;  // After serial port read, writes to this socket
    std::unique_ptr<zmq::socket_t> read_socket_;
#endif
};

#endif  // SerialConnector_H
