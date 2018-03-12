/**
******************************************************************************
* @file host-controller-service.h
* @author Prasanth Vivek
* $Rev: 1 $
* $Date: 2018-02-06
* @brief Implements the public Class for Host Controller Service
******************************************************************************

* @copyright Copyright 2018 On Semiconductor
*/
#ifndef HOST_CONTROLLER_SERVICE_H
#define HOST_CONTROLLER_SERVICE_H

// standard library
#include <iostream>
#include <string>
#include <sstream>
#include <stdio.h>
#include <fstream>
#include <SimpleOpt.h>
#include <map>
#include <list>
#include <thread>

// zero mq library
#include "zmq.hpp"
#include "zmq_addon.hpp"
#include "zhelpers.hpp"

// libevent library
#include <event2/event.h>
#include <event.h>

// libserial port library
#include <libserialport.h>

// rapid json library
#include "rapidjson/document.h"
#include <rapidjson/writer.h>
#include <rapidjson/stringbuffer.h>

// project libraries
#include "ParseConfig.h"
#include "Logger.h"
#include "DiscoveryService.h"

// Console print function
// used in main.cc and host-controller-service.cc
// usage:1) PDEBUG("hello world",0);
//       2) PDEBUG("the sum id %d",sum);
// controller by "DEBUG" variable
// DEBUG - 1 // print the message on Console
//         0 // do not print the message
#define DEBUG 1


// Helper macro for stringifying JSON. The quotes for key and variable get passed down explicity
#define WRAPQUOTE(key)  #key
#define JSON_SINGLE_OBJECT(key, value)      "{" WRAPQUOTE(key) ":" WRAPQUOTE(value) "}"

// Internal error numbers for Host Controller Services
typedef enum {
    NO_ERROR          = 0,
    EVENT_BASE_FAILURE = 1,
} HcsError;

// Host Controller Service Command dipstach messages
typedef enum{
	request_hcs_status	= 0,
	request_available_platforms = 1,
	platform_select		= 2,
    register_client     = 3,
	command_not_found	= 10,
}CommandDispatcherMessages;

// struct that will be added to the list
typedef struct{
    std::string platform_uuid;
    std::string platform_verbose;
    std::string connection_status;
}platform_details;

class HostControllerService {
public:
    // constructor
    HostControllerService(std::string configuration_file);

    // public member functions
    HcsError init();
    HcsError run();
    HcsError exit();

    // libevent callbacks
    static void testCallback(evutil_socket_t fd, short what, void* args);
    static void serviceCallback(evutil_socket_t fd, short what, void* args);
	static void platformCallback(evutil_socket_t fd, short what, void* args);
    static void remoteCallback(evutil_socket_t fd, short what, void* args);

	// utility functions
	std::vector<std::string> initialCommandDispatch(std::string dealer_id,std::string command);
	bool disptachMessageToPlatforms(std::string dealer_id,std::string command);
	CommandDispatcherMessages stringHash(std::string command);
	bool openPlatform(); // platform functions
	void initializePlatform(); //platform functions
    void addToLocalPlatformList(remote_platforms);  // add the element to the list

	std::string platformRead(); // this fucntion will be moved to usb connector
	bool parseAndGetPlatformId(); // potential new class to parse and handle json messages

	// sends the data from platform to client
	bool sendToClient(std::string dealer_id, std::string message_to_send);

    // getter fucntions
    int getServerSocketFileDescriptor();
    int getRemoteSocketFileDescriptor();
	void getServerSocketEventReady();
	std::string getPlatformListJson();
	// checker functions
	bool clientExists(std::string);
	bool checkPlatformExist(std::string *,std::string message);
    void remoteRouting(std::string message);

    // thread to monitor the serial port
    void serialPortMonitor();
    void sendDisconnecttoUI();

    void sendtoMap();
    HcsError setEventLoop();
private:
    // config file data members
    ParseConfig *configuration_;
    // zeromq data members
    zmq::context_t* socket_context_;    // context
    std::string hcs_server_address_;    // server address
    std::string hcs_remote_address_;    // remote address
    zmq::socket_t* server_socket_;      // server socket
    zmq::socket_t* remote_socket_;      // remote socket
	// getting serial port number from config file
	std::vector<std::string> serial_port_list_;
    // getting the dealer id for remote connection
    std::string dealer_remote_socket_id_;
    // libevent data members
    event_base *event_loop_base_;
    // multimap usage to store & find the link between client and platform
    // multimap is selected since in future we may work on many to many possibilities
    // for eg: client connected to two plat or plat connected to 2 clients
    // [TODO] [prasanth] create the multi map between UUID (string) and zmq ID(zmq_msg)
    // [testing alone] map created between int and zmq_msg

    // typedef std::multimap<std::vector<std::string>,std::string> multimap;
	typedef std::multimap<std::vector<std::string>,std::string> multimap;

    multimap platform_client_mapping_;
	multimap::iterator multimap_iterator_;	// iterator for multimap
    // list to hold all the platform UUID
    // [testing alone] hold int
	typedef std::list<platform_details> platformList;
    platformList platform_uuid_;    // [TODO] : change the naming style
	std::string g_platform_uuid_;	// global variable to stor connected uuid
	// ********************** //
	// lib serial port variables
	struct sp_port *platform_socket_;
    struct sp_event_set *ev;
    sp_return error;
	int serial_fd_;	//file descriptor for serial ports

    // Object for Discovery Service
    DiscoveryService discovery_service_;

    // Strictly for testing alone
    int usb_pd_target_voltage_ = 5; // to add to the multimap for testing case alone
	int vortex_target_pwm_ = 1300;
    // zmq::message_t g_reply_;
	std::string g_reply_,g_selected_platform_verbose_,g_dealer_id_;

    std::thread *serial_monitor_thread;
    std::thread *lib_event_thread;

    bool port_disconnected_;

    // platform libevents
    struct event *platform_handler;
};
#endif
