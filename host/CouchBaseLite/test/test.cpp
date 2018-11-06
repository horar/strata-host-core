//
// Created by Luay Alshawi on 10/25/18.
//
#include <iostream>
#include <thread>// std::this_thread::sleep_for

#include "SGDatabase.h"
#include "SGDocument.h"
#include "SGMutableDict.h"
#include "SGMutableDocument.h"
#include "FleeceImpl.hh"
#include "MutableArray.hh"
#include "MutableDict.hh"
#include "Doc.hh"
using namespace std;
using namespace fleece;
using namespace fleece::impl;
#define DEBUG(...) printf("TEST SGLiteCore: "); printf(__VA_ARGS__)

int main(){

    SGDatabase sgDatabase("local_test_db");

    SGMutableDocument usbPDDocument(&sgDatabase, "usb-pd6");



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
    }

    sgDatabase.save(&usbPDDocument);

    sgDatabase.deleteDocument(&usbPDDocument);


    return 0;
}
