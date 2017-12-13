//
// Created by Ian Cain on 11/21/17.
//

#include "ParseConfig.h"
#include "rapidjson/document.h"

using namespace std;
using namespace rapidjson;

ParseConfig::ParseConfig(std::string file) :
        subscriber_address_("not_set"),
        command_address_("not_set"),
        simulated_platform_(false) {

    std::ifstream config_file(file);
    if( !config_file ) {
        cout << "ERROR: config file read error: " << file << std::endl;
        return;
    }

    // read entire file at once. typically small file so not a huge performance hit
    std::string config_json((std::istreambuf_iterator<char>(config_file)),
                            std::istreambuf_iterator<char>());

    Document configuration;
    if (configuration.Parse<kParseCommentsFlag>(config_json.c_str()).HasParseError()) {
        cout << "ERROR: json parse error!\n";
        return;
    }

    if( ! configuration.HasMember("host_controller_service") ) {
        cout << "ERROR: No Host Controller Configuration parameters !!! \n";
        return;
    }

    // host controller service
    Value& hcs_config = configuration["host_controller_service"];
    subscriber_address_ = hcs_config["subscriber_address"].GetString();
    command_address_ = hcs_config["command_address"].GetString();

    // parse optional parameters
    if( hcs_config.HasMember("simulated_platform") ) {
        simulated_platform_ = hcs_config["simulated_platform"].GetBool ();
    }

    // database
    if( ! configuration.HasMember("database") ) {
        cout << "ERROR: No database configuration parameters !!! \n";
        return;
    }

    Value& database_config = configuration["database"];
    database_server_ = database_config["server"].GetString();
    gateway_sync_ = database_config["gateway_sync"].GetString();

    Value& channels = database_config["channels"];
    if( channels.IsArray ()) {
        for (int i = 0; i < channels.Size(); i++) {
            string channel = channels[i].GetString();
            channels_.push_back (channel);
        }
    }

    config_file.close();
}

ParseConfig::~ParseConfig() {}
