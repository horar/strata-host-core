/**
******************************************************************************
* @file Connector.h
* @author Prasanth Vivek
* $Rev: 2 $
* $Date: 2021-02-02
* @brief Abstract class for connector objects
******************************************************************************

* @copyright Copyright 2021 ON Semiconductor
*/

/**
 * @mainpage libconnector API
 *
 * Introduction
 * ============
 *
 * linconnector is minimalistic library written in cpp. Libconnector uses
 * "zeroMQ" for socket I/O operation.
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
 * To use libconnector functions in your code, you should include the
 * Connector.h header, i.e. "#include <Connector.h>".
 *
 * Functions
 * ---------
 *
 * The functions provided by the library are documented in detail in
 * the following sections:
 *
 * - getConnector() (creates Connector object with the specified CONNECTOR_TYPE)
 * - open() (opens the socket, configuring and connecting it to the speciffied IP address)
 * - close() (closes the open socket, to reuse the socket, open() must be called again)
 * - shutdown() (sends terminate signal to all ongoing read/write operations on the open socket, should be later followed by close())
 * - read() (reads data from open socket using either blocking or non-blocking approach)
 * - send() (writes data into open socket)
 * - getFileDescriptor() (get file descriptor information of open socket)
 * - addSubscriber() (for publisher socket, adds a subscriber to the list of subscribers)
 * - getDealerID() (gets the dealer id of the socket)
 * - setDealerID() (sets the dealer id of the socket)
 * - isConnected() (returns if the socket is currently connected)
 *
 * Debugging
 * ---------
 *
 * The library outputs extensive tracing and debugging information using Qt
 * logging framework. Simply enable adequate log level in the Qt application
 * using this library and it will log the messages.
 *
 * No guarantees are made about the content of the debug output; it is chosen
 * to suit the needs of the developers and may change between releases.
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
    typedef uintptr_t connector_handle_t;
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

    bool isConnected() const;
    virtual bool hasReadEvent();
    virtual bool hasWriteEvent();

    friend std::ostream& operator<<(std::ostream& stream, const Connector& c);

    enum class CONNECTOR_TYPE { SERIAL, ROUTER, DEALER, PUBLISHER, SUBSCRIBER, REQUEST, RESPONSE };
    static std::unique_ptr<Connector> getConnector(const CONNECTOR_TYPE type);

protected:
    void setConnectionState(bool connection_state);

private:
    std::string dealer_id_; // byte array
    std::string server_;

    bool connection_state_ = false;
};

}  // namespace strata::connector
