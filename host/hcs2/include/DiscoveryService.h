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

//hardcoded json string
#define PLATFORM_UUID "P2.2017.1.1.0.0.cbde0519-0f42-4431-a379-caee4a1494af"
#define PLATFORM_VERBOSE_NAME  "Vortex Fountain Motor Platform Board"

typedef struct {
    std::string platform_uuid;
    std::string platform_verbose;
} remote_platform_details;
typedef std::vector<remote_platform_details> remote_platforms;

class DiscoveryService {
public:
    //Constructor
    DiscoveryService();

    // core functions
    remote_platforms getPlatforms();  // returns the json string of list of available platforms
    void registerPlatforms();   // register the platforms
    void connectPlatform();     // connect to a platform

    // utility functions
    // [TODO] [Prasanth] this fucntion is for building the json string
    // should be removed as we move forward
    std::string buildPlatformJson();
private:

};
#endif
