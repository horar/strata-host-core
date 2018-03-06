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

    // opening the server socket as router
    server_socket_ = new zmq::socket_t(*socket_context_,ZMQ_ROUTER);
    // binding the server socket to address in config file
    server_socket_->bind(hcs_server_address_.c_str());

    // opening the remote socket as dealer
    remote_socket_ = new zmq::socket_t(*socket_context_,ZMQ_DEALER);
    // setting the dealer id for the remote socket
    remote_socket_->setsockopt(ZMQ_IDENTITY,dealer_remote_socket_id_.c_str(),dealer_remote_socket_id_.length());
    remote_socket_->connect(hcs_remote_address_.c_str());

    // place for serial/platform handling
    // [TODO] [prasanth] strictly for testing alone
    platform_details simulated_usb_pd,simulated_motor_vortex;
    simulated_usb_pd.platform_uuid = "simulation_1";
    simulated_usb_pd.platform_verbose = "simulated-usb-pd";
    simulated_usb_pd.connection_status = "view";

    simulated_motor_vortex.platform_uuid = "simulation_2";
    simulated_motor_vortex.platform_verbose = "simulated-motor-vortex";
    simulated_motor_vortex.connection_status = "view";

    platform_uuid_.push_back(simulated_usb_pd);  // for testing alone
    platform_uuid_.push_back(simulated_motor_vortex);  // for testing alone
    // initialize the event base
    event_loop_base_ = event_base_new();
    if (!event_loop_base_) {
    	PDEBUG("Could not create event base");
        return EVENT_BASE_FAILURE;
  	}
    // open the serial port connected to platform
    if(openPlatform()) {
        PDEBUG("\033[1;32mPlatform detected\033[0m\n");
        initializePlatform(); // init serial config
        PDEBUG("platform handle value is %d",serial_fd_);
    } else {
        PDEBUG(RED_TEXT_START "WARNING: no connected platforms" RED_TEXT_END"\n");
    }

    // get the platform list from the discovery service
    // [TODO] [Prasanth] : Should be added dynamically
    // remote_platforms remote_platform_list = discovery_service_.getPlatforms();
    addToLocalPlatformList(discovery_service_.getPlatforms());
    // PDEBUG("remote platform values %s %s",remote_platform_list[0].platform_uuid.c_str(),remote_platform_list[0].platform_verbose.c_str());
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
    // creating a periodic event for test case
    struct event *periodic_event = event_new(event_loop_base_, -1, EV_TIMEOUT
                        | EV_PERSIST, HostControllerService::testCallback,this);
  	timeval seconds = {3, 0};
  	event_add(periodic_event, &seconds);

    // service handler
    int server_socket_file_descriptor = getServerSocketFileDescriptor();

    // [prasanth] : Always add the serial port handling to event loop before socket
    // the socket event loop opens
    sp_get_port_handle(platform_socket_,&serial_fd_);
    PDEBUG("Serial fd %d\n",serial_fd_);
    struct event *platform_handler = event_new(event_loop_base_, serial_fd_, EV_READ | EV_PERSIST,
                                    HostControllerService::platformCallback,this);
    event_add(platform_handler,NULL);

    // adding the service handler callback to the event loop
    struct event *service_handler = event_new(event_loop_base_,server_socket_file_descriptor,
                        EV_READ | EV_WRITE | EV_PERSIST ,
                        HostControllerService::serviceCallback,this);
    event_add(service_handler,NULL);

    // remote handler
    int remote_socket_file_descriptor = getRemoteSocketFileDescriptor();
    // adding the service handler callback to the event loop
    unsigned int     zmq_events;
    size_t           zmq_events_size  = sizeof(zmq_events);
    remote_socket_->getsockopt(ZMQ_EVENTS, &zmq_events, &zmq_events_size);

    struct event *remote_handler = event_new(event_loop_base_,remote_socket_file_descriptor,
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

    // Following codes are strictly for testing only and hence written in stupid way
    hcs->multimap_iterator_ = hcs->platform_client_mapping_.begin();
    for(hcs->multimap_iterator_= hcs->platform_client_mapping_.begin();hcs->multimap_iterator_!=
                            hcs->platform_client_mapping_.end();hcs->multimap_iterator_++) {
        if (hcs->multimap_iterator_->first[0]=="simulated-udb-pd") {
            // [prasanth] : sending the client id. s_sendmore is to say the client that
            // we are sending multipart message and there is a message to follow
            s_sendmore(*hcs->server_socket_,hcs->multimap_iterator_->second);
            // s_sendmore(*hcs->server_socket_,"prasanth\n");
            Document document;
            // define the document as an object rather than an array
            document.SetObject();
            Document::AllocatorType& allocator = document.GetAllocator();
            document.AddMember("command","usb-pd-power-notifications",allocator);
            document.AddMember("target-voltage",hcs->usb_pd_target_voltage_,allocator);
            StringBuffer strbuf;
            Writer<StringBuffer> writer(strbuf);
            document.Accept(writer);
            s_send(*hcs->server_socket_,strbuf.GetString());

            PDEBUG("\033[1;4;32m[%s->%s]\033[0m: %s\n",hcs->multimap_iterator_->first[0].c_str(),hcs->multimap_iterator_->second.c_str(),strbuf.GetString());
        } else if (hcs->multimap_iterator_->first[0]=="simulated-motor-vortex") {
            // [prasanth] : sending the client id. s_sendmore is to say the client that
            // we are sending multipart message and there is a message to follow
            s_sendmore(*hcs->server_socket_,hcs->multimap_iterator_->second);
            Document document;
            // define the document as an object rather than an array
            document.SetObject();
            Document::AllocatorType& allocator = document.GetAllocator();
            document.AddMember("command","motor-pwm-notifications",allocator);
            document.AddMember("target-motor-pwm",hcs->vortex_target_pwm_,allocator);
            StringBuffer strbuf;
            Writer<StringBuffer> writer(strbuf);
            document.Accept(writer);
            s_send(*hcs->server_socket_,strbuf.GetString());

            PDEBUG("\033[1;4;32m[%s->%s]\033[0m: %s\n",hcs->multimap_iterator_->first[0].c_str(),hcs->multimap_iterator_->second.c_str(),strbuf.GetString());
        }
    }
}

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

    // adding poller because, when hcs add the service back to event loop, the callback is fired
    // [TODO] investigate and remove the need for polling
    zmq::pollitem_t items = {*hcs->server_socket_, 0, ZMQ_POLLIN, 0 };
    zmq::poll (&items,1,10);

    if(items.revents & ZMQ_POLLIN) {
        // reading the client/dealer socket id
        dealer_id = s_recv(*hcs->server_socket_);
    }
    if(items.revents & ZMQ_POLLIN) {
        // reading the message from client/dealer socket
        read_message = s_recv(*hcs->server_socket_);
        if(hcs->platform_client_mapping_.empty()) {
            // std::cout << "[received message ] "<<read_message<<std::endl;
        }
        if(hcs->platform_client_mapping_.empty() || !hcs->clientExists(dealer_id)) {
            std::vector<std::string> selected_platform_info = hcs->initialCommandDispatch(dealer_id,read_message);
            // strictly for testing alone
            PDEBUG("[selected verbose] %s",selected_platform_info[0].c_str());
            if(!(selected_platform_info[0] == "NONE")) {
                // need to change the following lines to support struct
                std::vector<std::string> map_element;
                map_element.insert(map_element.begin(),selected_platform_info[0]);
                map_element.insert(map_element.begin()+1,"remote");
                // hcs->g_platform_uuid_ = selected_platform_info[0];
                hcs->platform_client_mapping_.emplace(map_element,dealer_id);
                hcs->g_selected_platform_verbose_ = selected_platform_info[0];
                PDEBUG("adding the %s uuid to multimap with %s\n",selected_platform_info[0].c_str(),selected_platform_info[1].c_str());
            }
        } else {
            PDEBUG("Dispatching message to platform/s\n");
            hcs->disptachMessageToPlatforms(dealer_id,read_message);
        }
        // [prasanth] : The following lines are required for the event handling
        // to recognize the next read trigger

        unsigned int     zmq_events;
        size_t           zmq_events_size  = sizeof(zmq_events);
        hcs->server_socket_->getsockopt(ZMQ_EVENTS, &zmq_events, &zmq_events_size);
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
    // PDEBUG("Inside remote callback\n");
    HostControllerService *hcs = (HostControllerService*)args;

    std::string read_message;

    // adding poller because, when hcs add the service back to event loop, the callback is fired
    // [TODO] investigate and remove the need for polling
    zmq::pollitem_t items = {*hcs->remote_socket_, 0, ZMQ_POLLIN, 0 };
    zmq::poll (&items,1,10);

    if(items.revents & ZMQ_POLLIN) {
        // reading the message from client/dealer socket
	      PDEBUG("check1");
        read_message = s_recv(*hcs->remote_socket_);
        PDEBUG("message read %s",read_message.c_str());
        std::string dealer_id;
        hcs->remoteRouting(read_message);
	      PDEBUG("check2");
    }

    unsigned int     zmq_events;
    size_t           zmq_events_size  = sizeof(zmq_events);
    hcs->remote_socket_->getsockopt(ZMQ_EVENTS, &zmq_events, &zmq_events_size);
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
    // char buf[1024];
    // sp_nonblocking_read(hcs->platform_socket_,buf,1024);
    PDEBUG("message being read %s\n",read_message.c_str());
    sp_flush(hcs->platform_socket_,SP_BUF_BOTH);
    // [TODO] [prasanth] change the map value for platform from string to structure
    std::string dealer_id;
    if(hcs->checkPlatformExist(&dealer_id,read_message)) {
        //hcs->sendToClient(dealer_id,read_message);
    }
    else {
        PDEBUG("\033[1;4;32mPLATFORM %s is not connected to any client\033[0m\n",hcs->g_platform_uuid_.c_str());
    }
    //[TODO] [prasanth]: send data to the data bridge through multimap handle
    s_send(*hcs->remote_socket_,read_message);
    unsigned int     zmq_events;
    size_t           zmq_events_size  = sizeof(zmq_events);
    hcs->remote_socket_->getsockopt(ZMQ_EVENTS, &zmq_events, &zmq_events_size);
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
        error = sp_get_port_by_name(port.c_str(), &platform_socket_);
        if (error == SP_OK) {
            error = sp_open(platform_socket_, SP_MODE_READ_WRITE);
            if (error == SP_OK) {
                std::cout << "SERIAL PORT OPEN SUCCESS: " << port << std::endl;
                // Connector::messageProperty message;
                // message.message = "{\"notification\":{\"value\":\"platform_connection_change_notification\",\"payload\":{\"status\":\"connected\"}}}";
                // hostP.service->sendNotification(message, hostP.notify);
                // Reset our flag to output errors when we disconnect
                outputPortError = true;
                return true;
            }
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
    sp_set_stopbits(platform_socket_,1);
    sp_set_bits(platform_socket_,8);
    sp_set_rts(platform_socket_,SP_RTS_OFF);
    sp_set_baudrate(platform_socket_,115200);
    sp_set_dtr(platform_socket_,SP_DTR_OFF);
    sp_set_parity(platform_socket_,SP_PARITY_NONE );
    sp_set_cts(platform_socket_,SP_CTS_IGNORE );

    // sending this json to platform to get the uuid
    // [TODO] Only for intial phase. Future this should be added in better place and
    // it also should wait for response and a timeout event to send it again if
    // it didn't receive the uuid


    // [TODO] [prasanth] move everything to platform callback
    //std::vector<std::string> paltform_message;  // for this project
    // std::string platform_id = parseAndGetPlatformId();
    // [TODO] [prasanth] check for nullptr
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

    Document service_command;
    // [TODO] [prasanth] : needs better organization
    if (service_command.Parse(command.c_str()).HasParseError()) {
        // PDEBUG("ERROR: json parse error!\n");
        return selected_platform;
    }

    // state machine using switch statements
    switch(stringHash(service_command["command"].GetString())) {
        case request_hcs_status:            s_sendmore(*server_socket_,dealer_id);
                                            s_send(*server_socket_,JSON_SINGLE_OBJECT
                                                ("handshake","hcs_active"));
                                            break;
        case request_available_platforms:   PDEBUG("Sending the list of available platform");
                                            s_sendmore(*server_socket_,dealer_id);
                                            s_send(*server_socket_,getPlatformListJson());
                                            break;
        case platform_select:               PDEBUG("The client has selected a platform");
                                            board_name = service_command["platform_uuid"].GetString();
                                            remote_status = service_command["remote"].GetString();
                                            selected_platform.insert(selected_platform.begin(),board_name);
                                            selected_platform.insert(selected_platform.begin()+1,remote_status);
        default:                            return selected_platform;
    }
    getServerSocketEventReady();
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
    multimap_iterator_ = platform_client_mapping_.begin();
    for(multimap_iterator_= platform_client_mapping_.begin();multimap_iterator_!=
                            platform_client_mapping_.end();multimap_iterator_++) {
        PDEBUG("[map iter]");
        if (multimap_iterator_->second == dealer_id) {
            // the following printing is strictly for testing only
            PDEBUG("\033[1;4;31m[%s<-%s]\033[0m: %s\n",multimap_iterator_->first[0].c_str(),dealer_id.c_str(),read_message.c_str());
            // send the message to multimap_iterator_->first (connected platforms)

            // following code are strictly for testing Only
            Document service_command;
            if (service_command.Parse(read_message.c_str()).HasParseError()) {
                PDEBUG("ERROR: json parse error!\n");
                return false;
            }
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
            } else if(multimap_iterator_->first[0] == g_selected_platform_verbose_) {
                if(multimap_iterator_->first[1] == "connected") {
                    PDEBUG("\033[1;4;31mlocal write %s\033[0m\n",multimap_iterator_->first[1].c_str());
                    sp_flush(platform_socket_,SP_BUF_BOTH);
                    read_message += "\n";
                    sp_nonblocking_write(platform_socket_,(void *)read_message.c_str(),read_message.length());
                }
                else if(multimap_iterator_->first[1] == "remote") {
                    PDEBUG("\033[1;4;31mlocal write %s\033[0m\n",multimap_iterator_->first[1].c_str());
                    // sp_flush(platform_socket_,SP_BUF_BOTH);
                    read_message += "\n";
                    s_send(*remote_socket_,read_message);
                    // sp_nonblocking_write(platform_socket_,(void *)read_message.c_str(),read_message.length());
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
    sp_flush(platform_socket_,SP_BUF_BOTH);
    std::string cmd = "{\"cmd\":\"request_platform_id\"}\n";
    sp_blocking_write(platform_socket_,(void *)cmd.c_str(),cmd.length(),5);

    PDEBUG("parseAndGetPlatformId\n");

    bool isPlatformId=false;
    //
    // // platform read will be handled by connector factory and will always be called libevents
    while(!isPlatformId) {
        // std::string ack_message = platformRead();
        std::string platform_id_message = platformRead();

        Document platform_command;
        if (platform_command.Parse(platform_id_message.c_str()).HasParseError()) {
            PDEBUG("ERROR: json parse error in Platform ID section!\n");
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
              std::vector<std::string> map_element;
              map_element.insert(map_element.begin(),platform.platform_verbose);
              map_element.insert(map_element.begin()+1,"connected");
              PDEBUG("[remote routing ] added into map");
              platform_client_mapping_.emplace(map_element,"remote");
              g_platform_uuid_ = platform.platform_verbose;
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
    for(auto platform_list_iterator = platform_uuid_.begin(); platform_list_iterator
                                != platform_uuid_.end();platform_list_iterator++) {
        platform_details platform = *platform_list_iterator;
        if(platform.platform_uuid == remote_platform[0].platform_uuid) {
            PDEBUG("local exists\n");
            return;
        }
    }
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
    // [TODO] [prasanth] : needs better code for reading from serial port
    //  copied this section from current HCS

    // setting the libserial port events
    sp_new_event_set(&ev);
    sp_add_port_events(ev, platform_socket_, SP_EVENT_RX_READY);

    std::vector<char> response;
    sp_return error;
    char temp = '\0';
    while(temp != '\n') {
        sp_wait(ev, 0);
        error = sp_nonblocking_read(platform_socket_,&temp,1);
        if(error <= 0) {
            PDEBUG("Platform Disconnected\n");
            return "disconnected";  // think about this
        }
        if(temp !='\n' && temp!=NULL) {
            response.push_back(temp);
        }
    }
    if(!response.empty()) {
        std::string new_string(response.begin(),response.end());
        PDEBUG("Rx'ed message : %s\n",new_string.c_str());
        response.clear();
        return new_string;
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
    document.AddMember("handshake",nested_object,allocator);
    // document.AddMember("platforms",array,allocator);
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
        // does_platform_exist = (multimap_iterator_->first == g_platform_uuid_);
        std::vector<std::string> map_uuid = multimap_iterator_->first;
        // strictly for testing only
        PDEBUG("[List of Platform]: %s\n",map_uuid[0].c_str());
        PDEBUG("connected paltform uuid%s\n",g_platform_uuid_.c_str());
        PDEBUG("[msg]%s",message.c_str());
        (map_uuid[0] == g_selected_platform_verbose_)?does_platform_exist = true : does_platform_exist = false;
        PDEBUG("The comparison %d\n",(int)does_platform_exist);
        if(does_platform_exist) {
            *dealer_id = multimap_iterator_->second;
            if(!message.empty()) {
              s_sendmore(*server_socket_,*dealer_id);
              s_send(*server_socket_,message);
            }
        }
        multimap_iterator_++;
    }
    return true;
}

void HostControllerService::remoteRouting(std::string message)
{
    // sp_nonblocking_write(platform_socket_,(void *)message.c_str(),message.length());
    std::string dealer_id;
    multimap_iterator_ = platform_client_mapping_.begin();
    while(multimap_iterator_ != platform_client_mapping_.end()) {
        bool does_platform_exist = false;
        // does_platform_exist = (multimap_iterator_->first == g_platform_uuid_);
        std::vector<std::string> map_uuid = multimap_iterator_->first;
        // strictly for testing only
        PDEBUG("[List of Platform]: %s\n",map_uuid[0].c_str());
        PDEBUG("connected paltform uuid%s\n",g_platform_uuid_.c_str());
        PDEBUG("[msg]%s",message.c_str());
        (map_uuid[0] == g_selected_platform_verbose_)?does_platform_exist = true : does_platform_exist = false;
        PDEBUG("The comparison %d\n",(int)does_platform_exist);
        if(does_platform_exist) {
            dealer_id = multimap_iterator_->second;
            PDEBUG("dealer is empty %d",dealer_id.empty());
            if(!message.empty()) {
              if(map_uuid[1] == "remote") {
                  s_sendmore(*server_socket_,dealer_id);
                  s_send(*server_socket_,message);
              } else if (map_uuid[1] == "connected") {
                  PDEBUG("Inside remote writing");
                  sp_nonblocking_write(platform_socket_,(void *)message.c_str(),message.length());
              }
            }
        }
        multimap_iterator_++;
    }
}
