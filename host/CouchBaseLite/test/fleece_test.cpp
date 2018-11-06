//
// Created by Luay Alshawi on 10/25/18.
// Fleece Playground. Not an actual test
#include "FleeceImpl.hh"
#include "MutableArray.hh"
#include "MutableDict.hh"
#include "Doc.hh"
#include <iostream>

using namespace std;
using namespace fleece;
using namespace fleece::impl;

int main(){

    std::string json_data = R"foo({"name":"luay","age":100,"myobj":{"mykey":"myvalue","myarray":[1,2,3,4]} })foo";

    // Load string json to fleece Doc
    Retained<Doc> doc = Doc::fromJSON(json_data);

    // Pass existing  doc to mutable dictionary since we have json
    Retained<MutableDict> update = MutableDict::newDict(doc->asDict());
    cout << "Reading key name: " << update->get(slice("name"))->asString().asString() <<endl;
    update->set("name"_sl, slice("Alshawi"));
    cout << "Updating key name: " << update->get(slice("name"))->asString().asString() <<endl;

    // Done
    const Dict *dict = update->asDict();

    const Dict *myobj = dict->get(slice("myobj"))->asDict();

    const Array *myarray = myobj->get(slice("myarray"))->asArray();

    cout << "myarray index0= " << myarray->get(0)->asInt() << " index2= " << myarray->get(1)->asInt() << endl;


    update->getMutableDict("myobj"_sl)->getMutableArray("myarray"_sl)->set(0, 20);

    cout << "update myarray index0= " << myarray->get(0)->asInt() << " index2= " << myarray->get(1)->asInt() << endl;

    cout << "new json in string:" << dict->toJSON().asString();


    return 0;
}
