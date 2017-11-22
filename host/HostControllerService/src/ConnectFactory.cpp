/*
 * ConnectFactory.cpp
 *
 *  Created on: Jul 20, 2017
 *      Author: abhishek
 */

#include "ConnectFactory.h"

using namespace std;

ConnectFactory::ConnectFactory() {}
ConnectFactory::~ConnectFactory() {}

/*!
 * getServiceTypeObject returns the connector object to connect
 * to platform or to establish connection to Host-Controller Client
 */
Connector* ConnectFactory::getServiceTypeObject(string servicetype)
{
    if(servicetype.compare("SERVICE") ==0 ) {
        cout << "ZEROMQ object returned" << endl;
        return dynamic_cast<Connector*>(new ZeroMQConnector);
    }
    else if(servicetype.compare("PLATFORM")==0) {
        cout << "USB object returned" << endl;
        return dynamic_cast<Connector*>(new USBConnector);
    }
    return nullptr;
}

