/*
 * main.cpp
 */

#include "HostControllerService.h"

int main(int argc, char *argv[])
{
    std::string configuration_file = "../files/conf/host_controller_service.config";
    try {

        std::cout << "STARTING HOST CONTROLLER SERVICE: config file: " << configuration_file << std::endl;
        HostControllerService host_controller_service(configuration_file);

        // TODO : ian : remove need for while loop. this is nuts to not handle this internally
        while( host_controller_service.wait() == connected_state::DISCONNECTED ) {
            std::cout << "PLATFORM DISCONNECTED: waiting for connect\n";
        }
    }
    catch (const std::exception & e) {
        std::cout << "Host Controller Service failed to start: " << e.what() << std::endl;
        return -1;
    }
    catch (...) {
        std::cout << "Host Controller Service failure: unexpected error\n";
        return -1;
    }

    return 0;
}


