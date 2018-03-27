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

// @f constructor
// @b
//
SerialConnector::SerialConnector()
{
    cout<<"Creating a Serial Connector Object"<<endl;
    // context_ = new(zmq::context_t);

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
    sp_return error = sp_list_ports(&ports);
    if (error == SP_OK) {
        for (i = 0; ports[i]; i++) {
            std::string port_name = sp_get_port_name(ports[i]);
            // cout<<"Found port: "<<port_name<<endl;
            size_t found = port_name.find(usb_keyword);
            if (found!=std::string::npos) {
                cout << "'platform found at: " << port_name << '\n';
                platform_port_name = port_name;
                error = sp_get_port_by_name(platform_port_name.c_str(), &platform_socket_);
            }
        }
        sp_free_port_list(ports);
    }
    else {
        cout<<"No serial devices detected\n";
        return false;
    }
    if (error == SP_OK) {
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
            return true;
        }
        else {
            cout << "No platform detected"<< endl;
        }
    }
    return false;
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
    sp_new_event_set(&ev);
    sp_add_port_events(ev, platform_socket_, SP_EVENT_RX_READY);

    std::vector<char> response;
    sp_return error;
    char temp = '\0';
    while(temp != '\n') {
        sp_wait(ev, 250);
        error = sp_nonblocking_read(platform_socket_,&temp,1);
        if(error <= 0) {
            cout<<"Platform Disconnected\n";
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
    sp_flush(platform_socket_,SP_BUF_BOTH);
    if(sp_nonblocking_write(platform_socket_,(void *)message.c_str(),message.length()) >=0) {
    // if (i>=0) {
        // cout << "write success "<<i <<endl;
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
    int file_descriptor ;
    sp_get_port_handle(platform_socket_,&file_descriptor);
    cout << "file descriptor "<<file_descriptor<<endl;
    return file_descriptor;
}
