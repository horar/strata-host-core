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

#include "zmq.hpp"
#include "zmq_addon.hpp"
#include "zhelpers.hpp"
#include <fcntl.h>   // File control definitions
#include <errno.h>   // Error number definitions

#ifdef _WIN32
#include <winsock2.h>
#include <windows.h>
#endif

class Connector {
public:
    Connector() {}
    Connector(std::string) {}
    virtual ~Connector() {}

    virtual bool open(std::string) = 0;
    virtual bool close() = 0;

    // non-blocking calls
    virtual bool send(std::string message) = 0;
    virtual bool read(std::string &notification) = 0;

    friend std::ostream& operator<< (std::ostream& stream, const Connector & c) {
        std::cout << "Connector: " << std::endl;
        std::cout << "  server: " << c.server_ << std::endl;
        return stream;
    }

    virtual int getFileDescriptor() = 0;

    std::string dealer_id_;
protected:
    std::string client_id_;
    std::string server_;


private:
};

class SerialConnector : public Connector {
public:
    SerialConnector();
    SerialConnector(std::string){}
    virtual ~SerialConnector(){}

    bool open(std::string);

    bool close(){}

    // non-blocking calls
    bool send(std::string message);

    bool read(std::string &notification);

    int getFileDescriptor();

private:

    struct sp_port *platform_socket_;
    struct sp_event_set *ev;
    sp_return error;
    int serial_fd_;	//file descriptor for serial ports
#define TESTING
#ifdef TESTING
    std::string usb_keyword;
    std::string platform_id_json_;
#ifdef _APPLE_
    usb_keyword = "usb";
#elif _linux_
    usb_keyword = "USB";
#endif
    std::string platform_port_name;

#endif
#ifdef _WIN32
    zmq::context_t* context_;
    zmq::socket_t* socket_;
#endif
};

class ZMQConnector : public Connector {
public:
    ZMQConnector() {}
    ZMQConnector(std::string);
    virtual ~ZMQConnector() {}

    bool open(std::string);

    bool close(){}

    // non-blocking calls
    bool send(std::string message);
    bool read(std::string &notification);

    int getFileDescriptor();

    //std::string dealer_id_;

private:
    zmq::context_t* context_;
    zmq::socket_t* socket_;
    std::string connection_interface_;
};

class ConnectorFactory {
public:
    static Connector *getConnector(std::string type) {
        std::cout << "ConnectorFactory::getConnector type:" << type << std::endl;
        if( type == "client") {
            return dynamic_cast<Connector*>(new ZMQConnector("local"));
        }
        else if( type == "remote") {
            return dynamic_cast<Connector*>(new ZMQConnector("remote"));
        }
        else if( type == "platform") {
            return dynamic_cast<Connector*>(new SerialConnector);
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
