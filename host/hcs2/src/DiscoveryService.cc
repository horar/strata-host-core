/**
******************************************************************************
* @file DiscoveryService
* @author Prasanth Vivek
* $Rev: 1 $
* $Date: 2018-02-28
* @brief Discovery Service for interaction between HCS and Server
******************************************************************************

* @copyright Copyright 2018 On Semiconductor
*/

#include "DiscoveryService.h"

using namespace rapidjson;
// typedef struct {
//     std::string platform_uuid;
//     std::string platform_verbose;
// } remote_platform_details;
// typedef std::vector<remote_platform_details> remote_platforms;
/******************************************************************************/
/*                                core functions                              */
/******************************************************************************/
// @f constructor
// @b
//
// arguments:
//  IN:
//
//  OUT:
//   void
//
//  ERROR:
//
DiscoveryService::DiscoveryService()
{

}

// @f getPlatforms
// @b returns the json string of list of available platforms
//
// arguments:
//  IN:
//  OUT:
//   json string of available platforms
//
//  ERROR:
//
remote_platforms DiscoveryService::getPlatforms()
{
    // [TODO] [prasanth] the following function is to build the json string that
    // contains the list of available platforms
    std::string platform_list_json = buildPlatformJson();
    remote_platforms remote_platform;

    Document document;   // parse the json
    if (document.Parse(platform_list_json.c_str()).HasParseError()) {
        std::cout<<"ERROR: json parse error!\n";
        // return "NONE";
    }

    Value& platforms = document["platforms"];
    std::cout<<"array size is "<<platforms.Size()<<std::endl;
    for(int i=0;i<platforms.Size();i++) {
        remote_platform_details platform_detail;
        platform_detail.platform_uuid = platforms[i]["UUID"].GetString();
        platform_detail.platform_verbose = platforms[i]["verbose"].GetString();
        std::cout<<"platform uuid "<<platform_detail.platform_uuid<<std::endl;
        remote_platform.push_back(platform_detail);
    }
    return remote_platform;
}

/******************************************************************************/
/*                                utility functions                              */
/******************************************************************************/
// [TODO] [prasanth] : This fucntion will be used only for the initial verison
// will be removed as we move forward

// @f buildPlatformJson
// @b builds the json from the predefined global variables
//
// arguments:
//  IN:
//
//  OUT:
//   std::string that is a json of available platforms
//
//  ERROR:
//
std::string DiscoveryService::buildPlatformJson()
{
    // prepare JSON
    Document document;
    document.SetObject();
    Value array(kArrayType);
    Document::AllocatorType& allocator = document.GetAllocator();

    Value array_object; // create array object
    array_object.SetObject();
    array_object.AddMember("UUID",PLATFORM_UUID,allocator); // add platform uuid
    array_object.AddMember("verbose",PLATFORM_VERBOSE_NAME,allocator);  // add platform verbose name

    array.PushBack(array_object,allocator); // addind the uuid and verbose name to array

    document.AddMember("command","get_remote_platforms",allocator);
    document.AddMember("platforms",array,allocator);
    StringBuffer strbuf;
    Writer<StringBuffer> writer(strbuf);
    document.Accept(writer);
    std::cout<<"remote platforms "<<strbuf.GetString()<<std::endl;
    return strbuf.GetString();
}
