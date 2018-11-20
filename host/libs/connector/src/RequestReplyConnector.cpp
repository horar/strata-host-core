/**
******************************************************************************
* @file DiscoveryServiceConnector [connector]
* @author Prasanth Vivek
* $Rev: 1 $
* $Date: 2018-03-14
* @brief DiscoveryServiceConnector code provides abstraction of the libzmq for
    opening, closing, reading and writing to/from a zmq REQ socket
******************************************************************************

* @copyright Copyright 2018 On Semiconductor
*/

#include "Connector.h"
#include "ZMQSocketConfiguration.h"

using namespace std;

// @f constructor
// @b creates the context for the socket
//
RequestReplyConnector::RequestReplyConnector()
{
    LOG_DEBUG(DEBUG,"Creating Discovery Service connector object\n",0);
    // zmq context creation
    context_ = new(zmq::context_t);
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
bool RequestReplyConnector::open(const string& ip_address)
{
    socket_ = new zmq::socket_t(*context_,ZMQ_REQ);
    try {
        LOG_DEBUG(DEBUG,"Connecting to the discovery server socket %s\n",ip_address.c_str());
        socket_->connect(ip_address.c_str());
    }
    catch (zmq::error_t& e) {
        LOG_DEBUG(DEBUG,"Error in opening remote\n",0);
        return false;
    }
    return true;
}

// @f close
// @b close the ZMQ socket
//
bool RequestReplyConnector::close()
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
int RequestReplyConnector::getFileDescriptor()
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
bool RequestReplyConnector::read(string& message)
{
    zmq::pollitem_t items = {*socket_, 0, ZMQ_POLLIN, 0 };
    // [prasanth] : adding timeout of 5 seconds. Incase if discovery server fails
    // the control should return without blocking other functionalities
    zmq::poll (&items,1,REQUEST_SOCKET_TIMEOUT);
    if(items.revents & ZMQ_POLLIN) {
        message = s_recv(*socket_);
    }
    else {
        return false;
    }
    LOG_DEBUG(DEBUG,"[Socket] Rx'ed message : %s\n",message.c_str());
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
bool RequestReplyConnector::send(const string& message)
{
    s_send(*socket_,message);
    LOG_DEBUG(DEBUG,"[Socket] sned message : %s\n",message.c_str());
    return true;
}
