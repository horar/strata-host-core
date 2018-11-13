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

/**
 * * @mainpage HostControllerService
 *
 * Introduction
 * ============
 * Host Controller Service(HCS) is the edge to the cloud in the "Spyglass" project.
 * It communicates with cloud services, platform and client programs(UI, CLI).
 *
 * Valuable Information
 * ================
 * 1) Libevent dynamic addition/removal of events is implemented using event_init,event_add and event_dispatch.
 *    Dynamic addition and removal of events does not work using event_base_init, event_base_dispatch
 *
 * KNOWN BUGS/HACKS
 * ================
 * This section mentions about the technical bugs and our work around in detail
 *
 * 1) libevent read trigger fails sometimes for zeroMQ sockets (Techinal Hardship/HACK)
 *      HCS uses libevent as eventing library. It requires READ event to instantiate the
 * callback for zeromq sockets. But libevent fails to call the callbacks on READ event.
 * Currently the workaround for this issue is to use read and write for callbacks. This will
 * call the callbacks everytime (does not wait for a read event) and the callbacks uses poll
 * on sockets to read.
 *
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
#include "Connector.h"

// nimbus integration
#include "nimbus.h"
#include "observer.h"

// Console print function
// used in main.cc and host-controller-service.cc
// usage:1) PDEBUG("hello world",0);
//       2) PDEBUG("the sum id %d",sum);
// controller by "DEBUG" variable
// PRINT_DEBUG - 1 // print the message on Console
//         0 // do not print the message
#define PRINT_DEBUG 1

// set the length of hcs token
#define HCSTOKEN_LENGTH 7

// Helper macro for stringifying JSON. The quotes for key and variable get passed down explicity
#define WRAPQUOTE(key)  #key
#define JSON_SINGLE_OBJECT(key, value)      "{" WRAPQUOTE(key) ":" WRAPQUOTE(value) "}"

#if defined(NO_ERROR)
#undef NO_ERROR
#endif

// Internal error numbers for Host Controller Services
enum class HcsError{
    NO_ERROR           = 0,
    EVENT_BASE_FAILURE = 1,
};

// Host Controller Service Command dipstach messages
enum class CommandDispatcherMessages{
    REQUEST_HCS_STATUS	= 0,
    REQUEST_AVAILABLE_PLATFORMS = 1,
    PLATFORM_SELECT		= 2,
    REGISTER_CLIENT     = 3,
    COMMAND_NOT_FOUND	= 10,
};

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
    static void remoteActivityCallback(evutil_socket_t fd, short what, void* args);

    // utility functions
    std::vector<std::string> initialCommandDispatch(const std::string& dealer_id,const std::string& command);
    bool disptachMessageToPlatforms(const std::string& dealer_id,std::string& command);
    CommandDispatcherMessages stringHash(const std::string& command);
    bool openPlatform(); // platform functions
    void initializePlatform(); //platform functions
    void addToLocalPlatformList(remote_platforms);  // add the element to the list

    void generateHCSToken(std::string&, const int);
    std::string platformRead(); // this fucntion will be moved to usb connector
    bool parseAndGetPlatformId(); // potential new class to parse and handle json messages
    void parseHCSCommands(const std::string&); // function that parses the messages for hcs

    // getter fucntions
    void getPlatformListJson(std::string &);
    // checker functions
    bool clientExists(const std::string&);
    bool checkPlatformExist(const std::string& message);
    void remoteRouting(const std::string& message);
    bool clientExistInList(const std::string&);

    // thread to monitor the serial port
    void serialPortMonitor();
    void sendDisconnecttoUI();
    void platformDisconnectRoutine();

    // function that creates json using second parameter as notification and third as value
    void constructJSON(std::string&, const std::string&, const std::string&);

    // remote connection routine (with Discover Service)
    void handleRemotePlatformRegistration(bool);
    void handleRemoteGetPlatforms();
    void handleRemoteConnection(const std::string&);
    void handleRemoteActivity(const std::string&);
    void startRemoteService(); // starts the remote service
    void startActivityMonitorService(); // starts the subscriber service

    HcsError setEventLoop();
    void appendUsername(std::string&); // appends the username to the input json message
    void retrieveUsername(const std::string&);  // retrieves user name from the input json string
private:
    // config file data members
    ParseConfig *configuration_;
    // zeromq data members
    zmq::context_t* socket_context_;    // context
    std::string hcs_server_address_;    // server address
    std::string hcs_remote_address_;    // remote address
    zmq::socket_t* server_socket_;      // server socket
    zmq::socket_t* remote_socket_;      // remote socket

    // The following socket is for monitoring the activity from discovery service
    std::string remote_discovery_monitor_; // monitor sokcet address
    zmq::socket_t* remote_discovery_monitor_socket_;    // monitor socket

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
    typedef std::multimap<std::vector<std::string>,std::string> multimap;

    multimap platform_client_mapping_;
    multimap::iterator multimap_iterator_;	// iterator for multimap
    // list to hold all the platform UUID
    // [testing alone] hold int
    typedef std::list<platform_details> platformList;
    platformList platform_uuid_;    // [TODO] : change the naming style
    std::string g_platform_uuid_;	// global variable to stor connected uuid

    std::list<std::string> clientList;

    // Object for Discovery Service
    DiscoveryService *discovery_service_;

    // zmq::message_t g_reply_;
    std::string g_reply_,g_selected_platform_verbose_,g_dealer_id_;

    bool port_disconnected_;

    // Connector objects
    ConnectorFactory *connector_factory_;
    Connector *client_connector_ ;
    Connector *serial_connector_ ;
    Connector *remote_connector_ ;
    Connector *remote_activity_connector_;

    // Nimbus/database object
    Nimbus * database_;

    // JWT for the client session
    std::string JWT;
    // bool remote_advertise;

    struct event remote_handler_;
    struct event periodic_event_;
    struct event platform_handler_;
    struct event service_handler_;
    struct event activity_handler_;

    std::string user_name_;

};
#endif
