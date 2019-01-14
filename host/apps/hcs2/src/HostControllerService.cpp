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
using namespace std;

AttachmentObserver::AttachmentObserver(void *client_socket,void *client_id_list)
{
    PDEBUG(PRINT_DEBUG,"Attaching the nimbus observer");
    client_connector_ = (Connector *)client_socket;
    client_list_ = (clientList *)client_id_list;
}

void AttachmentObserver::DocumentChangeCallback(jsonString jsonBody) {
    for(const auto& item : *client_list_) {
        client_connector_->setDealerID(item);
        client_connector_->send(jsonBody);
        // [prasanth] : comment the following PDEBUG for faster performance.
        // use it for debugging
        // PDEBUG(PRINT_DEBUG,"[hcs to hcc]%s",jsonBody);
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
HostControllerService::HostControllerService(string configuration_file)
{
    // config file parsing
    configuration_ = new ParseConfig(configuration_file);
    cout<<"************************************************************\n";
    cout<<"CONFIG: \n"<< *configuration_ <<std::endl;
    if(PRINT_DEBUG > 0) {
        cout<< "Console print is enabled\n";
    }
    else {
        cout<< "Console print is disabled\n";
    }
    cout<<"************************************************************\n";
    //[TODO] [prasanth] : rename the terms and variables in config file and
    // parseconfig.cpp for easy understanding
    hcs_server_address_ = configuration_->GetSubscriberAddress();
    hcs_remote_address_ = configuration_->GetRemoteAddress();
    // remote monitor socket address retrieval
    remote_discovery_monitor_ = configuration_->GetDiscoveryMonitorSubscriber();
    // creating discovery service object
    discovery_service_ = new DiscoveryService(configuration_->GetDiscoveryServerID());
    // creating the nimbus object
    database_ = new Nimbus();
    // initializing the connectors
    client_connector_ = ConnectorFactory::getConnector("router");
    serial_connector_ = ConnectorFactory::getConnector("platform");
    remote_connector_ = ConnectorFactory::getConnector("dealer");
    // this connecotr is used for activity monitor from discovery service
    remote_activity_connector_ = ConnectorFactory::getConnector("subscriber");
}

// @f init
// @b initialises the zmq context, socket, nimbus and serial
//
// arguments:
//  IN:
//   open : service socket
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
    // // TODO [prasanth] NIMBUS integration **Needs better organisation
    AttachmentObserver blobObserver((void *)client_connector_, (void *)&clientList);
    database_->Register(&blobObserver);
    // [TODO]: [prasanth] the following lines are used to handle the serial connect/disconnect
    // This method will be removed once we get the serial to socket stuff in
    port_disconnected_ = true;
    //  Setting the connection state to false at start for both remote and client
    remote_connector_->setConnectionState(false);
    client_connector_->setConnectionState(false);
    remote_activity_connector_->setConnectionState(false);
    setEventLoop();
    // [TODO] [prasanth] : This function run is coded in this, since the libevent dynamic
    //addtion of event is not implemented successfully in hcs
    while((int)run());

    return HcsError::NO_ERROR;
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

// [TODO] [prasanth] : This function run is coded in this, since the libevent dynamic
//addtion of event is not implemented successfully in hcs
HcsError HostControllerService::run()
{
    while(!openPlatform()) {
        sleep(0.2);
    }
    PDEBUG(PRINT_DEBUG,"\033[1;32mPlatform detected\033[0m\n");
    initializePlatform(); // init serial config
    port_disconnected_ = false;

    return HcsError::EVENT_BASE_FAILURE;
}

HcsError HostControllerService::setEventLoop()
{
    // get the platform list from the discovery service
    // [TODO] [Prasanth] : Should be added dynamically
    string platformList ;
    getPlatformListJson(platformList);
    platform_details simulated_usb_pd,simulated_motor_vortex,sim_usb;
    simulated_usb_pd.platform_uuid = "P2.2018.1.1.0.0.c9060ff8-5c5e-4295-b95a-d857ee9a3671";
    simulated_usb_pd.platform_verbose = "USB PD Load Board";
    simulated_usb_pd.connection_status = "view";

    simulated_motor_vortex.platform_uuid = "SEC.2017.004.2.0.0.1c9f3822-b865-11e8-b42a-47f5c5ed4fc3";
    simulated_motor_vortex.platform_verbose = "Vortex Fountain Motor Platform Board";
    simulated_motor_vortex.connection_status = "view";

    sim_usb.platform_uuid = "P2.2017.1.1.0.0.cbde0519-0f42-4431-a379-caee4a1494af";
    sim_usb.platform_verbose = "USB PD";
    sim_usb.connection_status = "view";

    platform_uuid_.push_back(simulated_usb_pd);  // for testing alone
    platform_uuid_.push_back(simulated_motor_vortex);
    platform_uuid_.push_back(sim_usb);

    sendMessageToUI(platformList);

    PDEBUG(PRINT_DEBUG,"Starting the event");
    // creating a periodic event for test case
    event_loop_base_ = event_base_new();
    event_init();
    if (!event_loop_base_) {
        PDEBUG(PRINT_DEBUG,"Could not create event base");
        return HcsError::EVENT_BASE_FAILURE;
    }
    timeval seconds = {1, 0};
    event_set(&periodic_event_,-1,EV_TIMEOUT
                        | EV_PERSIST, HostControllerService::testCallback,this);
    event_add(&periodic_event_, &seconds);

    event_set(&service_handler_,client_connector_->getFileDescriptor(),
                        EV_READ | EV_WRITE | EV_PERSIST ,
                        HostControllerService::serviceCallback,this);
    event_add(&service_handler_,NULL);
    event_dispatch();

    return HcsError::NO_ERROR;
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
        if(hcs->serial_connector_->isSpyglassPlatform()) {
            PDEBUG(PRINT_DEBUG,"\033[1;32mPlatform detected\033[0m\n");
            hcs->initializePlatform(); // init serial config
            hcs->port_disconnected_ = false;
#ifdef _WIN32
            event_set(&hcs->platform_handler_,hcs->serial_connector_->getFileDescriptor(), EV_READ | EV_WRITE | EV_PERSIST,
                                           HostControllerService::platformCallback,hcs);
#else
            event_set(&hcs->platform_handler_,hcs->serial_connector_->getFileDescriptor(), EV_READ  | EV_PERSIST,
                                                   HostControllerService::platformCallback,hcs);
#endif
            event_add(&hcs->platform_handler_,NULL);

            // sending the platform list to ui
            string platformList;
            hcs->getPlatformListJson(platformList);
            hcs->sendMessageToUI(platformList);

        }   // end if - availableplatform
    }   // end if - flag that says if port is connected or not
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
    string dealer_id;
    string read_message;
    if(hcs->client_connector_->read(read_message)) {
        dealer_id = hcs->client_connector_->getDealerID();
        if(!hcs->clientExistInList(dealer_id)) {
            PDEBUG(PRINT_DEBUG,"Adding new client to list");
            hcs->clientList.push_back(dealer_id);
        }
        Document service_command;
        if (service_command.Parse(read_message.c_str()).HasParseError()) {
            PDEBUG(PRINT_DEBUG,"ERROR: json parse error!");
        }

        // TODO [ian] add this to a "command_filter" map to add more then just "db::cmd"
        if( service_command.HasMember("db::cmd") ) {
            // [TODO] [prasanth] : verify with Abe. Removing Open after nimbus initialization causes seg fault on this command
            // Hence commeneted out
            // if ( hcs->database_->Command( read_message.c_str() ) != NO_ERRORS ){
            //     PDEBUG(PRINT_DEBUG,"ERROR: database failed failed!");
            // }
        }
        // parsing all the hcs related messages
        // for instance, remote control message,chat
        else if( service_command.HasMember("hcs::cmd") ) {
            hcs->parseHCSCommands(read_message);
        }
        // the following routine is to add the client[ui] into the routing table
        else if(hcs->platform_client_mapping_.empty() || !hcs->clientExists(dealer_id)) {
            std::vector<string> selected_platform_info = hcs->initialCommandDispatch(dealer_id,read_message);
            // strictly for testing alone
            if(!(selected_platform_info[0] == "NONE")) {
                // need to change the following lines to support struct
                std::vector<string> map_element;
                map_element.insert(map_element.begin(),selected_platform_info[0]);
                map_element.insert(map_element.begin()+1,selected_platform_info[1]);
                hcs->platform_client_mapping_.emplace(map_element,dealer_id);
                //  storing the connected platform uuid to a global variable
                // [TODO] [prasanth] This is required later for remote activity subscriber
                // since it is created with platform uuid as filter
                hcs->g_platform_uuid_ = selected_platform_info[0];
                PDEBUG(PRINT_DEBUG,"adding the %s uuid to multimap\n",hcs->g_platform_uuid_.c_str());
                if(selected_platform_info[1] == "remote") {
                    // sending connect message to disc service
                    hcs->handleRemoteConnection(selected_platform_info[0]);
                    // openeing the subscriber socket for remote user connect and disconnect
                    hcs->startActivityMonitorService();
                }
                // constructing JSON for the database to open the channel based on selected platform
                Document document;
                document.SetObject();
                Document::AllocatorType& allocator = document.GetAllocator();
                Value platform_id(selected_platform_info[0].c_str(),allocator);
                Value payload_object;
                payload_object.SetObject();
                payload_object.AddMember("db_name",platform_id,allocator);
                document.AddMember("db::payload",payload_object,allocator);
                document.AddMember("db::cmd","open",allocator);
                StringBuffer strbuf;
                Writer<StringBuffer> writer(strbuf);
                document.Accept(writer);
                PDEBUG(PRINT_DEBUG,"db::cmd %s\n",strbuf.GetString());
                // sending the command to NIMBUS
                if ( hcs->database_->Command( strbuf.GetString() ) != NO_ERRORS ){
                    PDEBUG(PRINT_DEBUG,"ERROR: database failed failed!");
                }
                PDEBUG(PRINT_DEBUG,"adding the %s uuid to multimap\n",selected_platform_info[0].c_str());
            }
        }
        // this section will be invoked, if the client[ui] is already mapped to a platform and
        else {
            PDEBUG(PRINT_DEBUG,"Dispatching message to platform/s\n");
            hcs->disptachMessageToPlatforms(dealer_id,read_message);
        }
    }   // end if - read platform messages
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
    string read_message;
    if (hcs->remote_connector_->read(read_message)) {
        PDEBUG(PRINT_DEBUG,"remote message read %s",read_message.c_str());
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
    HostControllerService *hcs = (HostControllerService*)args;
    string read_message = hcs->platformRead();
    if(!read_message.empty()) {
        PDEBUG(PRINT_DEBUG,"message being read %s\n",read_message.c_str());
        // [TODO] [prasanth] change the map value for platform from string to structure
        hcs->checkPlatformExist(read_message);
        //[TODO] [prasanth]: send data to the data bridge through multimap handle
        // for now we are restricting the send to platform only when customer selects to advertise his/her platform
        if(hcs->remote_connector_->isConnected()) {
            hcs->remote_connector_->send(read_message);
        }
    }
}

// @f remote activity callback
// @b will be invoked when the subscriber to discovery service gets a message
//
// arguments:
//  IN: since it is a static function, this * is passed as input to variable args
//
//  OUT:
//   void
//
void HostControllerService::remoteActivityCallback(evutil_socket_t fd, short what, void* args)
{
    // [TODO] [prasanth] This is just a test case. will clean this as we proceed
    HostControllerService *hcs = (HostControllerService*)args;
    string read_message;
    if (hcs->remote_activity_connector_->read(read_message)) {
        PDEBUG(PRINT_DEBUG,"data activity message read %s",read_message.c_str());
        hcs->handleRemoteActivity(read_message);
    }
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
    string platform_port_name;
    if(serial_connector_->open(platform_port_name)) {
        port_disconnected_ = false;
        return true;
    }
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
    // clearing the list
    platform_uuid_.clear();

    platform_details simulated_usb_pd,simulated_motor_vortex,sim_usb;
    simulated_usb_pd.platform_uuid = "P2.2018.1.1.0.0.c9060ff8-5c5e-4295-b95a-d857ee9a3671";
    simulated_usb_pd.platform_verbose = "USB PD Load Board";
    simulated_usb_pd.connection_status = "view";

    simulated_motor_vortex.platform_uuid = "SEC.2017.004.2.0.0.1c9f3822-b865-11e8-b42a-47f5c5ed4fc3";
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
std::vector<string> HostControllerService::initialCommandDispatch(const std::string& dealer_id,const std::string& command)
{
    // [TODO]: [prasanth] should be removed after bod demo
    std::vector<string> selected_platform;
    selected_platform.insert(selected_platform.begin(),"NONE");
    selected_platform.insert(selected_platform.begin()+1,"NONE");
    string board_name,remote_status ;
    client_connector_->setDealerID(dealer_id);
    Document service_command;
    // [TODO] [prasanth] : needs better organization
    if (service_command.Parse(command.c_str()).HasParseError()) {
        PDEBUG(PRINT_DEBUG,"ERROR: json parse error!\n");
        return selected_platform;
    }
    // state machine using switch statements
    string platformList;
    CommandDispatcherMessages message = stringHash(service_command["cmd"].GetString());
    switch(message) {
        case CommandDispatcherMessages::REQUEST_HCS_STATUS:
                                            client_connector_->send(JSON_SINGLE_OBJECT
                                                ("hcs::notification","hcs_active"));
                                            break;
        case CommandDispatcherMessages::REGISTER_CLIENT:
        case CommandDispatcherMessages::REQUEST_AVAILABLE_PLATFORMS:
                                            PDEBUG(PRINT_DEBUG,"Sending the list of available platform");
                                            getPlatformListJson(platformList);
                                            client_connector_->send(platformList);
                                            break;
        case CommandDispatcherMessages::PLATFORM_SELECT:
                                            PDEBUG(PRINT_DEBUG,"The client has selected a platform");
                                            board_name = service_command["platform_uuid"].GetString();
                                            remote_status = service_command["remote"].GetString();
                                            selected_platform.insert(selected_platform.begin(),board_name);
                                            selected_platform.insert(selected_platform.begin()+1,remote_status);
                                            return selected_platform;
        default:
            assert(false);
            break;
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
bool HostControllerService::disptachMessageToPlatforms(const std::string& dealer_id,std::string& read_message)
{
    for(const auto& item : platform_client_mapping_) {
        if (item.second == dealer_id) {
            // the following printing is strictly for testing only
            PDEBUG(PRINT_DEBUG,"\033[1;4;31m[%s<-%s]\033[0m: %s\n",item.first[0].c_str(), dealer_id.c_str(),read_message.c_str());
            Document service_command;
            if(!read_message.empty()) {
                if (service_command.Parse(read_message.c_str()).HasParseError()) {
                    PDEBUG(PRINT_DEBUG,"ERROR: json parse error!\n");
                    return false;
                }
            }
            if(service_command.HasMember("cmd")) {
                string command = service_command["cmd"].GetString();

                //TODO: check if first has some items...
                if(item.first[1] == "connected") {
                    PDEBUG(PRINT_DEBUG,"\033[1;4;31mlocal write %s\033[0m\n",item.first[1].c_str());
                    if(serial_connector_->send(read_message)) {
                        PDEBUG(PRINT_DEBUG,"\033[1;4;33mWrite success %s\033[0m",read_message.c_str());
                    }
                }
                else if(item.first[1] == "remote") {
                    PDEBUG(PRINT_DEBUG,"\033[1;4;31mlocal write %s\033[0m\n",item.first[1].c_str());
                    // parsing the message and add the user name field to the message
                    // This si required for only remote client[FAE] to notify the customer that the command is sent from
                    // FAE with FAE username
                    appendUsername(read_message);
                    remote_connector_->send(read_message);
                }
            }   // end if - json check for member "cmd"
        }   // end if - check if user is connected to a platform or remote
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
CommandDispatcherMessages HostControllerService::stringHash(const std::string& command)
{
    if(command == "request_hcs_status") {
        return CommandDispatcherMessages::REQUEST_HCS_STATUS;
    }
    else if (command == "request_available_platforms") {
        return CommandDispatcherMessages::REQUEST_AVAILABLE_PLATFORMS;
    }
    else if (command == "platform_select") {
        return CommandDispatcherMessages::PLATFORM_SELECT;
    }
    else if (command == "register_client") {
        return CommandDispatcherMessages::REGISTER_CLIENT;
    }

    return CommandDispatcherMessages::COMMAND_NOT_FOUND;
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
    PDEBUG(PRINT_DEBUG,"parseAndGetPlatformId\n");
    platform_details platform;
    platform.platform_uuid = serial_connector_->getPlatformUUID();
    platform.platform_verbose = serial_connector_->getDealerID();
    // [TODO] [prasanth] storing the plat_id and plat_verbose for supporting disc service temporary
    g_selected_platform_verbose_ = serial_connector_->getDealerID();
    // [TODO] [prasanth] : change the dealer_id var name to platform id
    g_dealer_id_ = serial_connector_->getPlatformUUID();
    platform.connection_status = "connected";
    platform_uuid_.push_back(platform);
    return true;
}

// @f parseHCSCommands
// @b gets the json encoded string parses and routes to the appropriate routine
//
// arguments:
//  IN: json encoded string {!!! Expects only the HCS spedific commands}
//
void HostControllerService::parseHCSCommands(const string &hcs_message)
{
    PDEBUG(PRINT_DEBUG,"parsing the commands for HCS from client %s\n",hcs_message.c_str());
    Document hcs_command;
    if (hcs_command.Parse(hcs_message.c_str()).HasParseError()) {
        PDEBUG(PRINT_DEBUG,"json failed\n");
        return;
    }
    else if(!(strcmp(hcs_command["hcs::cmd"].GetString(),"jwt_token"))) {
        if(hcs_command["payload"].HasMember("jwt")) {
            PDEBUG(PRINT_DEBUG,"adding the JWT\n");
            string jwt = hcs_command["payload"]["jwt"].GetString();
            discovery_service_->setJWT(jwt);
            user_name_ = hcs_command["payload"]["user_name"].GetString();
            // store them as lower case, since we use the username to check with
            // discovery service subscriber socket value of usernames that are always
            // lower case
            transform(user_name_.begin(),user_name_.end(),user_name_.begin(), ::tolower);
        }
    }
    else if(!(strcmp(hcs_command["hcs::cmd"].GetString(),"advertise"))) {
        if(hcs_command["payload"].HasMember("advertise_platforms")) {
          bool remote_advertise = hcs_command["payload"]["advertise_platforms"].GetBool();
          PDEBUG(PRINT_DEBUG,"is remote session ON? %d",remote_advertise);
          handleRemotePlatformRegistration(remote_advertise);
        }
    }
    //  {"hcs::cmd":"get_platforms","payload":{"hcs_token":"dasfs"}}
    else if(!(strcmp(hcs_command["hcs::cmd"].GetString(),"get_platforms"))) {
        if(hcs_command["payload"].HasMember("hcs_token")) {
          discovery_service_->setHCSToken(hcs_command["payload"]["hcs_token"].GetString());
          PDEBUG(PRINT_DEBUG,"the token required to connect is %s",discovery_service_->getHCSToken().c_str());
          handleRemoteGetPlatforms();
        }
    }
    // handle remote disconnect from FAE
    else if(!(strcmp(hcs_command["hcs::cmd"].GetString(),"remote_disconnect"))) {
        // FAE when opts out of remote connection, the "disconnect" string is sent to bridge service
        if(remote_connector_->isConnected()) {
            remote_connector_->send("disconnect");
            discovery_service_->disconnect(g_platform_uuid_);
            sendDisconnecttoUI();
            // platformDisconnectRoutine();
            platform_uuid_.remove_if([](platform_details remote){ return remote.connection_status == "remote"; });
            platform_client_mapping_.clear();
            event_del(&remote_handler_);
            if(remote_activity_connector_->isConnected()) {
                event_del(&activity_handler_);
            }
            remote_connector_->close();
        }
    }
    // disconnect a particular user
    else if(!(strcmp(hcs_command["hcs::cmd"].GetString(),"disconnect_remote_user"))) {
        if(hcs_command["payload"].HasMember("user_name")) {
          string remote_user = hcs_command["payload"]["user_name"].GetString();
          PDEBUG(PRINT_DEBUG,"disconnecting remote user %s",remote_user.c_str());
          discovery_service_->disconnectUser(remote_user,g_dealer_id_);
        }
    }
    else if(!(strcmp(hcs_command["hcs::cmd"].GetString(),"disconnect_platform"))) {
        PDEBUG(PRINT_DEBUG,"User has requested to disconnect from platform\n");
        platform_client_mapping_.clear();
    }
    else if(!(strcmp(hcs_command["hcs::cmd"].GetString(),"unregister"))) {
        PDEBUG(PRINT_DEBUG,"User has disconnected\n");
        platform_client_mapping_.clear();
    }
}

// @f handleRemotePlatformRegistration
// @b creates the socket dealer id for bridge service,sends token to UI, adds plat to disc service
//
void HostControllerService::handleRemotePlatformRegistration(bool remote_advertise)
{
    if(remote_advertise) {
        remote_connector_->setConnectionState(remote_advertise);
        startRemoteService();
        startActivityMonitorService();
        bool status = discovery_service_->registerPlatform(g_dealer_id_,g_selected_platform_verbose_,dealer_remote_socket_id_);
        Document document;
        document.SetObject();
        Document::AllocatorType& allocator = document.GetAllocator();

        Value payload_object;
        payload_object.SetObject();
        payload_object.AddMember("status",status,allocator);
        if(status) {
            Value hcs_id_rpj(dealer_remote_socket_id_.c_str(),allocator);
            payload_object.AddMember("hcs_id",hcs_id_rpj,allocator);
        }
        else {
            Value hcs_id_rpj("Request Failed",allocator);
            payload_object.AddMember("hcs_id",hcs_id_rpj,allocator);
        }
        Value nested_object;
        nested_object.SetObject();
        Value cmd_rpj("advertise_platforms",allocator);
        nested_object.AddMember("value",cmd_rpj,allocator);
        nested_object.AddMember("payload",payload_object,allocator);
        document.AddMember("remote::notification",nested_object,allocator);
        StringBuffer strbuf;
        Writer<StringBuffer> writer(strbuf);
        document.Accept(writer);
        client_connector_->send(strbuf.GetString());
    }
    else {
        if(remote_connector_->isConnected()) {
            bool status = discovery_service_->deregisterPlatform(g_dealer_id_);
            event_del(&remote_handler_);
            event_del(&activity_handler_);
            string disconnect_message = "{\"notification\":{\"value\":\"platform_connection_change_notification\",\"payload\":{\"status\":\"disconnected\"}}}";
            remote_connector_->send(disconnect_message);
            remote_connector_->close();
        }
    }
}

// @f handleRemoteGetPlatforms
// @b on request from client, reads the token from client and send get platform request to
// discovery server. gets ack/nack from server and forwards them to client
//
void HostControllerService::handleRemoteGetPlatforms()
{
    bool get_platform_success = false;
    if(discovery_service_->getHCSToken().empty()) {
        PDEBUG(PRINT_DEBUG," Invalid Token for remote connection\n");
    }
    else {
        remote_platforms remote_platform;
        get_platform_success = discovery_service_->getRemotePlatforms(remote_platform);
        if(get_platform_success) {
            remote_connector_->setConnectionState(true);
            startRemoteService();
            addToLocalPlatformList(remote_platform);
            string platformList ;
            getPlatformListJson(platformList);
            PDEBUG(PRINT_DEBUG,"[hcs to hcc]%s",platformList.c_str());
            client_connector_->send(platformList);
        }
    }

    Document document;
    document.SetObject();
    Document::AllocatorType& allocator = document.GetAllocator();
    Value payload_object;
    payload_object.SetObject();
    payload_object.AddMember("status",get_platform_success,allocator);

    Value nested_object;
    nested_object.SetObject();
    nested_object.AddMember("value","get_platforms",allocator);
    nested_object.AddMember("payload",payload_object,allocator);
    document.AddMember("remote::notification",nested_object,allocator);
    StringBuffer strbuf;
    Writer<StringBuffer> writer(strbuf);
    document.Accept(writer);
    PDEBUG(PRINT_DEBUG,"[hcs to hcc]%s",strbuf.GetString());
    client_connector_->send(strbuf.GetString());
}

// @f handleRemoteConnection
// @b once the user selects the platform from the list, hcs sends the connect to discovery server
//
void HostControllerService::handleRemoteConnection(const std::string& platform_id)
{
    bool status = discovery_service_->sendConnect(platform_id,dealer_remote_socket_id_);
    cout<<"connection zmq "<<dealer_remote_socket_id_<<endl;
}

// @f handleRemoteActivity
// @b the json string that contains the user's name who are connected remotely
//
void HostControllerService::handleRemoteActivity(const std::string& platform_activity)
{
    Document command;
    string remote_user_name;

    // sending the user name to client
    Document document;
    document.SetObject();
    Document::AllocatorType& allocator = document.GetAllocator();
    Value nested_object;
    nested_object.SetObject();

    if (command.Parse(platform_activity.c_str()).HasParseError()) {
        PDEBUG(PRINT_DEBUG,"json failed\n");
        return;
    }
    else if(!(strcmp(command["msg"].GetString(),"remote_user_connected"))) {
        if(command.HasMember("user_name") && remote_connector_->isConnected()) {
            remote_user_name = command["user_name"].GetString();
            nested_object.AddMember("value","remote_user_added",allocator);
        }
        else {
            return;
        }
    }
    else if(!(strcmp(command["msg"].GetString(),"remote_user_disconnected"))) {
        remote_user_name = command["user_name"].GetString();
        //  [prasanth] Adding the remote_advertise to check if the hcs is the publisher or only remote
        // If it is a publisher then no need to disconnect
        if(!remote_connector_->isConnected() && (remote_user_name == user_name_)) {
            event_del(&remote_handler_);
            event_del(&activity_handler_);
            platform_uuid_.remove_if([](platform_details remote){ return remote.connection_status == "remote"; });
            platform_client_mapping_.clear();
            sendDisconnecttoUI();
            remote_connector_->close();
            return;
        }
        nested_object.AddMember("value","remote_user_removed",allocator);
    }
    else {
        return;
    }
    Value username_rpj(remote_user_name.c_str(),allocator);
    Value payload_object;
    payload_object.SetObject();
    payload_object.AddMember("user_name",username_rpj,allocator);
    nested_object.AddMember("payload",payload_object,allocator);
    document.AddMember("remote::notification",nested_object,allocator);
    StringBuffer strbuf;
    Writer<StringBuffer> writer(strbuf);
    document.Accept(writer);
    client_connector_->send(strbuf.GetString());
    PDEBUG(PRINT_DEBUG,"Remote user message to UI %s",strbuf.GetString());
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
    for(int i=0;i<remote_platform.size();i++) {
        platform_details platform;
        platform.platform_uuid = remote_platform[i].platform_uuid;
        platform.platform_verbose = remote_platform[i].platform_verbose;
        platform.connection_status = "remote";
        platform_uuid_.push_back(platform);
    }
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
string HostControllerService::platformRead()
{
    string notification;
    if (serial_connector_->read(notification)) {
        return notification;
    }
    else {
        platformDisconnectRoutine();
        return "NULL";
    }
}

void HostControllerService::platformDisconnectRoutine ()
{
    PDEBUG(PRINT_DEBUG,"Platform Disconnected\n");
    sendDisconnecttoUI();

    if(remote_connector_->isConnected()) {
        bool status = discovery_service_->deregisterPlatform(g_dealer_id_);
        event_del(&remote_handler_);
        event_del(&activity_handler_);
        string disconnect_message = "{\"notification\":{\"value\":\"platform_connection_change_notification\",\"payload\":{\"status\":\"disconnected\"}}}";
        remote_connector_->send(disconnect_message);
        remote_connector_->close();
    }

    platform_uuid_.clear();
    platform_client_mapping_.clear();



    platform_details simulated_usb_pd,simulated_motor_vortex,sim_usb;
    simulated_usb_pd.platform_uuid = "P2.2018.1.1.0.0.c9060ff8-5c5e-4295-b95a-d857ee9a3671";
    simulated_usb_pd.platform_verbose = "USB PD Load Board";
    simulated_usb_pd.connection_status = "view";

    simulated_motor_vortex.platform_uuid = "SEC.2017.004.2.0.0.1c9f3822-b865-11e8-b42a-47f5c5ed4fc3";
    simulated_motor_vortex.platform_verbose = "Vortex Fountain Motor Platform Board";
    simulated_motor_vortex.connection_status = "view";

    sim_usb.platform_uuid = "P2.2017.1.1.0.0.cbde0519-0f42-4431-a379-caee4a1494af";
    sim_usb.platform_verbose = "USB PD";
    sim_usb.connection_status = "view";

    platform_uuid_.push_back(simulated_usb_pd);  // for testing alone
    platform_uuid_.push_back(simulated_motor_vortex);
    platform_uuid_.push_back(sim_usb);

    string platformList;
    getPlatformListJson(platformList);
    sendMessageToUI(platformList);

    if (!port_disconnected_) {
        event_del(&platform_handler_);
        port_disconnected_ = true;
        // close the serial port
        serial_connector_->close();
        // clear global for storing the platform id
        g_dealer_id_.clear();
        g_selected_platform_verbose_.clear();
    }
}

void HostControllerService::sendMessageToUI(const std::string& message)
{
    for(const auto& item : clientList) {
        client_connector_->setDealerID(item);
        client_connector_->send(message);
        PDEBUG(PRINT_DEBUG,"[hcs to hcc]%s", message.c_str());
    }
}

// @f sendDisconnecttoUI
// @b sends the platform disconnected(local/remote) message to UI
//
void HostControllerService::sendDisconnecttoUI()
{
    string disconnect_message = "{\"notification\":{\"value\":\"platform_connection_change_notification\",\"payload\":{\"status\":\"disconnected\"}}}";
    sendMessageToUI(disconnect_message);
}

// @f getPlatformListJson
// @b uses RapidJSON to create json message with list of available platforms
//
// arguments:
//  IN: string pointer that will store the platform list
//
//  OUT:
//
//
void HostControllerService::getPlatformListJson(string &list)
{
    // document is the root of a json message
    Document document;
    // define the document as an object rather than an array
    document.SetObject();
    Value array(kArrayType);
    Document::AllocatorType& allocator = document.GetAllocator();
    // traversing through the list
    for(const platform_details& platform : platform_uuid_)
    {
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
    list = strbuf.GetString();
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
bool HostControllerService::clientExists(const string& client_identifier)
{
    for(const auto& item : platform_client_mapping_) {
        if (item.second == client_identifier) {
            return true;
        }
    }
    return false;
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
bool HostControllerService::clientExistInList(const string& client_identifier)
{
    for(const auto& item : clientList) {
        if (item == client_identifier) {
            return true;
        }
    }
    return false;
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
bool HostControllerService::checkPlatformExist(const std::string& message)
{
    for(const auto& item : platform_client_mapping_) {
        // bool does_platform_exist = false;
        string dealer_id = item.second;
        if(!message.empty()) {
          client_connector_->setDealerID(dealer_id);
          client_connector_->send(message);
        }
    }
    return true;
}

// @f remoteRouting
// @b handles the message read by the remote socket
//
// arguments:
//  IN: message read by the remote socket
//
void HostControllerService::remoteRouting(const std::string& message)
{
    if(message.empty()) {
        return;
    }
    Document document;
    if (document.Parse(message.c_str()).HasParseError()) {
        cout<< "json failed\n";
        return ;
    }
    else {
        // [prasanth]: [remote]: when the customer decides to stop advertising the platform,
        // the customer's HCS should send this "platform_change_notification" to all the remote
        // connected users [FAEs] through bridge service
        if(document.HasMember("notification")) {
            if(document["notification"].HasMember("value")) {
                if(document["notification"]["value"] == "platform_connection_change_notification") {
                    event_del(&remote_handler_);
                    event_del(&activity_handler_);
                    platform_uuid_.remove_if([](platform_details remote){ return remote.connection_status == "remote"; });
                    platform_client_mapping_.clear();
                    sendDisconnecttoUI();
                    remote_connector_->close();
                    return;
                } // end if the value matches
            } // end if the json has the required key-value
        } // end if the json has the required key-value
    }

    for(const auto& item : platform_client_mapping_) {
        // bool does_platform_exist = false;
        std::vector<string> map_uuid = item.first;
        string dealer_id = item.second;
        if(map_uuid[1] == "remote") {
            client_connector_->setDealerID(dealer_id);
            client_connector_->send(message);
        }
        else if ((map_uuid[1] == "connected")) {
            PDEBUG(PRINT_DEBUG,"Inside remote writing %s with dealer id %s",message.c_str(),dealer_id.c_str());
            serial_connector_->send(message);
            // [prasanth]: the customer HCS on receiving the commands from FAE should parse the message
            // and take the username and send it to UI client for activity monitor
            retrieveUsername(message);
        }
    }
}

// @f startRemoteService
// @b on invoked, will create the remote connector
//
// arguments:
//  IN: client/dealer socket identifier
//
//  OUT:
//   true if it exists in map and false if it does not
//
void HostControllerService::startRemoteService()
{
    generateHCSToken(dealer_remote_socket_id_,HCSTOKEN_LENGTH);
    remote_connector_->setDealerID(dealer_remote_socket_id_.c_str());
    cout<< "the token generated is "<<dealer_remote_socket_id_<<endl;
    remote_connector_->open(hcs_remote_address_);

    event_set(&remote_handler_,remote_connector_->getFileDescriptor(),
                        EV_READ | EV_WRITE | EV_PERSIST ,
                        HostControllerService::remoteCallback,this);

    event_add(&remote_handler_, NULL);
}

// @f startActivityMonitorService
// @b on invoked, will create the subscriber connector
//
// arguments:
//  IN: client/dealer socket identifier
//
//  OUT:
//   true if it exists in map and false if it does not
//
void HostControllerService::startActivityMonitorService()
{
    remote_activity_connector_->setDealerID(g_platform_uuid_.c_str());
    remote_activity_connector_->open(remote_discovery_monitor_);

    event_set(&activity_handler_,remote_activity_connector_->getFileDescriptor(),
                        EV_READ | EV_WRITE | EV_PERSIST ,
                        HostControllerService::remoteActivityCallback,this);

    event_add(&activity_handler_, NULL);
}

// @f generateHCSToken
// @b creates an alpha numeric string that acts as second token
//
// arguments:
//  IN: string and length required for the token
//
void HostControllerService::generateHCSToken(string& token_string, const int token_length)
{
    auto randchar = []() -> char
    {
        const char charset[] =
        "0123456789"
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        const size_t max_index = (sizeof(charset) - 1);
        return charset[ rand() % max_index ];
    };
    srand(time(0));
    std::generate_n( token_string.begin(), token_length, randchar );
}

// @f appendUsername
// @b takes the json message as input and adds the username to it
//
// arguments:
//  IN: json string
//
void HostControllerService::appendUsername(string& json_message)
{
    Document document;
    document.SetObject();
    Document::AllocatorType& allocator = document.GetAllocator();

    if (document.Parse(json_message.c_str()).HasParseError()) {
        cout<< "json failed\n";
        return ;
    }
    else {
        Value username_rpj(user_name_.c_str(),allocator);
        document.AddMember("user_name",username_rpj,allocator);

        StringBuffer strbuf;
        Writer<StringBuffer> writer(strbuf);
        document.Accept(writer);
        json_message = strbuf.GetString();
        cout<<"json after adding user name "<<json_message<<endl;
    }
}

// @f retrieveUserName
// @b takes the json message from bridge service as input and retrieves
// the username and sends to ui
//
// arguments:
//  IN: json string
//
void HostControllerService::retrieveUsername(const string& json_message)
{
    Document command;
    string remote_user_name;
    if (command.Parse(json_message.c_str()).HasParseError()) {
        PDEBUG(PRINT_DEBUG,"json failed\n");
        return;
    }
    if(command.HasMember("user_name")) {
        remote_user_name = command["user_name"].GetString();
    }
    else {
        return;
    }
    // sending the user name to client
    Document document;
    document.SetObject();
    Document::AllocatorType& allocator = document.GetAllocator();

    Value username_rpj(remote_user_name.c_str(),allocator);
    Value payload_object;
    payload_object.SetObject();
    payload_object.AddMember("user_name",username_rpj,allocator);
    Value nested_object;
    nested_object.SetObject();
    nested_object.AddMember("value","remote_activity",allocator);
    nested_object.AddMember("payload",payload_object,allocator);
    document.AddMember("remote::notification",nested_object,allocator);
    StringBuffer strbuf;
    Writer<StringBuffer> writer(strbuf);
    document.Accept(writer);
    client_connector_->send(strbuf.GetString());
}
