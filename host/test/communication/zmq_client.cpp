/*!
 * Simple HostControllerClient Implementation
 * Cross-platform handling capability
 * Tested on Linux and Windows 64bit
 * Needs testing on Windows 32bit
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

#ifdef _WIN32
#include <windows.h>
#endif


#include "ArduinoJson/ArduinoJson.h"
#include "zmq.hpp"
#include "zmq_addon.hpp"
#include "zhelpers.hpp"

using namespace std;


// * Counter to keep track of valid and invalid jason
int valid_json_, invalid_json_;


/*!
 * \brief : checks whether the received json over ZMQ_SUB is valid or not
 *          and increment the respective counter
 */
void verifyJson(string received) {

  if(received.compare("")) {
    StaticJsonBuffer<2000> jsonBuffer;
    JsonObject& root = jsonBuffer.parseObject(received.c_str());

    if(root.success()) {

      valid_json_+=1;
    } else {

      invalid_json_+=1;
    }
  }
}

int main() {

  valid_json_=invalid_json_=0;
  zmq::context_t context(1);
  zmq::socket_t command(context,ZMQ_DEALER);
  zmq::socket_t notify(context,ZMQ_SUB);

  command.connect("tcp://127.0.0.1:5564");
  int i = 1;
  #ifdef _WIN32
  s_set_id(command, (intptr_t)&i);
  #else
  s_set_id(command);
  #endif

  notify.connect("tcp://127.0.0.1:5563");
  notify.setsockopt(ZMQ_SUBSCRIBE,"ONSEMI",strlen("ONSEMI"));

  string cmd = "{\"cmd\":\"request_platform_id\",\"Host_OS\":\"Linux\"}\n";
  while(1) {

    s_send(command,cmd);
    s_recv(notify);
    string received = s_recv(notify);
    verifyJson(received);
    cout << "Valid Json Count = " << valid_json_ <<endl;
    cout << "InValid Json Count = " << invalid_json_ <<endl;

    #ifdef _WIN32
      Sleep(1000);
    #else
      sleep(1);
    #endif
  }
}
