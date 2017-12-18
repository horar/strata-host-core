/*
 * main.cpp
 */

#include <stdio.h>
#include <fstream>

#include "HostControllerService.h"

using namespace std;

void print_usage(const std::string &error_message)
{
    printf("%s\nusage: hcs -f <configuration_file>\n", error_message.c_str());
}

int main(int argc, char *argv[]) {
    std::string configuration_file = {};

    int option = 0;
    // while ((option = getopt (argc , argv , "f:")) != -1) {
    //     switch (option) {
    //         case 'f' :
    //             configuration_file = optarg;
    //             break;
    //         default:
    //             print_usage ("Unknown argument flag");
    //             exit (EXIT_FAILURE);
    //     }
    // }
    configuration_file = argv[2];

    if( configuration_file.empty () ) {
        print_usage ("No configuration file specified");
        exit (EXIT_FAILURE);
    }

    // check to make sure config file is accessible
    ifstream f(configuration_file.c_str());
    if( ! f.good () ) {
        print_usage ("Configuration file does not exist or not accessible.");
        exit (EXIT_FAILURE);
    }
    f.close();

roller_service(configuration_file);

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
