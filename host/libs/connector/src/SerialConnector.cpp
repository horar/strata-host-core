/**
******************************************************************************
* @file serial-connector [connector]
* @author Prasanth Vivek
* $Rev: 1 $
* $Date: 2018-03-14
* @brief Serial connector code provides abstraction of the libserial port for
    opening, closing, reading and writing to/from a serial port
******************************************************************************

* @copyright Copyright 2018 ON Semiconductor
*/

#include "SerialConnector.h"
#include "SerialPortConfiguration.h"
#include "zhelpers.hpp"

using namespace std;
using namespace rapidjson;

// [HACK] The following varaible is used to enable the hack support for ST EVAL boards in
// windows
// 1 - enabled
// 0 - disabled the hack, can support other platforms (Tested it with USB-PD and load board)
#define ST_EVAL_BOARD_SUPPORT_ENABLED 0

// The following variable is "strictly" used only for windows build.
// since windows does not support libevent handling of serial devices,
// the connector factory will create a seperate thread for serial read and
// after reading a message will write it to a push socket
// serial connector read will read the paltform message from pull socket
// @ref 1) under "KNOWN BUGS/HACKS" section in Connector.h for more details
#define SERIAL_SOCKET_ADDRESS "tcp://127.0.0.1:5567"

// windows enablement requires sleep to avoid high CPU usgae, since sp_wait that waits
// for read event always returns successfully even if there is no data to read.
// @ref 5) under "KNOWN BUGS/HACKS" section in Connector.h for more details
const int SERIAL_READ_SLEEP_MS = 50;

// Currently the Strata platforms are identified automatically using Platform_ID notification
// and this is done synchoronously. Increasing the number of retries to 15 is usefull for
// 4port since it has lot of periodic notifications and it affects the discovery procedure
const int PLATFORM_ID_RETRY = 15;

// @f constructor
// @b
//
SerialConnector::SerialConnector() : Connector()
{
    CONNECTOR_DEBUG_LOG("%s Creating a Serial Connector Object\n", "SerialConnector");
#ifdef _WIN32
    context_ = new (zmq::context_t);
    // creating the push socket and binding to a address
    write_socket_ = new zmq::socket_t(*context_, ZMQ_PUSH);
    write_socket_->bind(SERIAL_SOCKET_ADDRESS);
    // creating the pull socket and connecting it to the PUSH socket
    read_socket_ = new zmq::socket_t(*context_, ZMQ_PULL);
    read_socket_->connect(SERIAL_SOCKET_ADDRESS);
#endif
    CONNECTOR_DEBUG_LOG("%s Creating thread for serial port scan\n", "SerialConnector");
    open_platform_thread_ = new thread(&SerialConnector::openPlatform, this);
}

SerialConnector::~SerialConnector()
{
    // TODO: cleanup...
}

// @f isPlatformAvailable
// @b
//
void SerialConnector::openPlatform()
{
    // TODO [prasanth] add platform socket inside the class declaration
    struct sp_port **ports;

    CONNECTOR_DEBUG_LOG("%s In openPlatform thread\n", "SerialConnector");

    while (true) {
        std::this_thread::sleep_for(std::chrono::milliseconds(2000));
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
            for (int i = 0; ports[i]; i++) {
                platform_port_name = sp_get_port_name(ports[i]);
                size_t found = platform_port_name.find(usb_keyword);
                if (found != std::string::npos) {
                    CONNECTOR_DEBUG_LOG("opening port %s\n", platform_port_name.c_str());
                    if (open(platform_port_name)) {
                        sp_free_port_list(ports);
                        // the flag that is being used by hcs to detect if spyglass platform is
                        // connected
                        setPlatformConnected(true);
                        return;
                    }  // end if - open platform
                }      // end if - string pattern match
            }          // end for - list of ports detected
            sp_free_port_list(ports);
        }  // end if - port list error
    }      // end while
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
bool SerialConnector::open(const std::string &serial_port_name)
{
    sp_return error;
    error = sp_get_port_by_name(serial_port_name.c_str(), &platform_socket_);
    if (error != SP_OK) {
        return false;
    }
    error = sp_open(platform_socket_, SP_MODE_READ_WRITE);
    if (error == SP_OK) {
        CONNECTOR_DEBUG_LOG("SERIAL PORT OPEN SUCCESS: %s\n", serial_port_name.c_str());
        serial_port_settings serialport;
        sp_set_stopbits(platform_socket_, (int)SERIAL_PORT_CONFIGURATION::STOP_BIT);
        sp_set_bits(platform_socket_, (int)SERIAL_PORT_CONFIGURATION::DATA_BIT);
        sp_set_baudrate(platform_socket_, (int)SERIAL_PORT_CONFIGURATION::BAUD_RATE);
        CONNECTOR_DEBUG_LOG("SERIAL PORT BAUD RATE: %d\n",
                            (int)SERIAL_PORT_CONFIGURATION::BAUD_RATE);
        sp_set_rts(platform_socket_, serialport.rts_);
        sp_set_dtr(platform_socket_, serialport.dtr_);
        sp_set_parity(platform_socket_, serialport.parity_);
        sp_set_cts(platform_socket_, serialport.cts_);
        sp_flush(platform_socket_, SP_BUF_BOTH);

#ifdef _WIN32
        // @ref 1) under "KNOWN BUGS/HACKS" section in Connector.h for more details
        windows_thread_ = new thread(&SerialConnector::windowsPlatformReadHandler, this);
        // adding timeout for the serial read during the platform ID session
        // This timeout is mainly used for USB-PD Load Board
        serial_wait_timeout_ = 250;
#endif
        // getting the platform
        string cmd = "{\"cmd\":\"request_platform_id\"}";
        send(cmd);
        // TODO [prasanth]: Take the following into a seperate thread
        // The following section will block other functionalities if it detects a port and waits for
        // platform id 5 Retries for parsing the platform ID If valid Platform ID is read from
        // platform, adds the platform handler to the event If negative, then scans the port and
        // sends the platform ID This is essential for platforms like USB_PD Load Board that takes 5
        // second to boot
        for (int i = 0; i <= PLATFORM_ID_RETRY; i++) {
            // sleep for 50 milliseconds before reading from the platform
            // This sleep time is proportional to the time taken for detecting the platforms
            std::this_thread::sleep_for(std::chrono::milliseconds(SERIAL_READ_SLEEP_MS));
            // making the serial thread processing to start reading from the port
            producer_consumer_.notify_one();
            string read_message;
            // the read is done twice here based on our messaging architecture
            // we need to have the platform id to identify "spyglass" platforms
            // on sending a command to the platform, the platform command dispatcher
            // will send an acknowledgement followed by the notification
            // wiki link:
            // https://ons-sec.atlassian.net/wiki/spaces/SPYG/pages/6815754/Platform+Command+Dispatcher
            // // @ref 2) in KNOWN BUGS/HACKS in Connector.h
            read(read_message);
            if (getPlatformID(read_message)) {
                serial_wait_timeout_ = 0;
                return true;
            }
            read(read_message);
            if (getPlatformID(read_message)) {
                serial_wait_timeout_ = 0;
                return true;
            }
        }
    }
    sp_close(platform_socket_);
    return false;
}

// @f close the serial port
// @b closes the serial port connection and then sans and opens spyglass powered platforms
bool SerialConnector::close()
{
    sp_close(platform_socket_);
    setPlatformConnected(false);
    open_platform_thread_->join();
    delete open_platform_thread_;
    open_platform_thread_ = new thread(&SerialConnector::openPlatform, this);
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
    sp_new_event_set(&event_);
    sp_add_port_events(event_, platform_socket_, SP_EVENT_RX_READY);

    vector<char> response;
    sp_return error;
    char temp = '\0';
    while (temp != '\n') {
        temp = '\0';
        sp_wait(event_, 250);
        error = sp_nonblocking_read(platform_socket_, &temp, 1);

        if (error < 0) {
            cout << "error number " << error << endl;
            CONNECTOR_DEBUG_LOG("Platform Disconnected:%c\n", temp);
            setDealerID(std::string());
            return false;
        }
        if (temp != '\n' && temp != '\0') {
            response.push_back(temp);
        }
    }
    if (!response.empty()) {
        string read_message(response.begin(), response.end());
        notification = read_message;
        // LOG_DEBUG(DEBUG,"Rx'ed message : %s\n",notification.c_str());
        response.clear();
        return true;
    }
    return true;
#else
    // @ref 1) under "KNOWN BUGS/HACKS" section in Connector.h for more details
    // This section is only for windows
    // it uses producer consumer model to read from a pull socket
    // unique_lock<mutex> lock_condition_variable(locker_);
    zmq::pollitem_t items = {*read_socket_, 0, ZMQ_POLLIN, 0};
    zmq::poll(&items, 1, 10);
    if (items.revents & ZMQ_POLLIN) {
        // LOG_DEBUG(DEBUG,"Rx'ed message : %s\n",notification.c_str());
        if (false == s_recv(*read_socket_, notification) ||
            notification == "Platform_Disconnected") {
            return false;
        } else {
            producer_consumer_.notify_one();
            return true;
        }
    }
    notification = "";
    producer_consumer_.notify_one();
    unsigned int zmq_events;
    size_t zmq_events_size = sizeof(zmq_events);
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
bool SerialConnector::send(const std::string &message)
{
    // adding a new line to the message to be sent, since platform uses gets and it needs a newline
    if (sp_blocking_write(platform_socket_, (void *)message.c_str(), message.length(), 10) >= 0) {
        // [prasanth]: Platform uses new line as delimiter while reading. Hence sending a new line
        // after message
        sp_blocking_write(platform_socket_, "\n", 1, 1);
        CONNECTOR_DEBUG_LOG("write success %s\n", message.c_str());
        return true;
    }
    return false;
}

int SerialConnector::getFileDescriptor()
{
#ifndef _WIN32
    int file_descriptor;
    sp_get_port_handle(platform_socket_, &file_descriptor);
#else
    unsigned long long int file_descriptor;
    size_t file_descriptor_size = sizeof(file_descriptor);
    read_socket_->getsockopt(ZMQ_FD, &file_descriptor, &file_descriptor_size);
#endif
    return static_cast<bool>(file_descriptor);
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
// @ref 1) under "KNOWN BUGS/HACKS" section in Connector.h for more details
void SerialConnector::windowsPlatformReadHandler()
{
#ifdef _WIN32
    // Producer Consumer model is used here.
    // This is to ensure the synchoronous activity between push and pull sockets
    unique_lock<mutex> lock_condition_variable(locker_);
    int number_of_misses = 0;
    sp_new_event_set(&event_);
    sp_add_port_events(event_, platform_socket_, SP_EVENT_RX_READY);
    CONNECTOR_DEBUG_LOG("Thread starts\n", 0);
    while (true) {
        // [prasanth] : inducing a sleep for 100ms before read or read after getting signalled from
        // pull socket 200ms timeout results in merging two messages from platform

        // // @ref 5) under "KNOWN BUGS/HACKS" section in Connector.h for more details
        // // HACK
        // // Windows usb-pd 4 port two messages gets merged with each other if there is a delay of
        // 100ms
        // // commenting out the delay to support usb-pd 4 port
        // // But this will increase the cpu frequency
        // this->producer_consumer_.wait_for(lock_condition_variable,chrono::milliseconds(100),
        // [this]{return consumed_;});
        vector<char> response;
        sp_return error;
        char temp = '\0';

        while (temp != '\n') {
            temp = '\0';
            // @ref 3) under "KNOWN BUGS/HACKS" section in Connector.h for more details
            sp_return serial_wait_ = sp_wait(event_, 0);
            error = sp_nonblocking_read(platform_socket_, &temp, 1);
            if (error <= -1) {
                // [TODO] [prasanth] think of better way to have serial disconnect logic
                // Platform disconnect logic. Depends on the read and sp_wait
                CONNECTOR_DEBUG_LOG("Platform Disconnected\n", 0);
                s_send(*write_socket_, "Platform_Disconnected");
                return;
            }
            if (error == 0) {
                std::this_thread::sleep_for(std::chrono::milliseconds(SERIAL_READ_SLEEP_MS));
// [HACK] [todo] [prasanth] : the following if stetment is required only for ST eval boards in
// windows On disconnecting the ST board from windows, the read() does not return negative value,
// instead returns zero. We are counting the number of zeros and if it has 10 (2Sseconds), we are
// checking if it is motor board and if yes we will write to the platform. The write will fail if
// the board is disconnected

// @ref 4) under "KNOWN BUGS/HACKS" section in Connector.h for more details
#if ST_EVAL_BOARD_SUPPORT_ENABLED
                number_of_misses++;
                if (number_of_misses == 10 && !isPlatformConnected()) {
                    CONNECTOR_DEBUG_LOG("Platform Disconnected\n", 0);
                    s_send(*write_socket_, "Platform_Disconnected");
                    return;
                }
#endif
            }
            if (temp != '\n' && temp != '\0') {
                response.push_back(temp);
                number_of_misses = 0;
            }
        }
        if (!response.empty()) {
            string read_message(response.begin(), response.end());
            response.clear();
            s_send(*write_socket_, read_message);
        }
    }
#endif  // WIN32
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
    // TODO: Fix this code, it cannot handle garbled input or wrong syntax (Juraj)

    CONNECTOR_DEBUG_LOG("platform id message %s\n", message.c_str());
    Document platform_command;
    if (platform_command.Parse(message.c_str()).HasParseError()) {
        return false;
    }
    if (!(platform_command.HasMember("notification"))) {
        return false;
    }
    if (!(platform_command["notification"].IsObject())) {
        return false;
    }
    if (platform_command["notification"]["payload"].HasMember("class_id")) {
        setDealerID(platform_command["notification"]["payload"]["name"].GetString());
        setPlatformUUID(platform_command["notification"]["payload"]["class_id"].GetString());
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
bool SerialConnector::isPlatformConnected()
{
    string cmd("{\"cmd\":\"request_platform_id\"}");
    return send(cmd);
}
