/**
******************************************************************************
* @file host-controller-service [Host Controller Service]
* @author Prasanth Vivek
* $Rev: 1 $
* $Date: 2018-02-06
* @brief Host Controller Service for interaction between client[UI], platform
        and cloud
******************************************************************************

* @copyright Copyright 2018 On Semiconductor
*/

#include "HostControllerService.h"

using namespace rapidjson;

AttachmentObserver::AttachmentObserver(void *client_socket,void *client_id_list)
{
    PDEBUG("Attaching the nimbus observer");
    client_connector_ = (Connector *)client_socket;
    client_list_ = (clientList *)client_id_list;
}

void AttachmentObserver::DocumentChangeCallback(jsonString jsonBody) {
    clientList::iterator client_list_iterator = client_list_->begin();
    while(client_list_iterator != client_list_->end()) {
        client_connector_->dealer_id_ = *client_list_iterator;
        client_connector_->send(jsonBody);
        PDEBUG("[hcs to hcc]%s",jsonBody);
        client_list_iterator++;
    }
}
/******************************************************************************/
/*                                core functions                              */
/******************************************************************************/
// @f constructor
// @b gets the config file name and assigns the value to proper variables
//
// arguments:
//  IN: config file name
//   set : socket address
//
//  OUT:
//   void
//
//  ERROR:
//    exits if socket cannot be opened or incorrect socket address
//
HostControllerService::HostControllerService(std::string configuration_file)
{
    // config file parsing
    configuration_ = new ParseConfig(configuration_file);
    PDEBUG("************************************************************");
    PDEBUG("[TODO]: Need to change the config file parameters for new hcs");
    std::cout<<"CONFIG: \n"<< *configuration_ <<std::endl;
    PDEBUG("************************************************************");
    //[TODO] [prasanth] : rename the terms and variables in config file and
    // parseconfig.cpp for easy understanding
    hcs_server_address_ = configuration_->GetSubscriberAddress();
    hcs_remote_address_ = configuration_->GetRemoteAddress();
    // get the serial port numbers from config file and store it to a vector
    serial_port_list_ = configuration_->GetSerialPorts();
    // get the dealer id for remote socket connection
    dealer_remote_socket_id_ = configuration_->GetDealerSocketID();
    // creating the nimbus object
    database_ = new Nimbus();
    database_->Open(NIMBUS_TEST_PLATFORM_JSON);

}

// @f init
// @b initialises the zmq context, socket, nimbus and serial
//
// arguments:
//  IN:
//   open : service socket
//          nimbus [not yet]
//          serial [not yet]
//  OUT:
//   void
//
//  ERROR:
//    exits if socket cannot be opened or incorrect socket address
//
HcsError HostControllerService::init()
{
    // zmq context creation
    socket_context_ = new(zmq::context_t);
    // opening the client socket to connect with UI
    client_connector_->open(hcs_server_address_);
    // registering the observer to the database
    // TODO [prasanth] NIMBUS integration **Needs better organisation
    AttachmentObserver blobObserver((void *)client_connector_, (void *)&clientList);
    database_->Register(&blobObserver);
    // openeing the socket to talk with the remote server
    remote_connector_->dealer_id_ = dealer_remote_socket_id_;
    remote_connector_->open(hcs_remote_address_);
    // [TODO]: [prasanth] the following lines are used to handle the serial connect/disconnect
    // This method will be removed once we get the serial to socket stuff in
    port_disconnected_ = true;
    setEventLoop();
    while(run());
    return NO_ERROR;
}

// @f run
// @b adds service callback to the event loop and starts it
//
// arguments:
//  IN:
//
//  OUT:
//   HcsError number
//
//  ERROR:
//    exits if events cannot be dispatched or cannot be added to the base
//
HcsError HostControllerService::run()
{

    while(!openPlatform()) {
        sleep(2);
    }
    PDEBUG("\033[1;32mPlatform detected\033[0m\n");
    initializePlatform(); // init serial config
    PDEBUG("platform handle value is %d",serial_fd_);
    port_disconnected_ = false;
    event_base_loopbreak(event_loop_base_);
    setEventLoop();
    return EVENT_BASE_FAILURE;
}

HcsError HostControllerService::setEventLoop()
{
    // get the platform list from the discovery service
    // [TODO] [Prasanth] : Should be added dynamically
    // remote_platforms remote_platform_list = discovery_service_.getPlatforms();
    addToLocalPlatformList(discovery_service_.getPlatforms());
    std::string platformList = getPlatformListJson();
    std::list<std::string>::iterator client_list_iterator = clientList.begin();
    while(client_list_iterator != clientList.end()) {
        client_connector_->dealer_id_ = *client_list_iterator;
        client_connector_->send(platformList);
        PDEBUG("[hcs to hcc]%s",platformList.c_str());
        client_list_iterator++;
    }

    // creating a periodic event for test case
    event_loop_base_ = event_base_new();
    if (!event_loop_base_) {
        PDEBUG("Could not create event base");
        return EVENT_BASE_FAILURE;
    }

    struct event *periodic_event = event_new(event_loop_base_, -1, EV_TIMEOUT
                        | EV_PERSIST, HostControllerService::testCallback,this);
    timeval seconds = {1, 0};
    event_add(periodic_event, &seconds);

    // [prasanth] : Always add the serial port handling to event loop before socket
    // the socket event loop
    if(!port_disconnected_) {
        platform_handler = event_new(event_loop_base_,serial_connector_->getFileDescriptor(), EV_READ | EV_PERSIST,
                                        HostControllerService::platformCallback,this);
        event_add(platform_handler,NULL);
    }

    // adding the service handler callback to the event loop
    struct event *service_handler = event_new(event_loop_base_,client_connector_->getFileDescriptor(),
                        EV_READ | EV_WRITE | EV_PERSIST ,
                        HostControllerService::serviceCallback,this);
    event_add(service_handler,NULL);

    // remote handler
    struct event *remote_handler = event_new(event_loop_base_,remote_connector_->getFileDescriptor(),
                        EV_READ | EV_WRITE | EV_PERSIST ,
                        HostControllerService::remoteCallback,this);
    event_add(remote_handler,NULL);

    // dispatch all the events
    event_base_dispatch(event_loop_base_);
}

/******************************************************************************/
/*                         event callback functions                           */
/******************************************************************************/
// @f testCallback
// @b periodic callback to test the libevent callback
//
// arguments:
//  IN: since it is a static function, this * is passed as input to variable args
//
//  OUT:
//   void
//
void HostControllerService::testCallback(evutil_socket_t fd, short what, void* args)
{
    // creating a periodic event for test case
    HostControllerService *hcs = (HostControllerService*)args;
    if(hcs->port_disconnected_) {
        if(hcs->openPlatform())
            event_base_loopbreak(hcs->event_loop_base_);
    }
}
/******************************************************************************/
/*                         event callback functions                           */
/******************************************************************************/
// @f service socket callback
// @b will be invoked when the service socket reads a message
//
// arguments:
//  IN: since it is a static function, this * is passed as input to variable args
//
//  OUT:
//   void
//
void HostControllerService::serviceCallback(evutil_socket_t fd, short what, void* args)
{
    // [TODO] [prasanth] This is just a test case. will clean this as we proceed
    HostControllerService *hcs = (HostControllerService*)args;
    std::string dealer_id;
    std::string read_message;
    if(hcs->client_connector_->read(read_message)) {
        dealer_id = hcs->client_connector_->dealer_id_;
        if(!hcs->clientExistInList(dealer_id)) {
            PDEBUG("Adding new client to list");
            hcs->clientList.push_back(dealer_id);
        }
        Document service_command;
        if (service_command.Parse(read_message.c_str()).HasParseError()) {
            PDEBUG("ERROR: json parse error!");
        }

        // TODO [ian] add this to a "command_filter" map to add more then just "db::cmd"
        if( service_command.HasMember("db::cmd") ) {

            PDEBUG("FILTER: %s\n", read_message.c_str());

            if ( hcs->database_->Command( read_message.c_str() ) != NO_ERRORS ){
                PDEBUG("ERROR: database failed failed!");
            }
        }
        if(hcs->platform_client_mapping_.empty() || !hcs->clientExists(dealer_id)) {
            std::vector<std::string> selected_platform_info = hcs->initialCommandDispatch(dealer_id,read_message);
            // strictly for testing alone
            if(!(selected_platform_info[0] == "NONE")) {
                // need to change the following lines to support struct
                std::vector<std::string> map_element;
                map_element.insert(map_element.begin(),selected_platform_info[0]);
                map_element.insert(map_element.begin()+1,selected_platform_info[1]);
                hcs->platform_client_mapping_.emplace(map_element,dealer_id);
                PDEBUG("adding the %s uuid to multimap\n",selected_platform_info[0].c_str());
            }
        } else {
            PDEBUG("Dispatching message to platform/s\n");
            hcs->disptachMessageToPlatforms(dealer_id,read_message);
        }
    }
}

// @f remote socket callback
// @b will be invoked when the service socket reads a message
//
// arguments:
//  IN: since it is a static function, this * is passed as input to variable args
//
//  OUT:
//   void
//
void HostControllerService::remoteCallback(evutil_socket_t fd, short what, void* args)
{
    // [TODO] [prasanth] This is just a test case. will clean this as we proceed
    HostControllerService *hcs = (HostControllerService*)args;
    std::string read_message;

    if (hcs->remote_connector_->read(read_message)) {
        PDEBUG("remote message read %s",read_message.c_str());
        hcs->remoteRouting(read_message);
    }
}

// @f platform serial callback
// @b will be invoked when the platform writes a message
//
// arguments:
//  IN: since it is a static function, this * is passed as input to variable args
//
//  OUT:
//   void
//
void HostControllerService::platformCallback(evutil_socket_t fd, short what, void* args)
{
    // [TODO] [prasanth] This is just a test case. will clean this as we proceed
    PDEBUG("Inside platform callback\n");
    HostControllerService *hcs = (HostControllerService*)args;
    std::string read_message = hcs->platformRead();
    PDEBUG("message being read %s\n",read_message.c_str());
    // [TODO] [prasanth] change the map value for platform from string to structure
    std::string dealer_id;
    hcs->checkPlatformExist(&dealer_id,read_message);
    //[TODO] [prasanth]: send data to the data bridge through multimap handle
    hcs->remote_connector_->send(read_message);
}

/******************************************************************************/
/*                              utility functions                              */
/******************************************************************************/

// @f openPlatform
// @b checks the serial device in the vector assigned from the config file and opens them
//
// arguments:
//  IN:
//
//  OUT: true, if device is connected
//       false, if device is not connected
//
//
bool HostControllerService::openPlatform()
{
    static bool outputPortError = true;

    if(serial_port_list_.empty()) {
        std::cout << "ERROR: Please add serial port number in config file  !!!"<< std::endl;
        return false;
    }
    for (auto port : serial_port_list_) {
        if(serial_connector_->open((std::string)port)) {
            outputPortError = true;
            port_disconnected_ = false;
            return true;
        }
        else if(outputPortError) {
            std::cout << "ERROR: Invalid Serial Port Number " << port <<" Please check the config file  !!!" << std::endl;
        }
    }
    // Only output the error once
    outputPortError = false;
    return false;
}

// @f initializeSerial
// @b after opening the serial port, this function configures the serial port
//
// arguments:
//  IN:
//
//  OUT:
//
//
void HostControllerService::initializePlatform()
{
    platform_details simulated_usb_pd,simulated_motor_vortex,sim_usb;
    simulated_usb_pd.platform_uuid = "P2.2018.1.1.0.0.c9060ff8-5c5e-4295-b95a-d857ee9a3671";
    simulated_usb_pd.platform_verbose = "USB PD Load Board";
    simulated_usb_pd.connection_status = "view";

    simulated_motor_vortex.platform_uuid = "motorvortex1";
    simulated_motor_vortex.platform_verbose = "Vortex Fountain Motor Platform Board";
    simulated_motor_vortex.connection_status = "view";

    sim_usb.platform_uuid = "P2.2017.1.1.0.0.cbde0519-0f42-4431-a379-caee4a1494af";
    sim_usb.platform_verbose = "USB PD";
    sim_usb.connection_status = "view";
    platform_uuid_.push_back(simulated_usb_pd);  // for testing alone
    platform_uuid_.push_back(simulated_motor_vortex);
    platform_uuid_.push_back(sim_usb);
    parseAndGetPlatformId();
}

// @f commandDispatch
// @b gets the json encoded string from client and then dispatches it
//
// arguments:
//  IN: json command from client
//
//  OUT:
//
//
std::vector<std::string> HostControllerService::initialCommandDispatch(std::string dealer_id,std::string command)
{
    // [TODO]: [prasanth] should be removed after bod demo
    std::vector<std::string> selected_platform;
    selected_platform.insert(selected_platform.begin(),"NONE");
    selected_platform.insert(selected_platform.begin()+1,"NONE");
    std::string board_name,remote_status ;
    client_connector_->dealer_id_ = dealer_id;
    Document service_command;
    // [TODO] [prasanth] : needs better organization
    if (service_command.Parse(command.c_str()).HasParseError()) {
        PDEBUG("ERROR: json parse error!\n");
        return selected_platform;
    }

    // state machine using switch statements
    switch(stringHash(service_command["cmd"].GetString())) {
        case request_hcs_status:           client_connector_->send(JSON_SINGLE_OBJECT
                                                ("hcs::notification","hcs_active"));
                                            break;
        case register_client:
        case request_available_platforms:   PDEBUG("Sending the list of available platform");
                                            client_connector_->send(getPlatformListJson());
                                            break;
        case platform_select:               PDEBUG("The client has selected a platform");
                                            board_name = service_command["platform_uuid"].GetString();
                                            remote_status = service_command["remote"].GetString();
                                            selected_platform.insert(selected_platform.begin(),board_name);
                                            selected_platform.insert(selected_platform.begin()+1,remote_status);
                                            return selected_platform;
    }
    return selected_platform;
}

// @f disptachMessageToPlatforms
// @b gets the json encoded string from client and then dispatches it to the corresponding platform/s
//
// arguments:
//  IN: client_id and the message from client
//
//  OUT: true if success,
//       false if failure
//
bool HostControllerService::disptachMessageToPlatforms(std::string dealer_id,std::string read_message)
{
    for(multimap_iterator_= platform_client_mapping_.begin();multimap_iterator_!=
                            platform_client_mapping_.end();multimap_iterator_++) {
        if (multimap_iterator_->second == dealer_id) {
            // the following printing is strictly for testing only
            PDEBUG("\033[1;4;31m[%s<-%s]\033[0m: %s\n",multimap_iterator_->first[0].c_str(),dealer_id.c_str(),read_message.c_str());
            Document service_command;
            if(!read_message.empty()) {
                if (service_command.Parse(read_message.c_str()).HasParseError()) {
                    PDEBUG("ERROR: json parse error!\n");
                    return false;
                }
            }
            if(service_command.HasMember("cmd")) {
                std::string command = service_command["cmd"].GetString();
                if(multimap_iterator_->first[0] == "simulated-usb-pd") {
                    if(command == "set_target_voltage") {
                        usb_pd_target_voltage_ = service_command["target_voltage"].GetInt();
                    }
                    return true;
                } else if(multimap_iterator_->first[0] == "simulated-vortex-motor") {
                    if(command == "set_target_pwm") {
                        vortex_target_pwm_ = service_command["target_pwm"].GetInt();
                    }
                    return true;
                } else if(multimap_iterator_->first[0] == "Vortex Fountain Motor Platform Board") {
                    if(multimap_iterator_->first[1] == "connected") {
                        PDEBUG("\033[1;4;31mlocal write %s\033[0m\n",multimap_iterator_->first[1].c_str());
                        read_message += "\n";
                        //sp_nonblocking_write(platform_socket_,(void *)read_message.c_str(),read_message.length());
                        if(serial_connector_->send(read_message)) {
                            PDEBUG("\033[1;4;33mWrite success %s\033[0m",read_message.c_str());
                        }
                        else {
                            PDEBUG("\033[1;4;31mWrite success %s\033[0m",read_message.c_str());
                        }
                    }
                    else if(multimap_iterator_->first[1] == "remote") {
                        PDEBUG("\033[1;4;31mlocal write %s\033[0m\n",multimap_iterator_->first[1].c_str());
                        read_message += "\n";
                        remote_connector_->send(read_message);
                    }
                }
            }
        }
    }
    return false;
}

// @f stringHash
// @b gets the command object's value and returns the appropriate hash(enum) number
//
// arguments:
//  IN: json command object's key as string
//
//  OUT: hash(enum) for the string
//
//
CommandDispatcherMessages HostControllerService::stringHash(std::string command)
{
    if(command == "request_hcs_status") {
        return request_hcs_status;
    } else if (command == "request_available_platforms") {
        return request_available_platforms;
    } else if (command == "platform_select") {
        return platform_select;
    } else if (command == "register_client") {
        return register_client;
    } else {
        return command_not_found;
    }
}

//[TODO] [prasanth] create some class for this function
// @f parseAndGetPlatformId
// @b gets the json encoded string parses and returns the platform ID
//
// arguments:
//  IN: json encoded string {!!! Expects only the platform id}
//
//  OUT: bool true if it has platform id else false
//
//
bool HostControllerService::parseAndGetPlatformId()
{
    PDEBUG("parseAndGetPlatformId\n");
    std::string cmd = "{\"cmd\":\"request_platform_id\"}\n";

    bool isPlatformId=false;
    // // platform read will be handled by connector factory and will always be called libevents
    while(!isPlatformId) {
        if(serial_connector_->send(cmd)) {
            PDEBUG("[Serial write] %s -> success\n",cmd.c_str());
        }
        else {
            PDEBUG("[Serial write] %s -> fail\n",cmd.c_str());
        }
        std::string ack_message = platformRead();
        std::string platform_id_message = platformRead();
        Document platform_command;
        if (platform_command.Parse(platform_id_message.c_str()).HasParseError()) {
            PDEBUG("ERROR: json parse error in Platform ID section %s!\n",platform_id_message.c_str());
            isPlatformId = false;
        }

        else if(platform_command.HasMember("notification")){
            if (platform_command["notification"]["payload"].HasMember("verbose_name")) {
              platform_details platform;
              platform.platform_uuid = platform_command["notification"]["payload"]["platform_id"].GetString();
              platform.platform_verbose = platform_command["notification"]["payload"]["verbose_name"].GetString();
              platform.connection_status = "connected";    // [TODO] need some cool way to do it
              PDEBUG("Platform UUID %s\n",platform.platform_uuid.c_str());
              // [TODO] : add the platform element to the list
              platform_uuid_.push_back(platform);

              // [TODO] [prasanth] the following section is for mapping between remote and paltform
              if(!clientExists("remote")) {
                  std::vector<std::string> map_element;
                  map_element.insert(map_element.begin(),platform.platform_verbose);
                  map_element.insert(map_element.begin()+1,"connected");
                  PDEBUG("[remote routing ] added into map");
                  platform_client_mapping_.emplace(map_element,"remote");
                  g_platform_uuid_ = platform.platform_verbose;
              }
              break;
            }
        }
    }
}

// @f sendToClient
// @b gets the message and the dealer id where to send
//
// arguments:
//  IN: dealer_id and the message to send
//
//  OUT: bool true if it has platform id else false
//
//
bool HostControllerService::sendToClient(std::string dealer_id, std::string message)
{
    s_sendmore(*server_socket_,dealer_id);
    s_send(*server_socket_,message);
    getServerSocketEventReady();
}

// @f addToLocalPlatformList
// @b checks the list of available platforms and adds the new platforms to the list from Discovery Service
//
// arguments:
//  IN: disc service list of platforms
//
//  OUT:
//
void HostControllerService::addToLocalPlatformList(remote_platforms remote_platform)
{
    platform_details platform;
    platform.platform_uuid = remote_platform[0].platform_uuid;
    platform.platform_verbose = remote_platform[0].platform_verbose;
    platform.connection_status = "remote";
    platform_uuid_.push_back(platform);
}

/******************************************************************************/
/*               potential connector factory functions                        */
/******************************************************************************/
// @f platform read
// @b does a serial read from the global member platform_socket_
//
// arguments:
//  IN:
//
//  OUT: returns the received message
//
//
std::string HostControllerService::platformRead()
{
    PDEBUG("Inside read");
    std::string notification;
    if (serial_connector_->read(notification)) {
        return notification;
    }
    else {
        PDEBUG("Platform Disconnected\n");
        port_disconnected_ = true;
        sendDisconnecttoUI();
        platform_uuid_.clear();
        platform_client_mapping_.clear();
        sleep(1);
        // adding the remote platform
        addToLocalPlatformList(discovery_service_.getPlatforms());

        platform_details simulated_usb_pd,simulated_motor_vortex,sim_usb;
        simulated_usb_pd.platform_uuid = "P2.2018.1.1.0.0.c9060ff8-5c5e-4295-b95a-d857ee9a3671";
        simulated_usb_pd.platform_verbose = "USB PD Load Board";
        simulated_usb_pd.connection_status = "view";

        simulated_motor_vortex.platform_uuid = "motorvortex1";
        simulated_motor_vortex.platform_verbose = "Vortex Fountain Motor Platform Board";
        simulated_motor_vortex.connection_status = "view";

        sim_usb.platform_uuid = "P2.2017.1.1.0.0.cbde0519-0f42-4431-a379-caee4a1494af";
        sim_usb.platform_verbose = "USB PD";
        sim_usb.connection_status = "view";

        platform_uuid_.push_back(simulated_usb_pd);  // for testing alone
        platform_uuid_.push_back(simulated_motor_vortex);
        platform_uuid_.push_back(sim_usb);

        std::string platformList = getPlatformListJson();
        std::list<std::string>::iterator client_list_iterator = clientList.begin();
        while(client_list_iterator != clientList.end()) {
            client_connector_->dealer_id_ = *client_list_iterator;
            client_connector_->send(platformList);
            PDEBUG("[hcs to hcc]%s",platformList.c_str());
            client_list_iterator++;
        }
        // event_del(platform_handler);
        event_base_loopbreak(event_loop_base_);
        port_disconnected_ = true;
        setEventLoop();
        return "";
    }
}

void HostControllerService::sendDisconnecttoUI()
{
    std::list<std::string>::iterator client_list_iterator = clientList.begin();
    std::string disconnect_message = "{\"notification\":{\"value\":\"platform_connection_change_notification\",\"payload\":{\"status\":\"disconnected\"}}}";
    while(client_list_iterator != clientList.end()) {
        client_connector_->dealer_id_ = *client_list_iterator;
        client_connector_->send(disconnect_message);
        client_list_iterator++;
    }
}

/******************************************************************************/
/*                              getter functions                              */
/******************************************************************************/
// @f getServiceSocketFileDescriptor
// @b returns the file descriptor for the zeromq router socket
//
// arguments:
//  IN:
//
//  OUT:
//    router socket file descriptor
//
int HostControllerService::getServerSocketFileDescriptor()
{
    #ifdef _WIN32
        unsigned long long int server_socket_file_descriptor=0;
        size_t server_socket_file_descriptor_size = sizeof(server_socket_file_descriptor);
    #else
        int server_socket_file_descriptor=0;
        size_t server_socket_file_descriptor_size = sizeof(server_socket_file_descriptor);
    #endif
    server_socket_->getsockopt(ZMQ_FD,&server_socket_file_descriptor,
            &server_socket_file_descriptor_size);
    return server_socket_file_descriptor;
}

int HostControllerService::getRemoteSocketFileDescriptor()
{
    #ifdef _WIN32
        unsigned long long int remote_socket_file_descriptor=0;
        size_t remote_socket_file_descriptor_size = sizeof(remote_socket_file_descriptor);
    #else
        int remote_socket_file_descriptor=0;
        size_t remote_socket_file_descriptor_size = sizeof(remote_socket_file_descriptor);
    #endif
    remote_socket_->getsockopt(ZMQ_FD,&remote_socket_file_descriptor,
            &remote_socket_file_descriptor_size);
    return remote_socket_file_descriptor;
}

// @f getServerSocketEventReady
// @b make the server ready for reading and triggering the next event
//
// arguments:
//  IN:
//
//  OUT:
//
//
void HostControllerService::getServerSocketEventReady()
{
    // [prasanth] : The following lines are required for the event handling
    // to recognize the next read trigger
    unsigned int     zmq_events;
    size_t           zmq_events_size  = sizeof(zmq_events);
    server_socket_->getsockopt(ZMQ_EVENTS, &zmq_events, &zmq_events_size);
    unsigned int     zmq_events_remote;
    size_t           zmq_events_size_remote  = sizeof(zmq_events_remote);
    remote_socket_->getsockopt(ZMQ_EVENTS, &zmq_events_remote, &zmq_events_size_remote);
}

// @f getPlatformListJson
// @b uses RapidJSON to create json message with list of available platforms
//
// arguments:
//  IN:
//
//  OUT: string that is in json format and contains the list of available paltforms
//
//
std::string HostControllerService::getPlatformListJson()
{
    // document is the root of a json message
    Document document;
    // define the document as an object rather than an array
    document.SetObject();
    Value array(kArrayType);
    Document::AllocatorType& allocator = document.GetAllocator();
    // traversing through the list
    for(auto platform_list_iterator = platform_uuid_.begin(); platform_list_iterator
                                != platform_uuid_.end();platform_list_iterator++) {
        platform_details platform = *platform_list_iterator;
        Value json_verbose(platform.platform_verbose.c_str(),allocator);
        Value json_uuid(platform.platform_uuid.c_str(),allocator);
        Value json_connection_status(platform.connection_status.c_str(),allocator);
        Value array_object;
        array_object.SetObject();

        array_object.AddMember("verbose",json_verbose,allocator);
        array_object.AddMember("uuid",json_uuid,allocator);
        array_object.AddMember("connection",json_connection_status,allocator);
        array.PushBack(array_object,allocator);
    }
    Value nested_object;
    nested_object.SetObject();
    nested_object.AddMember("list",array,allocator);
    document.AddMember("hcs::notification",nested_object,allocator);
    StringBuffer strbuf;
    Writer<StringBuffer> writer(strbuf);
    document.Accept(writer);
    return strbuf.GetString();
}


/******************************************************************************/
/*                              checker functions                              */
/******************************************************************************/
// @f clientExists
// @b returns the true if client exits
//
// arguments:
//  IN: client/dealer socket identifier
//
//  OUT:
//   true if it exists in map and false if it does not
//
bool HostControllerService::clientExists(std::string client_identifier)
{
    bool does_client_exist;
    multimap_iterator_ = platform_client_mapping_.begin();
    while(multimap_iterator_ != platform_client_mapping_.end()) {
        does_client_exist = (multimap_iterator_->second == client_identifier);
        if(does_client_exist) {
            break;
        }
        multimap_iterator_++;
    }
    return does_client_exist;
}

// @f clientExistsinList
// @b returns the true if client exits in the list
//
// arguments:
//  IN: client/dealer socket identifier
//
//  OUT:
//   true if it exists in list and false if it does not
//
bool HostControllerService::clientExistInList(std::string client_identifier)
{
    bool does_client_exist;
    std::list<std::string>::iterator client_list_iterator = clientList.begin();
    while(client_list_iterator != clientList.end()) {
        does_client_exist = (*client_list_iterator == client_identifier);
        if(does_client_exist) {
            break;
        }
        client_list_iterator++;
    }
    return does_client_exist;
}

// @f checkPlatformExist
// @b returns the true if client exits
//
// arguments:
//  IN: client/dealer socket identifier
//
//  OUT:
//   true if it exists in map and false if it does not
//
bool HostControllerService::checkPlatformExist(std::string *dealer_id,std::string message)
{
    multimap_iterator_ = platform_client_mapping_.begin();
    while(multimap_iterator_ != platform_client_mapping_.end()) {
        bool does_platform_exist = false;
        std::vector<std::string> map_uuid = multimap_iterator_->first;
        // strictly for testing only
        (map_uuid[0] == "Vortex Fountain Motor Platform Board")?does_platform_exist = true : does_platform_exist = false;
        if(does_platform_exist) {
            *dealer_id = multimap_iterator_->second;
            if(!message.empty()) {
              client_connector_->dealer_id_ = *dealer_id;
              client_connector_->send(message);
            }
        }
        multimap_iterator_++;
    }
    return true;
}

void HostControllerService::remoteRouting(std::string message)
{
    std::string dealer_id;
    multimap_iterator_ = platform_client_mapping_.begin();
    while(multimap_iterator_ != platform_client_mapping_.end()) {
        bool does_platform_exist = false;
        std::vector<std::string> map_uuid = multimap_iterator_->first;
        std::string dealer_id = multimap_iterator_->second;
        (map_uuid[0] == "Vortex Fountain Motor Platform Board")?does_platform_exist = true : does_platform_exist = false;
        if(does_platform_exist) {
            dealer_id = multimap_iterator_->second;
            if(!message.empty()) {
              if(map_uuid[1] == "remote") {
                  client_connector_->dealer_id_ = dealer_id;
                  client_connector_->send(message);
              } else if (map_uuid[1] == "connected") {
                  PDEBUG("Inside remote writing %s with dealer id %s",message.c_str(),dealer_id.c_str());
                  serial_connector_->send(message);
              }
            }
        }
        multimap_iterator_++;
    }
}
