/**
******************************************************************************
* @file DiscoveryService.h
* @author Prasanth Vivek
* $Rev: 1 $
* $Date: 2018-02-28
* @brief Implements the public Class for Discovery Service
******************************************************************************

* @copyright Copyright 2018 On Semiconductor
*/
#ifndef DISCOVERY_SERVICE_H
#define DISCOVERY_SERVICE_H

// standard library
#include <iostream>
#include <sstream>
#include <string>
#include <vector>

// project library
#include "Logger.h"

// rapidjson libraries
#include "rapidjson/document.h"
#include <rapidjson/writer.h>
#include <rapidjson/stringbuffer.h>

// connector factory
#include "Connector.h"

//hardcoded json string
#define PLATFORM_UUID "motorvortex1"
#define PLATFORM_VERBOSE_NAME  "Vortex Fountain Motor Platform Board"

typedef struct {
    std::string platform_uuid;
    std::string platform_verbose;
} remote_platform_details;
typedef std::vector<remote_platform_details> remote_platforms;

class DiscoveryService {
public:
    //Constructor
    DiscoveryService(const std::string&);
    ~DiscoveryService();

    // core functions
    remote_platforms getPlatforms();  // returns the json string of list of available platforms
    void registerPlatforms();   // register the platforms
    void connectPlatform();     // connect to a platform

    // utility functions
    // [TODO] [Prasanth] this fucntion is for building the json string
    // should be removed as we move forward
    std::string buildPlatformJson();

    void setJWT(const std::string&); // to set the Java Web Token

    // advertising platforms to discovery service
    bool registerPlatform(const std::string&, const std::string&, const std::string&);
    // removing the platform from discovery service
    bool deregisterPlatform(const std::string&);
    // get remote platform
    bool getRemotePlatforms(remote_platforms&);
    // establishing connection between two hcs
    bool sendConnect(const std::string&, const std::string&);

    bool disconnectUser(const std::string&,const std::string&);
    bool disconnect(const std::string&);
    // set and get hcs token for discovery service
    void setHCSToken(const std::string& token) { hcs_token_ = token; }
    const std::string &getHCSToken() const { return hcs_token_; }
private:
    std::string jwt_string_;
    std::string hcs_token_;

    Connector *service_connector_ ;
};

#endif
