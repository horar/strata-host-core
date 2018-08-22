/**
******************************************************************************
* @file Connector.h
* @author Prasanth Vivek
* $Rev: 1 $
* $Date: 2018-03-14
* @brief Abstract class for connector objects
******************************************************************************

* @copyright Copyright 2018 On Semiconductor
*/

/**
 * @mainpage libconnectors API
 *
 * Introduction
 * ============
 *
 * linconnectors is minimalistic library written in cpp. Libconnectors uses
 * "libserialport" and "zeroMQ" for serial and socket I/O operation and takes
 * care of the OS-specific details when writing software that uses sockets and
 * serial ports.
 *
 * The library was conceived by Ian Cain, designed and maintained by
 * Ian Cain and Prasanth Vivek.
 *
 * API information
 * ===============
 *
 * The following subsections will help explain the principles of the API.
 *
 * Headers
 * -------
 *
 * To use libconnectors functions in your code, you should include the
 * Connector.h header, i.e. "#include <Connector.h>".
 *
 * Functions
 * ---------
 *
 * The functions provided by the library are documented in detail in
 * the following sections:
 *
 * - open() (opens the serial port or opens the dealer/router socket) (serial/socket)
 * - close() (closing ports/sockets) (serial/socket)
 * - read() (reading data from serial port/sockets) (serial/socket)
 * - send() (writing data to serial port/sockets) (serial/socket)
 * - getFileDescriptor() (get file descriptor information of serial port/sockets) (serial/socket)
 * - getDealerID() (gets the dealer id of the dealer sockets) (socket)
 * - getPlatformUUID() (gets the platform uuid from the serial port) (serial)
 *
 * Debugging
 * ---------
 *
 * The library can output extensive tracing and debugging information. The
 * simplest way to use this is to set DEBUG variable to "1" in Connector.h
 * messages will then be output to the standard error stream.
 *
 * No guarantees are made about the content of the debug output; it is chosen
 * to suit the needs of the developers and may change between releases.
 *
 * Porting
 * -------
 * LINUX and MAC implementations are straight forward for open, close, read and
 * write operations. getFileDescriptor() returns the file descriptor of the serial handle.
 *
 * WINDOWS implementation has a layer of abstraction for Serial read operation.
 * Windows Serial read uses libserial port non blocking read to read from the platform
 * and writes to PUSH ZMQ socket in a seperate thread. Libconnectors read() reads the platform
 * data from ZMQ PULL socket. This approach is implemented to support the eventing systems.
 * Other operations like open(),close() and send() are stright forward and same like LINUX
 * and MAC OS. getFileDescriptor() returns the file descriptor of the ZMQ PULL socket.
 *
 * KNOWN BUGS/HACKS
 * ================
 *
 * This section mentions about the technical bugs and our work around in detail
 *
 * 1) PUSH PULL socket for windows (Techinal Hardship)
 *		In Windows, libconnectors uses PUSH-PULL socket for reading data from the serial device.
 * libconnectors runs a thread that reads from the serial port and writes to a ZMQ PUSH socket.
 * Libconnectors read() gets the platform data by reading from the corressponding PULL socket.
 * This method is used to support the eventing systems like libevent.
 *
 * 2) Serial open() returns true only on reading the platform uuid from platform (HACK)
 *		In order to automatically detect the serial platform board, libconnectors uses libserialport to
 * enumerate the ports. Then it asks for platform UUID from the list. i.e) after opening a port from
 * the list, libconnectors send the "platform id request message" to the platform. Then it reads twice
 * from the platform with 50m sec delay in a loop with 5 iterations(This iteration is used because some
 * platform may take some time to load the software stack after power (for example: USB-PD-Load board)).
 *
 * 3) libserialport sp_wait not working in windows (Techinal Hardship/HACK)
 *		sp_wait() waits for completion of event (receive) and returns '0' or SP_OK on success.
 * It uses WaitForMultipleObjects() in windows. But in windows, sp_wait always returns '0' or
 * SP_OK instead of waiting for the read event. This increases the CPU usage in windows since we use a thread
 * to read from platform. Currently libserialport has a workaround by sleeping for 100ms before trying to read
 * from the serial port.
 *
 * 4) ST-Eval board disconnect not detected by libserialport read in windows (Techinal Hardship/HACK)
 *		Currently the platform disconnect is detected by the return value of read(). If read returns a negative
 * number, then the serial device is no more connected. But ST-EVAL boards (ST32L476VG in particular) on disconnecting
 * returns '0'. This behaviour hinders our platform disconnect detection. Currently the work around for this
 * specific issue is writing to the platform after 10 consecutive '0' return from read(). This helps
 * in detecting the ST-board disconnect. This issue is not noticed in other boards (Orion USB-PD, STM-USB-PD,
 * STM-USB_LOAD_BOARD) and only specific to VORTEX_FOUNTAIN project that uses ST Eval board. This logic is
 * enabled/disabled by setting ST_EVAL_BOARD_SUPPORT_ENABLED to 1/0 respectively in SerialConnector.cc
 *
 * 5) Serial messaged overlap in windows (Known Bug/HACK)
 *		In windows serial read some times produces overlapping of two messages when platform writes data at
 * high rate (10HZ). One example of the overlapped message read in windows is,
 *
 * {"notification":{"value":"pi_stats","payload":{"speed_target":1500,"current_speed":1500{"notification":{"value":
 * "pi_stats","payload":{"speed_target":1500,"current_speed":1520,"error":-20,"sum":-4.00e-4,"duty_now":0.19,"mode":"manual"}}}
 *
 * The above example contains two messages overlapped over each other. This overlapping happens
 * at a sleep of 200ms. After reducing the sleep time to 50ms, there is no overlapping. The average CPU usage in windows 7
 * four core operating at 2.3GHz is 3.
 *
 */

#ifndef CONNECTOR_H__
#define CONNECTOR_H__

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

#include "zmq.hpp"
#include "zmq_addon.hpp"
#include "zhelpers.hpp"
#include <fcntl.h>   // File control definitions
#include <errno.h>   // Error number definitions

#include "rapidjson/document.h"

#ifdef _WIN32
#include <winsock2.h>
#include <windows.h>
#define sleep(n) Sleep(n*1000);
#endif

// console prints
// DEBUG is used for showing the debug print messages on console.
// 0 - turn off debug and 1 - turn on debug
#define DEBUG 0
#define LOG_DEBUG(lvl, fmt, ...)						\
	do { if (lvl>0) fprintf(stderr, fmt, __VA_ARGS__); } while (0)

class Connector {
public:
    Connector() {}
    Connector(const std::string&) {}
    virtual ~Connector() {}

    virtual bool open(const std::string&) = 0;
    virtual bool close() = 0;


    // non-blocking calls
    virtual bool send(const std::string& message) = 0;
    virtual bool sendSmallChunks(const std::string& message, const unsigned int chunk_limit)=0;
    virtual bool read(std::string& notification) = 0;

    friend std::ostream& operator<< (std::ostream& stream, const Connector & c) {
        std::cout << "Connector: " << std::endl;
        std::cout << "  server: " << c.server_ << std::endl;
        return stream;
    }

    virtual int getFileDescriptor() = 0;

    void setDealerID(const std::string& id) {dealer_id_ = id;}
    const std::string &getDealerID() const {return dealer_id_;}
    const std::string &getPlatformUUID() const { return platform_uuid_;}
    bool isSpyglassPlatform() { return spyglass_platform_connected_; }
	void setConnectionState(bool connection_state) { connection_state_ = connection_state; }
	bool isConnected() { return connection_state_; }
protected:
    std::string dealer_id_;
    std::mutex locker_;
    std::string platform_uuid_;
    std::string server_;
    bool spyglass_platform_connected_;	// flag used in hcs for checking if platform is available
	bool connection_state_;
private:
};

class SerialConnector : public Connector {
public:
    SerialConnector();
    SerialConnector(const std::string&){}
    virtual ~SerialConnector(){}

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

// #ifdef _WIN32
    zmq::context_t* context_;
    zmq::socket_t* write_socket_;   // After serial port read, writes to this socket
    zmq::socket_t* read_socket_;
// #endif
};

class ZMQConnector : public Connector {
public:
    ZMQConnector() {}
    ZMQConnector(const std::string&);
    virtual ~ZMQConnector() {}

    bool open(const std::string&);
    bool close();

    // non-blocking calls
    bool send(const std::string& message);
    bool sendSmallChunks(const std::string& message, const unsigned int chunk_limit){}
    bool read(std::string& notification);

    int getFileDescriptor();

private:
    zmq::context_t* context_;
    zmq::socket_t* socket_;
    std::string connection_interface_;
};

class RequestReplyConnector : public Connector {
public:
    RequestReplyConnector() ;
    RequestReplyConnector(const std::string&){}
    virtual ~RequestReplyConnector() {}

    bool open(const std::string&);
    bool close();

    // non-blocking calls
    bool send(const std::string& message);
    bool sendSmallChunks(const std::string& message, const unsigned int chunk_limit){}
    bool read(std::string& notification);

    int getFileDescriptor();

private:
    zmq::context_t* context_;
    zmq::socket_t* socket_;
    std::string connection_interface_;
};

class PublisherSubscriberConnector : public Connector {
public:
  	PublisherSubscriberConnector() {}
    PublisherSubscriberConnector(const std::string&);
    virtual ~PublisherSubscriberConnector() {}

    bool open(const std::string&);
    bool close();

    // non-blocking calls
    bool send(const std::string& message);
    bool sendSmallChunks(const std::string& message, const unsigned int chunk_limit){}
    bool read(std::string& notification);

    int getFileDescriptor();

private:
    zmq::context_t* context_;
    zmq::socket_t* socket_;
    std::string connection_interface_;
};

class ConnectorFactory {
public:
    static Connector *getConnector(const std::string& type) {
        std::cout << "ConnectorFactory::getConnector type:" << type << std::endl;
        if( type == "router") {
            return dynamic_cast<Connector*>(new ZMQConnector("router"));
        }
        else if( type == "dealer") {
            return dynamic_cast<Connector*>(new ZMQConnector("dealer"));
        }
        else if( type == "platform") {
            return dynamic_cast<Connector*>(new SerialConnector);
        }
        else if( type == "request") {
            return dynamic_cast<Connector*>(new  RequestReplyConnector);
        }
        else if( type == "subscriber") {
            return dynamic_cast<Connector*>(new  PublisherSubscriberConnector("subscribe"));
        }
        else {
            std::cout << "ERROR: ConnectorFactory::getConnector - unknown interface. " << type << std::endl;
        }
        return nullptr;
    }

private:
    // TODO use = delete
    ConnectorFactory() { std::cout << "ConnectorFactory: CTOR\n"; }
    virtual ~ConnectorFactory() { std::cout << "ConnectorFactory: DTOR\n"; }

};
#endif
