/**
******************************************************************************
* @file client_comamnd_line
* @author Prasanth Vivek
* $Rev: 1 $
* $Date: 2018-02-07
* @brief Client[comamnd line] interaction with the platform through HCS
******************************************************************************

* @copyright Copyright 2018 On Semiconductor
*/
// Standard libraries
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <termios.h>
#include <inttypes.h>
#include <time.h>
#include <ArduinoJson.h>
#include <event2/event.h>
#include <cstdio>
#include <signal.h>

// zero mq Library
#include "zmq.hpp"
#include "zmq_addon.hpp"
#include "zhelpers.hpp"

#define DEBUG 1
#define BUF_SIZE 1024


extern int errno;
zmq::socket_t* client_socket;
zmq::context_t* client_context;
int client_number;
bool hcs_connected = false;
/**************************************************************************
 * Public Types
 **************************************************************************/
#define __EXTRACT_FILE(__path) (strrchr(__path, '/') ? strrchr(__path, '/') + 1 : __path)
#define __FLE __EXTRACT_FILE(__FILE__)

#define PDEBUG(__format, ...) do {\
	struct timespec __time;\
	clock_gettime(CLOCK_MONOTONIC, &__time);\
	printf("%ld.%09ld:%d <%s:%s(%d)>: ", __time.tv_sec, __time.tv_nsec,getpid(),__FLE,__func__,__LINE__ );\
	printf(__format,##__VA_ARGS__);\
	printf("\n");\
} while(0)

// Helper macro for stringifying JSON. The quotes for key and variable get passed down explicity
#define WRAPQUOTE(key)  #key
#define JSON_SINGLE_OBJECT(key, value)      "{" WRAPQUOTE(key) ":" WRAPQUOTE(value) "}"

// Internal error numbers for Host Controller Services
typedef enum {
    broadcast_hcs          = 0,
    available_platforms	   = 1,
	hcs_active			   = 2,
	command_does_not_exist = 10,
}CommandDispatcherMessages;

int target_voltage=5,target_pwm=1000,target_speed = 1000;  // global variables for target voltage and target PWM
std::string g_user_name;	// global variable for user name
std::string g_connected_platform ; // global variable to hold the connected platform uuid

std::string encoding_JSON()
{
	//  JSON buffer
	StaticJsonBuffer<100> json_buffer;
	//  JSON object
	JsonObject & sensor_object = json_buffer.createObject();
	sensor_object["Command"] = "Platform_ID";
	sensor_object["Host_OS"] = "Linux";
	//  JSON encoding
	std::string message;
	sensor_object.printTo(message);
	return message;
}

CommandDispatcherMessages stringHash(std::string command)
{
	if(command == "broadcast_hcs") {
		return broadcast_hcs;
	} else if(command == "available_platforms") {
		return available_platforms;
	} else if(command == "hcs_active") {
		return hcs_active;
	} else {
		return command_does_not_exist;
	}
}

// @f init
// @b initialises the zmq context and dealer socket for the client
//
// arguments:
//  IN: command line argument for the client socket address
//   open : client socket
//
//  OUT:
//   void
//
//  ERROR:
//    exits if socket cannot be opened or incorrect socket address
//
void socketInit(int argc, char *argv[])
{
	client_context = new(zmq::context_t);
	printf("Enter your user name : \n");
	std::cin>>g_user_name;
	client_socket = new zmq::socket_t(*client_context,ZMQ_DEALER);
	// setting the dealer id should be done before connecting to the router
	//client_socket->setsockopt(ZMQ_IDENTITY,g_user_name.c_str(),sizeof(g_user_name));
	client_socket->connect(argv[1]);
	printf("client connect \n");
	s_send(*client_socket,JSON_SINGLE_OBJECT("command","request_hcs_status"));
}

static void periodic_task(evutil_socket_t fd, short what, void* args)
{
	if(hcs_connected) {
		// char message_to_send[100];
		// sprintf(message_to_send,JSON_SINGLE_OBJECT("command","request_hcs_status"),client_number);
		// s_send(*client_socket,&message_to_send[0]);
		unsigned int     zmq_events;
	    size_t           zmq_events_size  = sizeof(zmq_events);
		client_socket->getsockopt(ZMQ_EVENTS,&zmq_events, &zmq_events_size);
	}
}

static void read_from_console(evutil_socket_t fd, short what, void* args)
{
	char s[2];
	int len = read(fd,&s,2);
	std::string message;

	StaticJsonBuffer<1000> json_buffer;
	JsonObject & json_object = json_buffer.createObject();
	JsonObject &payload_object = json_object.createNestedObject("payload");
	switch (s[0]) {
		case 'H':
		case 'h': 	printf("\n a - increase target voltage by 2V\n"
				  	" b - increase target pwm by 1000us\n"
					" q - quit\n");
					break;

		case 'A':
		case 'a':	printf("Increasing target voltage by 2V\n");
					target_voltage+=2;
					//  JSON object
					json_object["cmd"] = "set_target_voltage";
					json_object["target_voltage"] = target_voltage;
					//  JSON encoding
					json_object.printTo(message);
					s_send(*client_socket,message);
					break;

		case 'B':
		case 'b':	printf("Increasing target pwm by 1000us\n");
					target_pwm+=1000;
					//  JSON object
					json_object["cmd"] = "set_target_pwm";
					json_object["target_pwm"] = target_pwm;
					//  JSON encoding
					json_object.printTo(message);
					s_send(*client_socket,message);
					break;

		case 'C':
		case 'c':	printf("Increasing target pwm by 1000us\n");
					target_speed+=1000;
					//  JSON object
					json_object["cmd"] = "speed_input";
					payload_object["speed_target"] = target_speed;
					//  JSON encoding
					json_object.printTo(message);
					s_send(*client_socket,message);
					break;

		case 'D':
		case 'd':	json_object["cmd"] = "set_system_mode";
					payload_object["system_mode"] = "manual";
					json_object.printTo(message);
					s_send(*client_socket,message);
					break;

		case 'E':
		case 'e':	json_object["cmd"] = "set_system_mode";
					payload_object["system_mode"] = "automation";
					json_object.printTo(message);
					s_send(*client_socket,message);
					break;

		case 'Q':
		case 'q':
					printf("\n Exiting from the program\n");
					exit(0);
					break;

		default : 	printf("\n Enter valid options\n");
	}
	printf("\033[1;4;31m[%s<-%s]\033[0m:%s\n",g_connected_platform.c_str(),g_user_name.c_str(),message.c_str());
	unsigned int     zmq_events;
	size_t           zmq_events_size  = sizeof(zmq_events);
	client_socket->getsockopt(ZMQ_EVENTS,&zmq_events, &zmq_events_size);

}

std::string selectPlatform(JsonObject &json_object)
{
	int platform_index_selected;
	printf("#####################################\n");
	JsonArray& array = json_object["platforms"].asArray();
	for(int i = 0; i<array.size(); i++) {
		// std::cout<<i+1<<") "<<json_object["platforms"][i];
		std::string platform_verbose = json_object["platforms"][i]["verbose"];
		std::string platform_uuid = json_object["platforms"][i]["uuid"];
		std::string remote_status="local connect";
		if(json_object["platforms"][i]["remote"]) {
			remote_status = "remote connect";
		}
		printf("%d) %s[%s] with \033[1;4;31m%s\033[0m\n",i+1,platform_verbose.c_str(),platform_uuid.c_str(),remote_status.c_str());
	}
	printf("#####################################\n");
	printf("Enter the number to select your platform\n");
	std::cin>>platform_index_selected;
	//  JSON buffer
	StaticJsonBuffer<200> json_buffer;
	//  JSON object
	JsonObject & json_object_to_send = json_buffer.createObject();
	json_object_to_send["command"] = "platform_select";
	json_object_to_send["platform_uuid"] = json_object["platforms"][platform_index_selected-1]["verbose"];
	if(json_object["platforms"][platform_index_selected-1]["remote"]) {
		json_object_to_send["remote"] = "remote";
	}
	else {
		json_object_to_send["remote"] = "local";
	}
	// assiging the platform uuid to the global variable
	std::string connected_platform = json_object["platforms"][platform_index_selected-1]["verbose"];
	g_connected_platform = connected_platform;
	//  JSON encoding
	std::string message;
	json_object_to_send.printTo(message);
	return message;
}

void dispatchMessage(std::string read_message)
{
	// arduino json parsing
	StaticJsonBuffer < 5120 > json_buffer;
	JsonObject &received_json =
            json_buffer.parseObject(read_message);
	// get the cmd arguments
	// use enum here
	std::string command= received_json["command"];
	// char message_to_send[100];
	std::string message_to_send;
	// 	sprintf(message_to_send,JSON_SINGLE_OBJECT("command","request_hcs_status"),client_number);
	switch(stringHash(command)) {
		case broadcast_hcs: std::cout<<"\n print hello\n";
							break;
		case hcs_active:	//sprintf(message_to_send,JSON_SINGLE_OBJECT("command","request_available_platforms"));
							std::cout<< "message being send "<<JSON_SINGLE_OBJECT("command","request_available_platforms")<<std::endl;
							s_send(*client_socket,JSON_SINGLE_OBJECT("command","request_available_platforms"));
							PDEBUG("\033[1;4;31m[%s<-%s]\033[0m:%s\n",g_connected_platform.c_str(),g_user_name.c_str(),message_to_send.c_str());
							break;
		case available_platforms:
									message_to_send = selectPlatform(received_json);
									s_send(*client_socket,message_to_send);
									PDEBUG("\033[1;4;31m[%s<-%s]\033[0m:%s\n",g_connected_platform.c_str(),g_user_name.c_str(),message_to_send.c_str());
									hcs_connected = true;
									break;

	}
}

static void callbackServiceHandler(evutil_socket_t fd, short what, void* args)
{
	unsigned int     zmq_events;
    size_t           zmq_events_size  = sizeof(zmq_events);
	std::string read_message = s_recv(*client_socket);
	if(g_connected_platform.empty()) {
		std::cout << "[Read]: "<<read_message<<std::endl;
	} else {
		printf("\033[1;4;32m[%s->%s]\033[0m:%s\n",g_connected_platform.c_str(),g_user_name.c_str(),read_message.c_str());
	}
	dispatchMessage(read_message);
	client_socket->getsockopt(ZMQ_EVENTS,&zmq_events, &zmq_events_size);
}

int main(int argc, char *argv[])
{
	// initialize the socket
	socketInit(argc,argv);
	// get FD from client socket
	#ifndef _WIN32
	    int sockService=0;
	    size_t size_sockService = sizeof(sockService);
	#else
	    unsigned long long int sockService=0;
	    size_t size_sockService = sizeof(sockService);
	#endif
	client_socket->getsockopt(ZMQ_FD,&sockService,&size_sockService);
	// for some wierd reason the read callback didn't occur
	// so I added this getsockt for ZMQ_EVENTS and it occured
	unsigned int     zmq_events;
	size_t           zmq_events_size  = sizeof(zmq_events);
	client_socket->getsockopt(ZMQ_EVENTS,&zmq_events, &zmq_events_size);

	printf("\n"
			"#################################################\n"
			"Sample Host Program\n"
			"JOB: Serial Communication with Emulated Platform\n"
			"Uses:\n"
			"	1)libevents\n"
			"	2)ArduinoJson\n"
			"	3)serial communication\n\n"

			"Press 'h' during runtime for help\n"
			"Press 'q' to quit from the program\n"
			"#################################################\n"
			);

	// ask for client number
	printf("Please enter your client id number\n");
	// std::cin>>client_number;
	struct event_base *eb = event_base_new();
  	if (!eb) {
    	printf("Could not create event base");
  	}

  	struct event *hello_world_event = event_new(eb, -1, EV_TIMEOUT | EV_PERSIST, periodic_task,NULL);
  	timeval twoSec = {2, 0};
  	event_add(hello_world_event, &twoSec);

  	struct event *stdin_event = event_new(eb,STDIN_FILENO,EV_READ | EV_PERSIST,read_from_console,NULL);
  	event_add(stdin_event,NULL);

	struct event *service = event_new(eb,sockService ,EV_READ | EV_ET | EV_PERSIST ,callbackServiceHandler,NULL);
	event_add(service,NULL);

  	event_base_dispatch(eb);

}
