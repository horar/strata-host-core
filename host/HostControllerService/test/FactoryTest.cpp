/*
 * FactoryTest.cpp
 *
 */

#include "ConnectFactory.h"
#include "pthread.h"
#include "Connector.h"

/*!
 * \brief Test script for testing ConnectFactory.cpp
 * 		  We create a ZeroMQ Instance pointed by Base Class
 *
 * 		  Test script creates 1 instances of ZMQ_ROUTER type
 * 		  and 10 instances of ZMQ_DEALER (Host Controller Client) type
 * 		  and simulate Message send and receive
 *
 * 		  note: subscribe call might need to be adjusted based on the messaging
 * 		  		patter for verification
 */

struct ip {
    string routerIp ;
    string pubIp ;
};

void *createPub(void * add)
{
    ConnectFactory Obj;
    Connector* service = Obj.getServiceTypeObject("SERVICE");
    cout << "object Address is " << service <<endl;
    ip *address = (ip *)add;
    cout << "router Ip = " << address->routerIp <<endl;
    cout << "pub Ip = " << address->pubIp <<endl;
    service->clientEnd(address->routerIp,address->pubIp);
    cout << "Terminated "<<endl;
    return 0;
}

void *createSub(void *str) {

    ConnectFactory Obj;
    Connector* service = Obj.getServiceTypeObject("SERVICE");
    cout << "object Address is " << service <<endl;
    string *Id = (string *)str;
    service->subscribe(Id);
    return 0;
}

void *testUSB(void *) {

    ConnectFactory Obj;
    Connector* platform = Obj.getServiceTypeObject("PLATFORM");
    cout << "object Address is " << platform <<endl;
    platform->startPlatformCommunication();
    return 0;
}



int main(int argc,char *argv[]) {
    pthread_mutex_init(&lockRequestList,NULL);
    ip address;
    /*
    if(argc != 3) {

        cout << "Need two arguments for executable "<<endl;
        cout << "1 : Router Ip (to service connected client)" << endl;
        cout << "2 : Publisher Ip (to publish the data)"<<endl;
        exit(0);
    } else
    */
    if ((!(strcmp(argv[1],"-help"))) || (!(strcmp(argv[1],"-h")))) {

        cout <<endl;
        cout <<"Argument 1 = Ip address for ZMQ_ROUTER Socket" <<endl;
        cout << "Arg 1 will be used for HostControllerClient to send and receive" <<endl;
        cout <<"Argument 2 = Ip address for ZMQ_PUB Socket" <<endl;
        cout << "Arg 2 will be used for HostControllerClient to receive platform notification" <<endl;
        exit(0);
    }else {
        address.routerIp= argv[1];
        cout << "router Ip = " << address.routerIp <<endl;
        address.pubIp = argv[2];
        cout << "pubIp = " << address.pubIp << endl;
    }
    pthread_t A,B,C,d,e,f,g,h,i,j,k,l;
    //string E = "A";
    //string F = "B";
    //string G = "C";
    //string H = "D";
    //string I = "E";
    //string J = "F";
    //string K = "G";
    //string L = "H";
    //string M = "I";
    //pthread_create(&A,NULL,createSub,(void *)&E);
    //pthread_create(&C,NULL,createSub,(void *)&F);
    //pthread_create(&d,NULL,createSub,(void *)&G);
    //pthread_create(&e,NULL,createSub,(void *)&H);
    //pthread_create(&f,NULL,createSub,(void *)&I);
    //pthread_create(&g,NULL,createSub,(void *)&J);
    //pthread_create(&h,NULL,createSub,(void *)&K);
    //pthread_create(&i,NULL,createSub,(void *)&L);
    //pthread_create(&j,NULL,createSub,(void *)&E);
    //pthread_create(&k,NULL,createSub,(void *)&M);
    pthread_create(&B,NULL,createPub,(void *) &address);
    pthread_create(&l,NULL,testUSB,NULL);
    //pthread_join(A,NULL);
    pthread_join(B,NULL);
    //pthread_join(C,NULL);
    //pthread_join(d,NULL);
    //pthread_join(e,NULL);
    //pthread_join(g,NULL);
    //pthread_join(h,NULL);
    //pthread_join(i,NULL);
    //pthread_join(j,NULL);
    //pthread_join(k,NULL);
    pthread_join(l,NULL);
    return 0;
}



