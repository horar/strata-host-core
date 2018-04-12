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
#include "SerialPortConfiguration.h"

using namespace std;
using namespace rapidjson;

// [HACK] The following varaible is used to enable the hack support for ST EVAL boards in
// windows
// 1 - enabled
// 0 - disabled the hack, can support other platforms (Tested it with USB-PD and load board)
#define ST_EVAL_BOARD_SUPPORT_ENABLED 1

// The following variable is "strictly" used only for windows build.
// since windows does not support libevent handling of serial devices,
// the connector factory will create a seperate thread for serial read and
// after reading a message will write it to a push socket
// serial connector read will read the paltform message from pull socket
#define SERIAL_SOCKET_ADDRESS "tcp://127.0.0.1:5567"

// @f constructor
// @b
//
SerialConnector::SerialConnector()
{
    cout<<"Creating a Serial Connector Object"<<endl;
#ifdef _WIN32
    context_ = new(zmq::context_t);
    // creating the push socket and binding to a address
    write_socket_ = new zmq::socket_t(*context_,ZMQ_PUSH);
    write_socket_->bind(SERIAL_SOCKET_ADDRESS);
    // creating the pull socket and connecting it to the PUSH socket
    read_socket_ = new zmq::socket_t(*context_,ZMQ_PULL);
    read_socket_->connect(SERIAL_SOCKET_ADDRESS);
#endif
}

bool SerialConnector::isPlatformAvailable()
{
    // TODO [prasanth] add platform socket inside the class declaration
    struct sp_port **ports;
    sp_return port_list_error = sp_list_ports(&ports);
    std::string usb_keyword;
    // TODO [Prasanth] : The following TESTING section will look for a string pattern and try
    // to open those that match. This will reduce the time taken for detecing the platform
#define TESTING
#ifdef TESTING
#ifdef __APPLE__
    usb_keyword = "usb";
#elif __linux__
    usb_keyword = "ACM";
#elif _WIN32
    usb_keyword = "COM";
#endif
#endif
    if (port_list_error == SP_OK) {
        for (int i = 0; ports[i]; i++) {
            platform_port_name_ = sp_get_port_name(ports[i]);
            size_t found = platform_port_name_.find(usb_keyword);
            if (found!=std::string::npos) {
                error = sp_get_port_by_name(platform_port_name_.c_str(), &platform_socket_);
                if(error == SP_OK){
                    cout<<"found port "<<found<<" "<<platform_port_name_;
                    sp_free_port_list(ports);
                    return true;
                }
            }
        }
        sp_free_port_list(ports);
        return false;
    }
    else {
        sp_free_port_list(ports);
        return false;
    }
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
    if (isPlatformAvailable()) {
        error = sp_open(platform_socket_, SP_MODE_READ_WRITE);
        if (error == SP_OK) {
            cout << "SERIAL PORT OPEN SUCCESS: " << platform_port_name_ << endl;
            serialport_settings serialport;
            sp_set_stopbits(platform_socket_,serialport.stop_bit_);
            sp_set_bits(platform_socket_,serialport.data_bit_);
            sp_set_rts(platform_socket_,serialport.RTS_setting_);
            sp_set_baudrate(platform_socket_,serialport.baudrate_);
            sp_set_dtr(platform_socket_,serialport.DTR_setting_);
            sp_set_parity(platform_socket_,serialport.parity_setting_ );
            sp_set_cts(platform_socket_,serialport.cts_setting_);

#ifdef _WIN32
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
    //close();
    return false;
}

// @f close
// @b closes the serial port connection
bool SerialConnector::close()
{
    sp_close(platform_socket_);
    platform_port_name_.clear();
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
#ifndef _WIN32
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
    // unique_lock<mutex> lock_condition_variable(locker_);
    zmq::pollitem_t items = {*read_socket_, 0, ZMQ_POLLIN, 0 };
    zmq::poll (&items,1,10);
    if(items.revents & ZMQ_POLLIN) {
        notification = s_recv(*read_socket_);
        cout << "Rx'ed message : "<<notification<<endl;
        if(notification == "Platform_Disconnected") {
            return false;
        }
        else {
            producer_consumer_.notify_one();
            return true;
        }
    }
    notification="";
    producer_consumer_.notify_one();
    unsigned int     zmq_events;
    size_t           zmq_events_size  = sizeof(zmq_events);
    read_socket_->getsockopt(ZMQ_EVENTS, &zmq_events, &zmq_events_size);
    return true;
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
    if(sp_blocking_write(platform_socket_,(void *)message.c_str(),message.length(),10) >=0) {
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
#ifndef _WIN32
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
    int number_of_misses = 0;
    sp_new_event_set(&ev);
    sp_add_port_events(ev, platform_socket_, SP_EVENT_RX_READY);
    while(true) {
        this->producer_consumer_.wait_for(lock_condition_variable,chrono::milliseconds(200), [this]{return consumed_;});
        vector<char> response;
        sp_return error;
        char temp = '\0';
        while(temp != '\n') {
            temp = '\0';
            sp_return serial_wait_ = sp_wait(ev,0);
            error = sp_nonblocking_read(platform_socket_,&temp,1);
            if(error <= -1) {
                // [TODO] [prasanth] think of better way to have serial disconnect logic
                // Platform disconnect logic. Depends on the read and sp_wait
                cout<<"Platform Disconnected\n";
                s_send(*write_socket_,"Platform_Disconnected");
                // close the serial port
                close();
                return;
            }
            if(error == 0) {
                sleep(0.02);
// [HACK] [todo] [prasanth] : the following if stetment is required for only for ST eval boards in windows
// On disconnecting the ST board from windows, the read() does not return negative value, instead returns zero.
// We re counting the number of zeros and if it has 10 (2Sseconds), we are checking if it is motor board
// and if yes we will write to the platform. The write will fail if the board is disconnected
#if ST_EVAL_BOARD_SUPPORT_ENABLED
                number_of_misses++;
                if(number_of_misses == 10 && !isPlatformConnected()) {
                    cout<<"Platform Disconnected\n";
                    s_send(*write_socket_,"Platform_Disconnected");
                    // close the serial port
                    close();
                    return;
                }
#endif
            }
            if(temp !='\n' && temp!= NULL ) {
                response.push_back(temp);
                number_of_misses = 0;
            }
        }
        if(!response.empty()) {
            string read_message(response.begin(),response.end());
            response.clear();
            s_send(*write_socket_,read_message);
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
    cout<<"platform id message "<<message<<endl;
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
    return false;
}

// @f isPlatformConnected
// @b checks if platform is still connected by writing to it
//
// arguments:
//  IN:
//
//  OUT: true if platform ID exists, false if it does not
//
//
bool SerialConnector::isPlatformConnected ()
{
    string cmd = "{\"cmd\":\"request_platform_id\"}";
    if(send(cmd)) {
        return true;
    }
    else {
      return false;
    }
}
