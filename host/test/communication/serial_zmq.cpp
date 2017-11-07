/*!
 *  Simple HostControllerService Code
 *  This democ code uses libserialport + zmq library
 *  Feature functionality is cross-platform
 *  Current Implementation is tested on Linux and Windows 64bit
 *  Needs testing on Windows 32bit
 */

#include <iostream>
#include <libserialport.h>
#include <stdio.h>
#include <stdlib.h>
#include <vector>
#include <string>
#include <functional>
#include <thread>
#include <mutex>
#include <unistd.h>
#include <event2/event.h>
#include <condition_variable>

#include "ArduinoJson/ArduinoJson.h"
#include "zmq.hpp"
#include "zmq_addon.hpp"
#include "zhelpers.hpp"

using namespace std;

mutex lock_serial_;
struct sp_port *port;
struct sp_event_set *ev;
sp_return error;
const char *desired_port;
vector<char> response;
bool start;


/*!
 * \brief:
 * servicehandle: reports requests coming from HostControllerClient to platform board
 */

void servicehandle(evutil_socket_t fd ,short what,void* service) {

  zmq::socket_t *socket = (zmq::socket_t *)service;

  s_recv(*socket);
  string cmd = s_recv(*socket);
  lock_serial_.lock();
  //cout << "Received String " <<cmd <<endl;
  error = sp_blocking_write(port,(void *)cmd.c_str(),cmd.length(),5);
  // cout << "service handle exit " <<endl;
  lock_serial_.unlock();
}


/*!
 * \brief:
 * platformhandle: reports the notification from platform to hostcontrollerclient
 */
void platformhandle(zmq::socket_t* platform) {

  char byte_buff;
  cout << "platform handler started " <<endl;

  sp_new_event_set(&ev);
  sp_add_port_events(ev, port, SP_EVENT_RX_READY);

  while(1) {
    sp_wait(ev, 0);
    sp_blocking_read_next(port,(void *)&byte_buff,1,0);

    if(byte_buff!= '\n' && byte_buff != '\0') {

      response.push_back(byte_buff);
    } else if(byte_buff == '\n') {

      string newString(response.begin(),response.end());
      cout << "Received Message = " << newString  << endl;
      s_sendmore(*platform,"ONSEMI");
      s_send(*platform,newString);
      cout << "send done " <<endl;
      response.clear();
    } else {
      cout << "cout returning else " <<endl;
    }
    byte_buff='\0';
  }
}

/*!
 * \brief:
 * setup_serial_port: serial port configuration to match the platform
 */
void setup_serial_port() {

  error = sp_set_stopbits(port,1);

  if(error == SP_OK ) {

    cout << "Stop Bit init success" <<endl;
  }

  error = sp_set_bits(port,8);

  if(error == SP_OK ) {

    cout << "data Bit init success" <<endl;
  }

  error = sp_set_rts(port,SP_RTS_OFF);
  if(error == SP_OK ) {

    cout << "Rts Bit off success" <<endl;
  }

  error = sp_set_baudrate(port,9600);
  if(error == SP_OK ) {

    cout << "Baud Rate init success" <<endl;
  }

  error= sp_set_dtr(port,SP_DTR_OFF);
  if(error == SP_OK ) {

    cout << "DTR Bit off success" <<endl;
  }

  error= sp_set_parity(port,SP_PARITY_NONE );
  if(error == SP_OK ) {

    cout << "Parity Bit none success" <<endl;
  }

  error = sp_set_cts(port,SP_CTS_IGNORE );
  if(error == SP_OK ) {

    cout << "CTS Bit Ignore success" <<endl;
  }

}

int main() {

  zmq::context_t context(1);
  zmq::socket_t command(context,ZMQ_ROUTER);
  command.bind("tcp://*:5564");

  #ifndef _WIN32
  int sockService=0;
  size_t size_sockService = sizeof(sockService);
  #else
  unsigned long long int sockService=0;
  size_t size_sockService = sizeof(sockService);
  #endif

  zmq::socket_t platform(context,ZMQ_PUB);
  platform.bind("tcp://*:5563");

  command.getsockopt(ZMQ_FD,&sockService,&size_sockService);

  #ifndef _WIN32
  error = sp_get_port_by_name("/dev/ttyUSB0",&port);
  #else
  error = sp_get_port_by_name("COM7",&port);
  #endif

  if(error == SP_OK) {
    error = sp_open(port, SP_MODE_READ_WRITE);
    if(error == SP_OK) {
      cout << "Serial Port OPEN Success "<<endl;
    } else {
      cout << "SERIAL PORT OPEN FAILED "<<endl;
    }
  } else {
    cout << "Port not present "<<endl;
  }

  setup_serial_port();
  thread t2(platformhandle,&platform);

  struct event_base *base = event_base_new();
  struct event *event = event_new(base, sockService ,
    EV_READ | EV_WRITE | EV_ET | EV_PERSIST ,
    servicehandle,(void *)&command);

    if (event_base_set(base,event) <0 )
    cout <<"Event BASE SET SERVICE FAILED "<<endl;

    if(event_add(event,NULL) <0 )
    cout<<"Event SERVICE ADD FAILED "<<endl;
    event_base_dispatch(base);
    t2.join();
    return 0;
  }
