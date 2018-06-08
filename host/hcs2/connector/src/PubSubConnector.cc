/*
******************************************************************************
* @file pub-sub-connector [connector]
* @author Prasanth Vivek
* $Rev: 1 $
* $Date: 2018-05-10
* @brief ZMQ PUBLISHER/SUBSCRIBER socket; API for opening, closing, reading and
    writing to/from a DEALER/ROUTER socket
******************************************************************************

* @copyright Copyright 2018 On Semiconductor
*/

#include "Connector.h"

using namespace std;

// @f constructor
// @b creates the context for the socket
//
PublisherSubscriberConnector::PublisherSubscriberConnector(const string& type)
{
    LOG_DEBUG(DEBUG,"Creating PublisherSubscriberConnector connector object for %s\n",type.c_str());
    // zmq context creation
    context_ = new(zmq::context_t);
    connection_interface_ = type;
}

// @f open
// @b gets the ip address and opens, if fail return false and if success return true
//
// arguments:
//  IN: string ip address
//
//  OUT: true, if device is connected
//       false, if device is not connected
//
//
bool PublisherSubscriberConnector::open(const string& ip_address)
{
    if(connection_interface_ == "subscribe") {
        socket_ = new zmq::socket_t(*context_,ZMQ_SUB);
        try {
            LOG_DEBUG(DEBUG,"Connecting to the remote server socket %s with filter %s\n",ip_address.c_str(),dealer_id_.c_str());
            socket_->setsockopt(ZMQ_SUBSCRIBE,dealer_id_.c_str(),1);
            socket_->connect(ip_address.c_str());
        }
        catch (zmq::error_t& e) {
            LOG_DEBUG(DEBUG,"Error in opening remote\n",0);
            return false;
        }
    } else if(connection_interface_ == "publish") {
        socket_ = new zmq::socket_t(*context_,ZMQ_PUB);
        try {
            socket_->bind(ip_address.c_str());
        }
        catch (zmq::error_t& e) {
            return false;
        }
    }
    return true;
}

// @f close
// @b close the ZMQ socket
//
bool PublisherSubscriberConnector::close()
{
    socket_->close();
    return true;
}

// @f getFileDescriptor
// @b returns the file descriptor
//
// arguments:
//  IN:
//
//  OUT: file descriptor
//
//
int PublisherSubscriberConnector::getFileDescriptor()
{
#ifdef _WIN32
    unsigned long long int server_socket_file_descriptor;
#else
    int server_socket_file_descriptor=0;
#endif
    size_t server_socket_file_descriptor_size = sizeof(server_socket_file_descriptor);
    socket_->getsockopt(ZMQ_FD,&server_socket_file_descriptor,
            &server_socket_file_descriptor_size);
    return server_socket_file_descriptor;
}

// @f read
// @b reads from the dealer socket
//
// arguments:
//  IN: std::string read message
//
//  OUT: bool, true on success and false otherwise
//
bool PublisherSubscriberConnector::read(string& message)
{
    zmq::pollitem_t items = {*socket_, 0, ZMQ_POLLIN, 0 };
    zmq::poll (&items,1,10);
    if(items.revents & ZMQ_POLLIN) {
        // [prasanth] : Only for client UI connection since they are dealer socket
        // while reading from dealer socket, you will have two messages,
        // 1) dealer_id and 2) message
        // remote sockets read from router and they have only message and not dealer id
        if(connection_interface_ == "publish") {
            dealer_id_ = s_recv(*socket_);
        }
        message = s_recv(*socket_);
    }
    else {
        return false;
    }
    LOG_DEBUG(DEBUG,"[Socket] Rx'ed message : %s\n",message.c_str());
    unsigned int     zmq_events;
    size_t           zmq_events_size  = sizeof(zmq_events);
    socket_->getsockopt(ZMQ_EVENTS, &zmq_events, &zmq_events_size);
    return true;
}

// @f write
// @b writes to the client UI socket
//
// arguments:
//  IN: string to be written
//
//  OUT: true if success and false if fail
//
//
bool PublisherSubscriberConnector::send(const string& message)
{
    // 1) dealer_id and 2) message
    if(connection_interface_ == "publish") {
        s_sendmore(*socket_,dealer_id_);
    }
    s_send(*socket_,message);
    unsigned int     zmq_events;
    size_t           zmq_events_size  = sizeof(zmq_events);
    socket_->getsockopt(ZMQ_EVENTS, &zmq_events, &zmq_events_size);
}
