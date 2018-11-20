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
using namespace std;

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
DiscoveryService::DiscoveryService(const std::string& server_address)
{
    service_connector_ = ConnectorFactory::getConnector("request");
    service_connector_->open(server_address);
}

DiscoveryService::~DiscoveryService()
{
    delete service_connector_;
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
    }

    Value& platforms = document["platforms"];
    for(int i=0;i<platforms.Size();i++) {
        remote_platform_details platform_detail;
        platform_detail.platform_uuid = platforms[i]["UUID"].GetString();
        platform_detail.platform_verbose = platforms[i]["verbose"].GetString();
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
    return strbuf.GetString();
}

// @f setJWT
// @b sets the java web token
//
// arguments:
//  IN: jwt string
//
void DiscoveryService::setJWT(const string& jwt)
{
    jwt_string_ = jwt;
}

// @f register platform
// @b sends the platform details to the discovery service
//
// arguments:
//  IN: jwt string
//
// Add a platform: {
//      "token" :"<jwt token from auth-server>", "cmd": "add_platform",
//      "platform_id": <unique platform id>,
//      "name": <platform name>,
//      "hcs": <server id used for mapping>
//      }
bool DiscoveryService::registerPlatform(const string& id, const string& name, const string& hcs_id)
{
    Document document;
    document.SetObject();
    Document::AllocatorType& allocator = document.GetAllocator();

    Value jwt_string_rpj(jwt_string_.c_str(),allocator);
    Value id_rpj(id.c_str(),allocator);
    Value name_rpj(name.c_str(),allocator);
    Value hcs_id_rpj(hcs_id.c_str(),allocator);

    document.AddMember("token",jwt_string_rpj,allocator);
    document.AddMember("cmd","add_platform",allocator);
    document.AddMember("platform_id",id_rpj,allocator);
    document.AddMember("name",name_rpj,allocator);
    document.AddMember("hcs",hcs_id_rpj,allocator);
    StringBuffer strbuf;
    Writer<StringBuffer> writer(strbuf);
    document.Accept(writer);
    service_connector_->send(strbuf.GetString());

    string read_message;
    service_connector_->read(read_message);
    cout << " [Disc service] read message "<< read_message << endl;

    // parse the message received from disc service
    if (document.Parse(read_message.c_str()).HasParseError()) {
        cout<< "json failed\n";
        return false;
    }
    if(document.HasMember("msg")) {
        if((!strcmp(document["msg"].GetString(),"platform added"))
            || (!strcmp(document["msg"].GetString(),"platform updated"))) {
                return true;
        }
        else {
            return false;
        }
    }
    else {
        cout<<"add command failed\n";
        return false;
    }
    cout<<"Add command failed\n";
    return true;
}

// @f register platform
// @b sends the platform details to the discovery service
//
// arguments:
//  IN: jwt string
//
//Remove platform:
//     { "token" :"<jwt token from auth-server>",
//       "cmd": "remove_platform",
//       "platform_id": <unique platform id>
//      }
bool DiscoveryService::deregisterPlatform(const string& platform_id)
{
    Document document;
    document.SetObject();
    Document::AllocatorType& allocator = document.GetAllocator();

    Value jwt_string_rpj(jwt_string_.c_str(),allocator);
    Value platform_id_rpj(platform_id.c_str(),allocator);

    document.AddMember("token",jwt_string_rpj,allocator);
    document.AddMember("cmd","remove_platform",allocator);
    document.AddMember("platform_id",platform_id_rpj,allocator);

    StringBuffer strbuf;
    Writer<StringBuffer> writer(strbuf);
    document.Accept(writer);
    service_connector_->send(strbuf.GetString());

    string read_message;
    service_connector_->read(read_message);
    cout << " [Disc service] read message "<< read_message << endl;
    return true;
}

// @f get remote platform
// @b requests the remote platforms of a particular user
//
// arguments:
//  IN: hcs_token of the remote user to connect
//
// Get platforms for allowed hcs:
//     {
//     "token" :"<jwt token from auth-server>",
//     "cmd":"get_platform",
//     "hcs": <hcs_id>
//     }
bool DiscoveryService::getRemotePlatforms(remote_platforms& remote_platform)
{
    Document document;
    document.SetObject();
    Document::AllocatorType& allocator = document.GetAllocator();

    Value jwt_string_rpj(jwt_string_.c_str(),allocator);
    Value hcs_token_rpj(hcs_token_.c_str(),allocator);


    document.AddMember("token",jwt_string_rpj,allocator);
    document.AddMember("cmd","get_platform",allocator);
    document.AddMember("hcs",hcs_token_rpj,allocator);

    StringBuffer strbuf;
    Writer<StringBuffer> writer(strbuf);
    document.Accept(writer);
    service_connector_->send(strbuf.GetString());

    string read_message;
    service_connector_->read(read_message);
    cout << " [Disc service] read message "<< read_message << endl;

    // parse and get the remote platforms
    if (document.Parse(read_message.c_str()).HasParseError()) {
        cout << " parse error "<< endl;
        return false;
    }
    else {
        cout << "parse success" <<endl;
        const Value& remote_platform_array = document;
        assert(remote_platform_array.IsArray());
        if(remote_platform_array.Empty()) {
            return false;
        }
        for (SizeType i = 0; i < remote_platform_array.Size();i++) {
            remote_platform_details platform_detail;
            platform_detail.platform_uuid = remote_platform_array[i]["_id"].GetString();
            platform_detail.platform_verbose = remote_platform_array[i]["name"].GetString();
            remote_platform.push_back(platform_detail);
        }
        return true;
    }
    return false;
}

// @f sendConnect
// @b establishes connection between two platforms
//
// arguments:
//  IN: platform_uuid of the remote platform
//
// Connect: {
// "token" :"<jwt token from auth-server>", "cmd": "connect",
// "id": <server id used for mapping>,
// "platform_id": <unique platform id>
// }
bool DiscoveryService::sendConnect(const string& platform_uuid, const std::string& hcs_token)
{
    Document document;
    document.SetObject();
    Document::AllocatorType& allocator = document.GetAllocator();
    cout<<"disc service hcs token "<<hcs_token.c_str()<<endl;

    Value jwt_string_rpj(jwt_string_.c_str(),allocator);
    Value hcs_token_rpj(hcs_token.c_str(),allocator);
    Value platform_uuid_rpj(platform_uuid.c_str(),allocator);

    document.AddMember("token",jwt_string_rpj,allocator);
    document.AddMember("cmd","connect",allocator);
    document.AddMember("id",hcs_token_rpj,allocator);
    document.AddMember("platform_id",platform_uuid_rpj,allocator);

    StringBuffer strbuf;
    Writer<StringBuffer> writer(strbuf);
    document.Accept(writer);
    service_connector_->send(strbuf.GetString());

    string read_message;
    service_connector_->read(read_message);
    cout << " [Disc service] read message "<< read_message << endl;

    return true;
}

// Disconnect Remote Users: {
// "token" :"<jwt token from auth-server>", "cmd": "disconnect_remote_user",
// "user": <user_id to be disconnected from the platform>,
// "platform_id": <unique platform id>
// }
bool DiscoveryService::disconnectUser(const string& user_name, const string &platform_id)
{
    Document document;
    document.SetObject();
    Document::AllocatorType& allocator = document.GetAllocator();

    Value jwt_string_rpj(jwt_string_.c_str(),allocator);
    Value user_name_rpj(user_name.c_str(),allocator);
    Value platform_uuid_rpj(platform_id.c_str(),allocator);

    document.AddMember("token",jwt_string_rpj,allocator);
    document.AddMember("cmd","disconnect_remote_user",allocator);
    document.AddMember("user",user_name_rpj,allocator);
    document.AddMember("platform_id",platform_uuid_rpj,allocator);

    StringBuffer strbuf;
    Writer<StringBuffer> writer(strbuf);
    document.Accept(writer);
    service_connector_->send(strbuf.GetString());

    string read_message;
    service_connector_->read(read_message);
    cout << " [Disc service] read message "<< read_message << endl;

    return true;
}

// Disconnect : {
// "token" :"<jwt token from auth-server>", "cmd": "disconnect",
// "platform_id": <unique platform id>
// }
bool DiscoveryService::disconnect(const string& platform_id)
{
    Document document;
    document.SetObject();
    Document::AllocatorType& allocator = document.GetAllocator();

    Value jwt_string_rpj(jwt_string_.c_str(),allocator);
    Value platform_uuid_rpj(platform_id.c_str(),allocator);

    document.AddMember("token",jwt_string_rpj,allocator);
    document.AddMember("cmd","disconnect",allocator);
    document.AddMember("platform_id",platform_uuid_rpj,allocator);

    StringBuffer strbuf;
    Writer<StringBuffer> writer(strbuf);
    document.Accept(writer);
    service_connector_->send(strbuf.GetString());

    string read_message;
    service_connector_->read(read_message);
    cout << " [Disc service] read message "<< read_message << endl;

    return true;
}
