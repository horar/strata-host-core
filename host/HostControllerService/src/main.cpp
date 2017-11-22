/*
 * main.cpp
 */

#include "HostControllerService.h"


int main(int argc, char *argv[])
{
    string routerIp,pubIp;

    if ((!(strcmp(argv[1],"-help"))) || (!(strcmp(argv[1],"-h")))) {
        cout << endl;
        cout << "Argument 1 = Ip address for ZMQ_ROUTER Socket" <<endl;
        cout << "Arg 1 will be used for HostControllerClient to send and receive" <<endl;
        cout << "Argument 2 = Ip address for ZMQ_PUB Socket" <<endl;
        cout << "Arg 2 will be used for HostControllerClient to receive platform notification" <<endl;
        exit(0);
    }
    else {
        routerIp = argv[1];
        cout << "router Ip = " << routerIp <<endl;
        pubIp = argv[2];
        cout << "pub Ip = " << pubIp << endl;
    }

    try {
        HostControllerService host_controller_service(routerIp, pubIp);
        while( host_controller_service.wait() == connected_state::DISCONNECTED ) {
            std::cout << "PLATFORM DISCONNECTED: waiting for connect\n";
        }

    }
    catch (const std::exception & e) {
        cout << "Host Controller Service failed to start: " << e.what() << endl;
        return -1;
    }
    catch (...) {
        cout << "Host Controller Service failure: unexpected error\n";
        return -1;
    }


    return 0;
}


