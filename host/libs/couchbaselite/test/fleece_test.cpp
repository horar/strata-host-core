//
// Created by Luay Alshawi on 10/25/18.
// Fleece Playground. Not an actual test
#include "FleeceImpl.hh"
#include "MutableArray.hh"
#include "MutableDict.hh"
#include "Doc.hh"
#include "JSONDelta.hh"
#include <iostream>

using namespace std;
using namespace fleece;
using namespace fleece::impl;


/** getDiff.
* @brief By gevin the original dicrionary and the delta generated from JSONDelta API. The new data will be written to newdict.
* @param original_dict The original dictionary.(Original JSON structure).
* @param delta The value given which contains the delta. (Delta JSON).
* @param newdict The Object to be written to.
*/
// Note: This function is not designed to be generic. It assumes it has the same json structure in main
// If something fails newdict might be null
// newdict will contains only the keys that are modified
void getDiff(const Dict* original_dict, const Value *delta, Retained<MutableDict> newdict){
    if(!delta){
        cout << "delta is null" << endl;
        return;
    }
    const Dict* dict = delta->asDict();
    if(!dict) {
        cout << "dict is null" << endl;
        return;
    }

    if(!dict->get("documents"_sl)){
        cout << "documents is not a key" << endl;
        return;
    }
    const Dict* document = dict->get("documents"_sl)->asDict();
    if(!document){
        cout << "documents is not Dictionary" << endl;
        return;
    }
    Retained<MutableDict> download = MutableDict::newDict();
    for (Dict::iterator document_iterator(document); document_iterator; ++document_iterator){

        const Dict* internal_dict = document_iterator.value()->asDict();
        if(!internal_dict){
            cout << "something went wrong!" << endl;
            return;
        }

        // for dicationary
        if(document_iterator.value()->type() == kDict){
            Retained<MutableArray> mutable_array = MutableArray::newArray();

            cout << "key:" << document_iterator.keyString().asString() << endl;
            for (Dict::iterator internal_dict_iterator(internal_dict); internal_dict_iterator; ++internal_dict_iterator){
                string key = internal_dict_iterator.keyString().asString();
                cout << "key:" << key << endl;
                if(key.back() == '-'){
                    //new elemtns in the array
                    // for each array append to the main array
                    for (Array::iterator array_iterator(internal_dict_iterator.value()->asArray()); array_iterator; ++array_iterator) {
                        mutable_array->append(array_iterator.value());
                    }

                }else{
                    //element has some members changed
                    int index_to_be_updated = std::stoi(key);
                    const Dict* current_document = original_dict->get("documents"_sl)->asDict();
                    if(!current_document){
                        cout << "current _document is not valid dict or does not have documents key" << endl;
                        return;
                    }

                    const Array* arr = current_document->get( document_iterator.keyString().asString())->asArray();
                    Retained<MutableDict> mutable_dict = MutableDict::newDict(arr->get(index_to_be_updated)->asDict());
                    for (Dict::iterator array_element_dict_iterator(internal_dict_iterator.value()->asDict()); array_element_dict_iterator; ++array_element_dict_iterator) {
                        string k = array_element_dict_iterator.keyString().asString();
                        mutable_dict->set(slice(k), array_element_dict_iterator.value());
                    }
                    mutable_array->append(mutable_dict);
                }
            }
            // Set the new dictionary with updated copy
            download->set(document_iterator.keyString(), mutable_array);
        }else{
            // Add the new key, value stuff as it is
            download->set(document_iterator.keyString(), document_iterator.value());
        }
    }
    newdict->set("documents"_sl, download);

}

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

    // Modify existing element
    update->getMutableDict("myobj"_sl)->getMutableArray("myarray"_sl)->set(0, 20);
    
    // Append to the array
    update->getMutableDict("myobj"_sl)->getMutableArray("myarray"_sl)->append(33);

    cout << "update myarray index0= " << myarray->get(0)->asInt() << " index2= " << myarray->get(1)->asInt() << endl;

    cout << "new json in string:" << dict->toJSON().asString();

    string original_json = R"foo(
    {
       "channels": "<platform_document_class>",
       "name":"<Platform Class Verbose name. Example: USB 4-Port Power Delivery",
       "documents":{
           "views":[
               {
                   "name":"views1",
                   "file":"/<class>/views/schematic/schematic.pdf",
                   "md5":"9e107d9d372bb6826bd81d3542a419d6",
                   "timestamp":"2005-10-30 T 10:45.76"
               }
           ],
           "downloads":[
               {
                   "name":"downloads1",
                   "file":"/<class>/views/schematic/schematic.pdf",
                   "md5":"9e107d9d372bb6826bd81d3542a419d6",
                   "timestamp":"2005-10-30 T 10:45.76"
               },
               {
                   "name":"downloads2",
                   "file":"/<class>/views/schematic/schematic.pdf",
                   "md5":"9e107d9d372bb6826bd81d3542a419d7",
                   "timestamp":"2005-10-30 T 10:45.76"
               },
               {
                   "name":"downloads3",
                   "file":"/<class>/views/schematic/schematic.pdf",
                   "md5":"9e107d9d372bb6826bd81d3542a419d7",
                   "timestamp":"2005-10-30 T 10:45.76"
               }
           ],
           "configuration":[
               {
                   "name":"configuration1",
                   "file":"/<class>/views/schematic/schematic.pdf",
                   "md5":"9e107d9d372bb6826bd81d3542a419d6",
                   "timestamp":"2005-10-30 T 10:45.76"
               }
           ]
       },
       "_rev": "4-e62835d48fa94fd1abec415f6b797216",
       "_id": "hello"
    }
    )foo";
    string updated_json = R"foo(
    {
       "channels": "<platform_document_class>",
       "name":"<Platform Class Verbose name. Example: USB 4-Port Power Delivery",
       "documents":{
           "views":[
               {
                   "name":"views1",
                   "file":"/<class>/views/schematic/schematic.pdf",
                   "md5":"9e107d9d372bb6826bd81d3542a419d6",
                   "timestamp":"2005-10-30 T 10:45.76"
               }
           ],
           "downloads":[
               {
                   "name":"downloads1",
                   "file":"/<class>/views/schematic/schematic.pdf",
                   "md5":"9e107d9d372bb6826bd81d3542a419d7",
                   "timestamp":"2005-10-30 T 10:45.77"
               },
               {
                   "name":"downloads2",
                   "file":"/<class>/views/schematic/schematic.pdf",
                   "md5":"9e107d9d372bb6826bd81d3542a419d7",
                   "timestamp":"2005-10-30 T 10:45.76"
               },
               {
                   "name":"downloads3",
                   "file":"/<class>/views/schematic/schematic.pdf",
                   "md5":"9e107d9d372bb6826bd81d3542a419d8",
                   "timestamp":"2005-10-30 T 10:45.76"
               },
               {
                   "name":"downloads4",
                   "file":"/<class>/views/schematic/schematic.pdf",
                   "md5":"9e107d9d372bb6826bd81d3542a419d7",
                   "timestamp":"2005-10-30 T 10:45.76"
               }
           ],
           "configuration":[
               {
                   "name":"configuration1",
                   "file":"/<class>/views/schematic/schematic.pdf",
                   "md5":"9e107d9d372bb6826bd81d3542a419d6",
                   "timestamp":"2005-10-30 T 10:45.76"
               },
               {
                   "name":"configuration2",
                   "file":"/<class>/views/schematic/schematic.pdf",
                   "md5":"9e107d9d372bb6826bd81d3542a419d6",
                   "timestamp":"2005-10-30 T 10:45.76"
               }
           ]
       },
       "_rev": "4-e62835d48fa94fd1abec415f6b797216",
       "_id": "hello",
        "new_kwy": "k1"
    }
    )foo";

    Retained<Doc> original_document = Doc::fromJSON(original_json);
    Retained<Doc> new_doc = Doc::fromJSON(updated_json);

    const Dict* original_dict = original_document->asDict();
    const Dict* new_dict = new_doc->asDict();

    alloc_slice jsonDelta = JSONDelta::create(original_dict, new_dict);
    alloc_slice fleeceDelta = JSONConverter::convertJSON(jsonDelta);
    const Value *delta = Value::fromData(fleeceDelta);


    Retained<MutableDict> newdict = MutableDict::newDict();

    getDiff(original_dict, delta, newdict);

    cout << "json:" <<endl;
    cout << delta->toJSONString() << endl<<endl;
    cout << newdict->toJSONString() << endl<<endl;


    return 0;
}
