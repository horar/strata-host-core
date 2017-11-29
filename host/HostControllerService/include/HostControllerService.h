/*
 * HostControllerService.cpp
 */

#ifndef HOSTCONTROLLERSERVICE_H_
#define HOSTCONTROLLERSERVICE_H_

#include <chrono>
#include <thread>

#include "USBConnector.h"
#include "ZeroMQConnector.h"
#include "Connector.h"
#include "ConnectFactory.h"
#include "ArduinoJson.h"
#include <libserialport.h>

// NIMBUS integration **Needs better organisation --Prasanth**
#include "Observer.h"
#include "ParseConfig.h"

enum class connected_state {
    CONNECTED,
    DISCONNECTED
};

void callbackServiceHandler(evutil_socket_t fd ,short what, void* hostP );
void heartBeatPeriodicEvent(evutil_socket_t fd ,short what, void* hostP);
class HostControllerService {
public:

    // TODO : ian : host_packet this is a duplicate structure with
    //   Observer.h struct host_packet
    //   move to a common location or remove all together. Not sure of it's purpose

    // TODO : what is a "host_packet"? this doesn't even make sense.
    //    it is the sockets and service/serial port .... AND the HCS itself? the "this pointer?
    //    void * user_context pointers to 0mq event callback functions is the correct way of
    //    pointing back to "self".
    //
    struct host_packet {
        zmq::socket_t* command;
        zmq::socket_t* notify;
        zmq::socket_t* simulationOnly;

        Connector *platform;
        Connector *service;
        Connector *simulation;

        HostControllerService *hcs; // TODO why do we need a reference back to 'this' pointer?

        event_base *base;
    } hostP;

    HostControllerService(std::string);
    ~HostControllerService();

    friend void callbackServiceHandler(evutil_socket_t fd ,short what, void* hostP);
    friend void heartBeatPeriodicEvent(evutil_socket_t fd ,short what, void* hostP);
    void callbackPlatformHandler(void* hostP);

    bool openPlatformSocket();
    void initPlatformSocket();
    bool verifyReceiveCommand(std::string command, std::string *response);
    connected_state wait();

    struct sp_port *platform_socket_;
    struct sp_event_set *ev;
    sp_return error;

private :
    ConnectFactory *conObj;
    zmq::context_t* context;
    zmq::socket_t* commandAck;
    zmq::socket_t* notifyAll;
    zmq::socket_t* simulationQemuSocket;

    std::string command_address_;
    std::string subscription_address_;

    connected_state platform_;
    bool simulation_;
    bool platformConnect;
    ParseConfig *configuration_;
};


#endif // HOSTCONTROLLERSERVICE_H_
