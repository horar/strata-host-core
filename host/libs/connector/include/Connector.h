/**
******************************************************************************
* @file Connector.h
* @author Prasanth Vivek
* $Rev: 1 $
* $Date: 2018-03-14
* @brief Abstract class for connector objects
******************************************************************************

* @copyright Copyright 2018 ON Semiconductor
*/

/**
 * @mainpage libconnectors API
 *
 * Introduction
 * ============
 *
 * linconnectors is minimalistic library written in cpp. Libconnectors uses
 * "zeroMQ" for serial and socket I/O operation and takes OS-specific details
 * when writing software that uses sockets and serial ports.
 *
 * The library was conceived by Ian Cain and Prasanth Vivek.
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
 */

#pragma once

#include <iostream>
#include <string>

namespace strata::connector {

// ENUM for blocking and non blocking read
enum class ReadMode {
    BLOCKING = 0,
    NONBLOCKING
};
#ifdef _WIN32
    typedef intptr_t connector_handle_t;
#else
    typedef int connector_handle_t;
#endif

class Connector
{
public:
    Connector() = default;
    virtual ~Connector() = default;

    virtual bool open(const std::string&) = 0;
    virtual bool close() = 0;
    virtual bool shutdown() = 0;

    // non-blocking send
    virtual bool send(const std::string& message) = 0;

    // choose blocking or non-blocking read mode
    virtual bool read(std::string& notification, ReadMode read_mode) = 0;

    // non-blocking read
    virtual bool read(std::string& notification) = 0;

    // blocking read
    virtual bool blockingRead(std::string& notification) = 0;

    virtual connector_handle_t getFileDescriptor() = 0;

    /**
     * @brief addSubscriber - a hack due to ZmqPublisherConnector class
     * @param dealerID
     */
    virtual void addSubscriber(const std::string& dealerID);

    void setDealerID(const std::string& id);
    std::string getDealerID() const;

    void setConnectionState(bool connection_state);
    bool isConnected() const;

    friend std::ostream& operator<<(std::ostream& stream, const Connector& c);

    enum class CONNECTOR_TYPE { SERIAL, ROUTER, DEALER, PUBLISHER, SUBSCRIBER, REQUEST, RESPONSE };
    static std::unique_ptr<Connector> getConnector(const CONNECTOR_TYPE type);

private:
    std::string dealer_id_;
    std::string server_;

    bool connection_state_ = false;
};

}  // namespace strata::connector
