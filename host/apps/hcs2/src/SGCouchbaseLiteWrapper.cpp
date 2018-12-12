/**
******************************************************************************
* @file SGCouchbaseWrapper.h
* @author Prasanth Vivek
* $Rev: 1 $
* $Date: 2018-12-07
* @brief Implements the public Class for SGCouchbaseLiteCPP wrapper
******************************************************************************

* @copyright Copyright 2018 On Semiconductor
*/

#include "SGCouchbaseLiteWrapper.h"

using namespace std;
using namespace fleece;
using namespace fleece::impl;

const char* platform_document_key = "platform_list";

/******************************************************************************/
/*                                core functions                              */
/******************************************************************************/
// @f constructor
// @b gets the db name and opens it
//
// arguments:
//  IN: db name
//
//  OUT:
//   void
//
SGCouchbaseLiteWrapper::SGCouchbaseLiteWrapper(std::string database)
{
    // opening the db
    sgDatabase_ = new SGDatabase(database);
    sgDatabase_->open();
    // [prasanth] TODO: Needs error handling. Need to co ordinate with @Luay
}

SGCouchbaseLiteWrapper::~SGCouchbaseLiteWrapper()
{
    sgDatabase_->save(sg_platform_document_);
}

// @f openDocument
// @b gets the document name and opens it
//
// arguments:
//  IN: document name
//
//  OUT:
//   true, if document is opened. else false
//
bool SGCouchbaseLiteWrapper::openDocument(std::string document_name)
{
    // opening the document  in sgdatabase
    sg_platform_document_ = new SGMutableDocument(sgDatabase_, document_name);
    // [prasanth] TODO: Needs error handling. Need to co ordinate with @Luay
}

// @f getStoredPlatforms
// @b gets the platformlist(list of struct) and populates the list with the details
// that are stored in database
// 
// arguments:
//  IN: platformlist(list of struct)
//
//  OUT:
//   true, if the list is populated, else false
//
bool SGCouchbaseLiteWrapper::getStoredPlatforms(platformList &platform_list)
{
    if(!sg_platform_document_->exist()) {
        LOG_DEBUG(PRINT_DEBUG,"The document does not exist",0);
        return false;
    }
    const Value *platform_value = sg_platform_document_->get(platform_document_key);
    // Checking if the value exist for the key
    if(!platform_value){
        return false;
    }
    // Checking if it has mutable array in it
    if(!platform_value->type() == kArray){
        LOG_DEBUG(PRINT_DEBUG,"The document does not contain the array",0);
        // [prasanth] TODO : empty the document since it has wrong format in it
        return false;
    }
    // @ return fleece::array
    const Array *array = platform_value->asArray();
    if(array->empty()) {
        LOG_DEBUG(PRINT_DEBUG,"The mutable array is empty",0);
        return false;
    }

    Array::iterator iterator(array);
    for(int it = 0 ; it < array->count(); it++){
        if(iterator->type() == kDict){
            const Dict *dictionary = iterator.value()->asDict();
            platform_details platform_information;
            cout<< "the stored uuid is "<<dictionary->get("uuid"_sl)->asString().asString()<<endl;
            platform_information.platform_uuid = dictionary->get("uuid"_sl)->asString().asString();
            cout<< " the stored verbose is "<<dictionary->get("verbose"_sl)->asString().asString()<<endl;
            platform_information.platform_verbose = dictionary->get("verbose"_sl)->asString().asString();
            platform_information.connection_status = "view";
            platform_list.push_back(platform_information);
            // [prasanth] TODO: adding the stored value to list
        }
        ++iterator;
    } 
    return true;
}

// @f addPlatformtoDB
// @b gets the platform uuid/class and platform verbose and pushes to db
// 
// arguments:
//  IN: platform uuid/class string and platform verbose name string
//
//  OUT:
//   true, if the platform details are succesfully added, else false.
//
bool SGCouchbaseLiteWrapper::addPlatformtoDB(const std::string& platform_uuid, const std::string& platform_verbose)
{
    // check for empty strings
    if(platform_uuid.empty() || platform_verbose.empty()) {
        LOG_DEBUG(PRINT_DEBUG,"Either or both the uuid/class and platform verbose name are empty\n",0);
        return false;
    }
    // [prasanth] TODO: check also if key exist
    if(!sg_platform_document_->exist()) {
        LOG_DEBUG(PRINT_DEBUG,"The document does not exist",0);
        Retained<MutableArray> mutable_array = MutableArray::newArray();
        Retained<MutableDict> mutable_dict = MutableDict::newDict();
        mutable_dict->set("uuid"_sl,slice(platform_uuid));
        mutable_dict->set("verbose"_sl,slice(platform_verbose));
        mutable_array->append(mutable_dict);
        sg_platform_document_->set(platform_document_key, mutable_array);
        string json = sg_platform_document_->getBody();
        sgDatabase_->save(sg_platform_document_);
    } 
    else {
        string json = sg_platform_document_->getBody();
        Retained<MutableArray> mutable_array = sg_platform_document_->getMutableArray(slice(platform_document_key));
        int array_length = mutable_array->count();
        Retained<MutableDict> mutable_dict = MutableDict::newDict();
        mutable_dict->set("uuid"_sl,slice(platform_uuid));
        mutable_dict->set("verbose"_sl,slice(platform_verbose));
        mutable_array->append(mutable_dict);
        cout << "size of the array is "<<mutable_array->count()<<endl;
        sgDatabase_->save(sg_platform_document_);
    }  
    return true;
}