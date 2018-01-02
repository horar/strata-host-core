/*
 * main.cpp
 */

#include <stdio.h>
#include <fstream>
#include <SimpleOpt.h>

#include "HostControllerService.h"

using namespace std;

enum { OPT_HELP, OPT_ARG };
CSimpleOpt::SOption g_rgOptions[] = {
        { OPT_ARG,  "-f",     SO_REQ_SEP },
        { OPT_HELP, "-?",     SO_NONE    },
        { OPT_HELP, "-h",     SO_NONE    },
        { OPT_HELP, "--help", SO_NONE    },
        SO_END_OF_OPTIONS
};

void print_usage(const std::string &error_message)
{
    printf("%s\nusage: hcs -f <configuration_file> [-?] [--help]\n", error_message.c_str());
}

int main(int argc, char *argv[])
{
    std::string configuration_file = {};

    if( argc <= 1 ) {
        print_usage("missing arguments");
        exit (EXIT_FAILURE);
    }

    CSimpleOpt args(argc, argv, g_rgOptions);
    while ( args.Next() ) {

        if (args.LastError() != SO_SUCCESS) {
            print_usage("Help: ");
            exit(1);
        }

        switch (args.OptionId()) {
            case OPT_HELP:
                print_usage("help: ");
                exit(0);

            case OPT_ARG:
                string argument = args.OptionText();
                if( argument == "-f" ) {
                    printf("!!!!!!!!!!!!!!!!! %s\n", args.OptionArg());
                    configuration_file = args.OptionArg();
                }
                break;
        }
    }

    // check to make sure config file is accessible
    ifstream f(configuration_file.c_str());
    if( ! f.good () ) {
        print_usage ("Configuration file does not exist or not accessible.");
        exit (EXIT_FAILURE);
    }
    f.close();

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
