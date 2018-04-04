/**
******************************************************************************
* @file serial-connector [connector]
* @author Prasanth Vivek
* $Rev: 1 $
* $Date: 2018-03-14
* @brief Serial connector code provides abstraction of the libserial port for
    opening, closing, reading and writing to/from a serial port
******************************************************************************

* @copyright Copyright 2018 On Semiconductor
*/

#include "Connector.h"

using namespace std;
using namespace rapidjson;

// The following variable is "strictly" used only for windows build.
// since windows does not support libevent handling of serial devices,
// the connector factory will create a seperate thread for serial read and
// after reading a message will write it to a push socket
// serial connector read will read the paltform message from pull socket
#define SERIAL_SOCKET_ADDRESS "tcp://127.0.0.1:5567"
// #define WINDOWS_SERIAL_TESTING;

// @f constructor
// @b
//
SerialConnector::SerialConnector()
{
    cout<<"Creating a Serial Connector Object"<<endl;
#ifdef WINDOWS_SERIAL_TESTING
    context_ = new(zmq::context_t);
    // creating the push socket and binding to a address
    write_socket_ = new zmq::socket_t(*context_,ZMQ_PUSH);
    write_socket_->bind(SERIAL_SOCKET_ADDRESS);
    // creating the pull socket and connecting it to the PUSH socket
    read_socket_ = new zmq::socket_t(*context_,ZMQ_PULL);
    read_socket_->connect(SERIAL_SOCKET_ADDRESS);
#endif

}

// @f open
// @b gets the port name and opens, if fail return false and if success return true
//
// arguments:
//  IN: string port name
//
//  OUT: true, if device is connected
//       false, if device is not connected
//
//
bool SerialConnector::open(std::string serial_port_name)
{
    // TODO [prasanth] add platform socket inside the class declaration
    int i;
    struct sp_port **ports;
    sp_return port_list_error = sp_list_ports(&ports);
    std::string usb_keyword;
    std::string platform_port_name;
    // TODO [Prasanth] : The following TESTING section will look for a string pattern and try
    // to open those that match. This will reduce the time taken for detecing the platform
#define TESTING
#ifdef TESTING
#ifdef __APPLE__
    usb_keyword = "usb";
#elif __linux__
    usb_keyword = "USB";
#elif _WIN32
    usb_keyword = "COM";
#endif
#endif
    if (port_list_error == SP_OK) {
        for (i = 0; ports[i]; i++) {
            std::string port_name = sp_get_port_name(ports[i]);
            size_t found = port_name.find(usb_keyword);
            if (found!=std::string::npos) {
                platform_port_name = port_name;
                error = sp_get_port_by_name(platform_port_name.c_str(), &platform_socket_);
            }
        }
        sp_free_port_list(ports);
    }
    else {
        return false;
    }
    if (error == SP_OK) {
        cout << "Opening the port "<<platform_port_name<<endl;
        error = sp_open(platform_socket_, SP_MODE_READ_WRITE);
        if (error == SP_OK) {
            cout << "SERIAL PORT OPEN SUCCESS: " << serial_port_name << endl;
            sp_set_stopbits(platform_socket_,1);
            sp_set_bits(platform_socket_,8);
            sp_set_rts(platform_socket_,SP_RTS_OFF);
            sp_set_baudrate(platform_socket_,115200);
            sp_set_dtr(platform_socket_,SP_DTR_OFF);
            sp_set_parity(platform_socket_,SP_PARITY_NONE );
            sp_set_cts(platform_socket_,SP_CTS_IGNORE );
#ifdef WINDOWS_SERIAL_TESTING
            windows_thread = new thread(&SerialConnector::windowsPlatformReadHandler,this);
            // adding timeout for the serial read during the platform ID session
            // This timeout is mainly used for USB-PD Load Board
            serial_wait_timeout_ = 250;
#endif
            // getting the platform
            string cmd = "{\"cmd\":\"request_platform_id\"}";
            // TODO [prasanth]: Take the following into a seperate thread
            // The following section will block other functionalities if it detects a port and waits for platform id
            // 5 Retries for parsing the platform ID
            // If valid Platform ID is read from platform, adds the platform handler to the event
            // If negative, then scans the port and sends the platform ID
            // This is essential for platforms like USB_PD Load Board that takes 5 second to boot
            for (int i =0 ; i <=5; i++) {
                sleep(1);
                send(cmd);
                // making the serial thread processing to start reading from the port
                consumed_ = true;
                producer_consumer_.notify_one();
                string read_message;
                // the read is done twice here based on our messaging architecture
                // we need to have the platform id to identify "spyglass" platforms
                // on sending a command to the platform, the platform command dispatcher
                // will send an acknowledgement followed by the notification
                // wiki link:
                // https://ons-sec.atlassian.net/wiki/spaces/SPYG/pages/6815754/Platform+Command+Dispatcher
                read(read_message);
                if(getPlatformID(read_message)) {
                    serial_wait_timeout_ = 0;
                    return true;
                }
                read(read_message);
                if(getPlatformID(read_message)) {
                    serial_wait_timeout_ = 0;
                    return true;
                }
            }
        }
    }
    return false;
}

// @f close
// @b closes the serial port connection
bool SerialConnector::close()
{
  sp_close(platform_socket_);
  return true;
}

// @f read
// @b reads from the connected device
//
// arguments:
//  IN:
//
//  OUT: std::string read message
//
//
bool SerialConnector::read(string &notification)
{
    // [TODO] [prasanth] : needs better code for reading from serial port
    //  copied this section from current HCS

    // setting the libserial port events
#ifndef WINDOWS_SERIAL_TESTING
    sp_new_event_set(&ev);
    sp_add_port_events(ev, platform_socket_, SP_EVENT_RX_READY);

    vector<char> response;
    sp_return error;
    char temp = '\0';
    while(temp != '\n') {
        temp = '\0';
        sp_wait(ev, 250);
        error = sp_nonblocking_read(platform_socket_,&temp,1);
        if(error <= 0) {
            cout<<"Platform Disconnected\n";
            dealer_id_.clear();
            return false;
        }
        if(temp !='\n' && temp!= NULL) {
            response.push_back(temp);
        }
    }
    if(!response.empty()) {
        string read_message(response.begin(),response.end());
        notification = read_message;
        cout << "Rx'ed message : "<<notification<<endl;
        response.clear();
        return true;
    }
    return false;
#else
    // This section is only for windows
    // it uses producer consumer model to read from a pull socket
    unique_lock<mutex> lock_condition_variable(locker_);
    this->producer_consumer_.wait(lock_condition_variable, [this]{return produced_;});
    zmq::pollitem_t items = {*read_socket_, 0, ZMQ_POLLIN, 0 };
    zmq::poll (&items,1,10);
    if(items.revents & ZMQ_POLLIN) {
        notification = s_recv(*read_socket_);
        cout << "Rx'ed message : "<<notification<<endl;
        if(notification == "Platform_Disconnected") {
            return false;
        }
        else {
            produced_ = false;
            consumed_ = true;
            producer_consumer_.notify_one();
            return true;
        }
    }
    unsigned int     zmq_events;
    size_t           zmq_events_size  = sizeof(zmq_events);
    read_socket_->getsockopt(ZMQ_EVENTS, &zmq_events, &zmq_events_size);
#endif
}

// @f write
// @b writes to the connected device
//
// arguments:
//  IN: string to be written
//
//  OUT: true if success and false if fail
//
//
bool SerialConnector::send(std::string message)
{
    // adding a new line to the message to be sent, since platform uses gets and it needs a newline
    message += "\n";
    sp_flush(platform_socket_,SP_BUF_BOTH);
    if(sp_blocking_write(platform_socket_,(void *)message.c_str(),message.length(),5) >=0) {
        cout << "write success "<<message<<endl;
        return true;
    }
    return false;
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
int SerialConnector::getFileDescriptor()
{
#ifndef WINDOWS_SERIAL_TESTING
    int file_descriptor ;
    sp_get_port_handle(platform_socket_,&file_descriptor);
#else
    unsigned long long int file_descriptor;
    size_t file_descriptor_size = sizeof(file_descriptor);
    read_socket_->getsockopt(ZMQ_FD,&file_descriptor,
        &file_descriptor_size);
#endif
    return file_descriptor;
}

// @f windowsPlatformReadHandler
// @b reads from the serial port
//
// arguments:
//  IN:
//
//  OUT: file descriptor
//
//
void SerialConnector::windowsPlatformReadHandler()
{
    // Producer Consumer model is used here.
    // This is to ensure the synchoronous activity between push and pull sockets
    unique_lock<mutex> lock_condition_variable(locker_);
    while(true) {
        this->producer_consumer_.wait(lock_condition_variable, [this]{return consumed_;});
        sp_new_event_set(&ev);
        sp_add_port_events(ev, platform_socket_, SP_EVENT_RX_READY);
        vector<char> response;
        sp_return error;
        char temp = '\0';
        while(temp != '\n') {
            temp = '\0';
            sp_wait(ev,serial_wait_timeout_);
            error = sp_nonblocking_read(platform_socket_,&temp,1);
#ifdef _WIN32
            if(error <= -1) {
#else
            if(error <= 0) {
#endif
                // [TODO] [prasanth] think of better way to have serial disconnect logic
                // Platform disconnect logic. Depends on the read and sp_wait
                cout<<"Platform Disconnected\n";
                s_send(*write_socket_,"Platform_Disconnected");
                // Signaling the ZMQ PULL thread that the data is produced
                produced_ = true;
                consumed_ = false;
                producer_consumer_.notify_one();
                // close the serial port
                sp_close(platform_socket_);
                return;
            }
            if(temp !='\n' && temp!= NULL) {
                response.push_back(temp);
            }
        }
        if(!response.empty()) {
            string read_message(response.begin(),response.end());
            response.clear();
            s_send(*write_socket_,read_message);
            produced_ = true;
            consumed_ = false;
            producer_consumer_.notify_one();
        }
    }
}

// @f getPlatformID
// @b parses the IN parameter and checks for the platform ID
//
// arguments:
//  IN: message to parsed
//
//  OUT: true if platform ID exists, false if it does not
//
//
bool SerialConnector::getPlatformID(std::string message)
{
    Document platform_command;
    if (platform_command.Parse(message.c_str()).HasParseError()) {
        return false;
    }
    if (!(platform_command.HasMember("notification"))) {
        return false;
    }
    if (platform_command["notification"]["payload"].HasMember("verbose_name")) {
        dealer_id_ = platform_command["notification"]["payload"]["verbose_name"].GetString();
        platform_uuid_ = platform_command["notification"]["payload"]["platform_id"].GetString();
        return true;
    }
}
