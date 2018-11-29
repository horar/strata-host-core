//
// Created by Luay Alshawi on 10/25/18.
//
#include <iostream>
#include <thread>

#include "FleeceImpl.hh"
#include "MutableArray.hh"
#include "MutableDict.hh"
#include "Doc.hh"

#include "SGReplicator.h"
#include "SGDatabase.h"
#include "SGDocument.h"
#include "SGMutableDocument.h"
#include "SGAuthenticator.h"
using namespace std;
using namespace fleece;
using namespace fleece::impl;
#define DEBUG(...) printf("TEST SGLiteCore: "); printf(__VA_ARGS__)

const char* activity_level_string[] = {"Stopped","Offline","Connecting","Idle", "Busy" };
void onStatusChanged(SGReplicator::ActivityLevel level, SGReplicatorProgress progress){
    float progress_percentage = 0.0;
    if(progress.total > 0){
        progress_percentage = (progress.completed / progress.total) *100;
    }
    DEBUG("Replicator Activity Level: %s %f %\n", activity_level_string[level], progress_percentage);
}
void onDocumentError(bool pushing, std::string doc_id, std::string error_message, bool transient){
    DEBUG("onDocumentError: pushing: %d, Doc Id: %s, error message: %s, transient:%d\n", pushing, doc_id.c_str(), error_message.c_str(), transient);
}
int main(){

    SGDatabase sgDatabase("db2");
    SGMutableDocument usbPDDocument(&sgDatabase, "motor-vortex");


    DEBUG("document Id: %s, body: %s\n", usbPDDocument.getId().c_str(), usbPDDocument.getBody().c_str());

    usbPDDocument.set("number", 30);
    usbPDDocument.set("name", "hello"_sl);


    string name_key = "name";

    const Value *name_value = usbPDDocument.get(name_key);
    if(name_value){

        if(name_value->type() == kString){

            string name_string = name_value->toString().asString();

            DEBUG("name:%s\n", name_string.c_str());
        }else{
            DEBUG("name_value is not a string!\n");
        }

    }else{
        DEBUG("There is no such key called: %s\n", name_key.c_str());
    }

    sgDatabase.save(&usbPDDocument);

    string whatever_key = "game";

    const Value *whatever_value_key = usbPDDocument.get(whatever_key);
    if(whatever_value_key){

        if(whatever_value_key->type() == kNumber){
            usbPDDocument.set(whatever_key, usbPDDocument.get(whatever_key)->asInt() + 1);
        }else{
            DEBUG("Warning: No such key:%s exist\n",whatever_key.c_str());
        }
    }else{
        usbPDDocument.set(whatever_key, 0);
    }

    sgDatabase.save(&usbPDDocument);

    string my_url = "ws://localhost:4984/staging";
    SGURLEndpoint url_endpoint(my_url);

    DEBUG("host %s, \n", url_endpoint.getHost().c_str());
    DEBUG("schema %s, \n", url_endpoint.getSchema().c_str());
    DEBUG("getPath %s, \n", url_endpoint.getPath().c_str());

    SGBasicAuthenticator basic_authenticator("username","password");

    SGReplicatorConfiguration replicator_configuration(&sgDatabase, &url_endpoint);

    replicator_configuration.setAuthenticator(&basic_authenticator);

    replicator_configuration.setReplicatorType(SGReplicatorConfiguration::ReplicatorType::kPushAndPull);

    SGReplicator replicator(&replicator_configuration);


    replicator.addChangeListener(onStatusChanged);
    replicator.addDocumentErrorListener(onDocumentError);

    replicator.start();
    DEBUG("About to stop the replicator thread\n");
    this_thread::sleep_for(chrono::milliseconds(5000));
    replicator.stop();
    DEBUG("bye\n");


    return 0;
}
