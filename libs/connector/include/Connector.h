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
