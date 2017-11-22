/*
 * startHostControllerService.cpp
 *
 *  Created on: Aug 14, 2017
 *      Author: abhishek
 */

#include "HostControllerService.h"


int main(int argc, char *argv[]) {


	string routerIp,pubIp;

    if ((!(strcmp(argv[1],"-help"))) || (!(strcmp(argv[1],"-h")))) {

            cout <<endl;
            cout <<"Argument 1 = Ip address for ZMQ_ROUTER Socket" <<endl;
            cout << "Arg 1 will be used for HostControllerClient to send and receive" <<endl;
            cout <<"Argument 2 = Ip address for ZMQ_PUB Socket" <<endl;
            cout << "Arg 2 will be used for HostControllerClient to receive platform notification" <<endl;
            exit(0);
    }else {

            routerIp= argv[1];
            cout << "router Ip = " << routerIp <<endl;
            pubIp = argv[2];
            cout << "pub Ip = " << pubIp << endl;
    }

    HostControllerService HCS(routerIp,pubIp);
repeat:

	string conStatus = HCS.setupHostControllerService(routerIp,pubIp);

	if(!conStatus.compare("DISCONNECTED"))
		goto repeat;
	return 0;
}


