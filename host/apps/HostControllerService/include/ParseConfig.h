//
// Created by Ian Cain on 11/21/17.
//

#ifndef HOSTCONTROLLERSERVICE_PARSECONFIG_H
#define HOSTCONTROLLERSERVICE_PARSECONFIG_H


#include <string>
#include <iostream>
#include <fstream>
#include <ostream>
#include <vector>
#include <sstream>

class ParseConfig {
public:

    ParseConfig(std::string file);
    virtual ~ParseConfig();

    const std::string &GetCommandAddress() const { return command_address_; }
    const std::string &GetSubscriberAddress() const { return subscriber_address_; }
    const std::vector<std::string> &GetSerialPorts() const { return serial_ports_; }
    bool IsSimulatedPlatform() const { return simulated_platform_; }

    const std::string &GetDatabaseServer() const { return database_server_; }
    const std::string &GetGatewaySync() const { return gateway_sync_; }

    friend std::ostream& operator<< (std::ostream& stream, const ParseConfig& config) {
        std::cout << "command_address: " << config.command_address_ << std::endl;
        std::cout << "subscriber_address: " << config.subscriber_address_ << std::endl;
        std::cout << "simulated_platform: " << (config.simulated_platform_ ? "TRUE":"FALSE") << std::endl;
        std::cout << "database_server: " << config.database_server_ << std::endl;
        std::cout << "gateway_sync: " << config.gateway_sync_<< std::endl;
        for (auto &serial_port : config.serial_ports_) {
            std::cout << " + serial port: " << serial_port << std::endl;
        }
        for( auto &channel : config.channels_ ) {
            std::cout << " + channel: " << channel << std::endl;
        }
        return stream;
    }

private:
    // host controller service parameters
    std::string subscriber_address_;
    std::string command_address_;

    // database parameters
    std::string database_server_;
    std::string gateway_sync_;

    // serial port number
    std::vector<std::string> serial_ports_;

    std::vector<std::string> channels_;
    bool simulated_platform_;
};

#endif //HOSTCONTROLLERSERVICE_PARSECONFIG_H
