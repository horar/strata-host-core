/*
******************************************************************************
* @file zmq-connector [connector]
* @author Prasanth Vivek
* $Rev: 1 $
* $Date: 2018-03-14
* @brief ZMQ DEALER/ROUTER socket; API for opening, closing, reading and
    writing to/from a DEALER/ROUTER socket
******************************************************************************

* @copyright Copyright 2018 On Semiconductor
*/

#include "Connector_impl.h"

using namespace std;


static std::string hex2Str(unsigned char* data, size_t len)
{
    std::stringstream ss;
    ss << std::hex;
    for(size_t i=0;i < len; i++)
        ss << std::setw(2) << std::setfill('0') << (int)data[i];
    return ss.str();
}



// @f constructor
// @b creates the context for the socket
//
ZMQConnector::ZMQConnector(const string& type) : Connector(),
    context_(new zmq::context_t ),
    socket_(nullptr),
    connection_interface_(type)
{
    LOG_DEBUG(DEBUG,"Creating ZMQ connector object for %s\n", type.c_str());
}

ZMQConnector::~ZMQConnector()
{
    if (socket_) {
        close();
        delete socket_;
    }

    delete context_;
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
bool ZMQConnector::open(const string& ip_address)
{
    if(connection_interface_ == "dealer") {
        socket_ = new zmq::socket_t(*context_,ZMQ_DEALER);
        try {
            LOG_DEBUG(DEBUG,"Connecting to the remote server socket %s\n",ip_address.c_str());

            const std::string& id = getDealerID();
            if (!id.empty()) {
                socket_->setsockopt(ZMQ_IDENTITY, id.c_str(), id.length());
            }
            socket_->connect(ip_address.c_str());

        }
        catch (zmq::error_t& e) {
            LOG_DEBUG(DEBUG,"Error in opening remote\n",0);
            return false;
        }
    } else if(connection_interface_ == "router") {
        socket_ = new zmq::socket_t(*context_,ZMQ_ROUTER);
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
bool ZMQConnector::close()
{
    socket_->close();
    setConnectionState(false);
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
int ZMQConnector::getFileDescriptor()
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
bool ZMQConnector::read(string& message)
{
    zmq::pollitem_t items = {*socket_, 0, ZMQ_POLLIN, 0 };
    zmq::poll (&items,1,10);
    if(items.revents & ZMQ_POLLIN) {
        // [prasanth] : Only for client UI connection since they are dealer socket
        // while reading from dealer socket, you will have two messages,
        // 1) dealer_id and 2) message
        // remote sockets read from router and they have only message and not dealer id
        locker_.lock();
        if(connection_interface_ == "router") {
            std::string dealer_id = s_recv(*socket_);
            setDealerID(dealer_id);
        }
        message = s_recv(*socket_);
        locker_.unlock();
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
bool ZMQConnector::send(const string& message)
{
    // [prasanth] : Only for client UI connection since they are dealer socket
    // while writing to dealer socket, you will have two messages,
    // 1) dealer_id and 2) message
    // remote sockets write to router and they have only message and not dealer id
    locker_.lock();
    if(connection_interface_ == "router") {
        s_sendmore(*socket_, getDealerID() );
    }
    s_send(*socket_,message);
    LOG_DEBUG(DEBUG,"[Socket] Tx'ed message : %s\n",message.c_str());
    locker_.unlock();
    unsigned int     zmq_events;
    size_t           zmq_events_size  = sizeof(zmq_events);
    socket_->getsockopt(ZMQ_EVENTS, &zmq_events, &zmq_events_size);
    
    return true;
}
