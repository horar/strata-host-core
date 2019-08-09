/**
******************************************************************************
* @file SGCouchbaseWrapper.h
* @author Prasanth Vivek
* $Rev: 1 $
* $Date: 2018-12-07
* @brief Implements the public Class for SGCouchbaseLiteCPP wrapper
******************************************************************************

* @copyright Copyright 2018 ON Semiconductor
*/

#include "SGCouchbaseLiteWrapper.h"

using namespace std;
using namespace fleece;
using namespace fleece::impl;
using namespace Spyglass;
// [prasanth] TODO: need to take the following variables into config file
const char* platform_document_key = "platform_list";

SGCouchbaseLiteWrapper::SGCouchbaseLiteWrapper(const std::string& database, const std::string& url)
{
    // opening the db
    sg_database_ = new SGDatabase(database);
    // replicator stuff
    url_endpoint_ = new SGURLEndpoint(url);
    sg_replicator_configuration_ = new SGReplicatorConfiguration(sg_database_,url_endpoint_);
    sg_replicator_configuration_->setReplicatorType(SGReplicatorConfiguration::ReplicatorType::kPull);
    sg_replicator_ = new SGReplicator(sg_replicator_configuration_);
    sg_platform_document_ = nullptr;
    basic_authenticator_ = nullptr;
    replication_called_ = false;
}

bool SGCouchbaseLiteWrapper::openDatabase()
{
    if(sg_database_->open() != SGDatabaseReturnStatus::kNoError) {
        cout<< "SGDatabase open failed\n";
        return false;
    }
    return true;
}

bool SGCouchbaseLiteWrapper::initURL()
{
    if(!(url_endpoint_->init())) {
        cout<< "URL initialization for replicator failed\n";
        return false;
    }
    return true;
}

void SGCouchbaseLiteWrapper::setChangeListenerCallback(const std::function<void(SGReplicator::ActivityLevel, SGReplicatorProgress)>& callback )
{
    sg_replicator_->addChangeListener(callback);
}

void SGCouchbaseLiteWrapper::setDocumentEndedListener(const std::function<void(bool pushing, std::string doc_id, std::string error_message, bool is_error,bool error_is_transient)>& document_ended_callback )
{
    sg_replicator_->addDocumentEndedListener(document_ended_callback);
}

void SGCouchbaseLiteWrapper::setValidationListener(const std::function<void(const std::string& doc_id, const std::string& json_body )>& validation_listener_callback)
{
    sg_replicator_->addValidationListener(validation_listener_callback);
}

SGCouchbaseLiteWrapper::~SGCouchbaseLiteWrapper()
{
    delete basic_authenticator_;
    delete sg_platform_document_;
    delete sg_replicator_configuration_;
    delete sg_replicator_;
    delete url_endpoint_;
    delete sg_database_;
}

bool SGCouchbaseLiteWrapper::openDocument(const std::string& document_name)
{
    // opening the document  in sgdatabase
    if(sg_platform_document_ == nullptr) {
        sg_platform_document_ = new SGMutableDocument(sg_database_, document_name);
        // [prasanth] TODO: Needs error handling. Need to co ordinate with @Luay
        return true;
    }
    return false;
}

bool SGCouchbaseLiteWrapper::getStoredPlatforms(platformList &platform_list)
{
    if(sg_platform_document_ == nullptr && !sg_platform_document_->exist()) {
        LOG_DEBUG(PRINT_DEBUG,"The document does not exist",0);
        return false;
    }
    const Value *platform_value = sg_platform_document_->get(platform_document_key);
    // Checking if the value exist for the key
    if(!platform_value) {
        return false;
    }
    // Checking if it has mutable array in it
    if(platform_value->type() != kArray) {
        LOG_DEBUG(PRINT_DEBUG,"The document does not contain the array",0);
        // [prasanth] TODO : empty the document since it has wrong format in it
        return false;
    }
    const Array *array = platform_value->asArray();
    if(array->empty()) {
        LOG_DEBUG(PRINT_DEBUG,"The mutable array is empty",0);
        return false;
    }

    for(Array::iterator iterator(array); iterator ; ++iterator) {
        if(iterator->type() == kDict) {
            const Dict *dictionary = iterator.value()->asDict();
            platform_details platform_information;
            platform_information.platform_uuid = dictionary->get("uuid"_sl)->asString().asString();
            platform_information.platform_verbose = dictionary->get("verbose"_sl)->asString().asString();
            platform_information.connection_status = "view";
            platform_list.push_back(platform_information);
            // [prasanth] TODO: adding the stored value to list
        }
    }
    return true;
}

bool SGCouchbaseLiteWrapper::addPlatformtoDB(const std::string& platform_uuid, const std::string& platform_verbose)
{
    // check for empty strings
    if(platform_uuid.empty() || platform_verbose.empty()) {
        LOG_DEBUG(PRINT_DEBUG,"Either or both the uuid/class and platform verbose name are empty\n",0);
        return false;
    }
    // [prasanth] TODO: check also if key exist
    if(sg_platform_document_ == nullptr) {
        return false;
    }
    if(!sg_platform_document_->exist()) {
        LOG_DEBUG(PRINT_DEBUG,"The document does not exist",0);
        Retained<MutableArray> mutable_array = MutableArray::newArray();
        Retained<MutableDict> mutable_dict = MutableDict::newDict();
        mutable_dict->set("uuid"_sl,slice(platform_uuid));
        mutable_dict->set("verbose"_sl,slice(platform_verbose));
        mutable_array->append(mutable_dict);
        sg_platform_document_->set(platform_document_key, mutable_array);
        if(sg_database_->save(sg_platform_document_) != SGDatabaseReturnStatus::kNoError) {
            LOG_DEBUG(PRINT_DEBUG,"Database save failed\n",0);
            return false;
        }
    }
    else {
        string json = sg_platform_document_->getBody();
        Retained<MutableArray> mutable_array = sg_platform_document_->getMutableArray(slice(platform_document_key));
        int array_length = mutable_array->count();
        Retained<MutableDict> mutable_dict = MutableDict::newDict();
        mutable_dict->set("uuid"_sl,slice(platform_uuid));
        mutable_dict->set("verbose"_sl,slice(platform_verbose));
        mutable_array->append(mutable_dict);
        if(sg_database_->save(sg_platform_document_) != SGDatabaseReturnStatus::kNoError) {
            LOG_DEBUG(PRINT_DEBUG,"Database save failed\n",0);
            return false;
        }
    }
    return true;
}

bool SGCouchbaseLiteWrapper::setAuthentication(const std::string& user_name, const std::string& password)
{
    if(basic_authenticator_ == nullptr) {
        basic_authenticator_ = new SGBasicAuthenticator(user_name,password);
        sg_replicator_configuration_->setAuthenticator(basic_authenticator_);
        // [prasanth] TODO : needs Error handling
        return true;
    }
    return false;
}

bool SGCouchbaseLiteWrapper::addChannels(const std::string& channel_name)
{
    // Checking if the channel already exists
    if(find(channels_.begin(), channels_.end(), channel_name) != channels_.end()) {
        LOG_DEBUG(PRINT_DEBUG,"channel already exists\n",0);
        return true;
    }
    channels_.push_back(channel_name);
    sg_replicator_configuration_->setChannels(channels_);
    // [prasanth] TODO : needs Error handling
    return true;
}

bool SGCouchbaseLiteWrapper::startReplicator()
{
    if(!replication_called_ && initURL()) {
        LOG_DEBUG(PRINT_DEBUG,"Starting the Replicator\n",0);
        if(!sg_replicator_->start()) {
            return false;
        }
        replication_called_ = true;
        return true;
    }
    return false;
}

bool SGCouchbaseLiteWrapper::stopReplicator()
{
    if(replication_called_) {
        LOG_DEBUG(PRINT_DEBUG,"Stopping the Replicator\n",0);
        sg_replicator_->stop();
        channels_.clear();
        replication_called_ = false;
        return true;
    }
    return false;
}

bool SGCouchbaseLiteWrapper::readExistingDocument(std::string& platform_uuid,  std::string& json_body)
{
    string uuid_class;
    LOG_DEBUG(PRINT_DEBUG," we are in reading from local db for content for channel %s\n",platform_uuid.c_str());
    SGMutableDocument platform_content(sg_database_,platform_uuid);
    if(!platform_content.exist()) {
        LOG_DEBUG(PRINT_DEBUG,"The document does not exist",0);
        return false;
    }
    const Value *document_value = platform_content.get("documents");
    if(document_value == nullptr) {
        return false;
    }
    json_body = document_value->toJSONString();
    LOG_DEBUG(PRINT_DEBUG,"The document body is %s\n",json_body.c_str());
    return true;
}


bool SGCouchbaseLiteWrapper::getDiff(const std::string& doc_id, const std::string& new_doc_body, std::string& diff_json_body)
{
    SGDocument document(sg_database_, doc_id);
    if(!document.exist()) {
        diff_json_body = new_doc_body;
        return false;
    }
    Retained<Doc> new_doc = Doc::fromJSON(new_doc_body);
    const Dict* original_dict = document.asDict();
    const Dict* new_dict = new_doc->asDict();
    alloc_slice jsonDelta = JSONDelta::create(original_dict, new_dict);
    alloc_slice fleeceDelta = JSONConverter::convertJSON(jsonDelta);
    const Value *delta = Value::fromData(fleeceDelta);
    Retained<MutableDict> newdict = MutableDict::newDict();
    if(diffString(original_dict, delta, newdict)) {
        cout << "json:" <<endl;
        cout << delta->toJSONString() << endl<<endl;
        cout << newdict->toJSONString() << endl<<endl;
        diff_json_body = newdict->toJSONString();
        return true;
    }
    return false;
}

bool SGCouchbaseLiteWrapper::diffString(const Dict* original_dict, const Value *delta, Retained<MutableDict> newdict)
{
    if(!delta) {
        cout << "delta is null" << endl;
        return false;
    }
    const Dict* dict = delta->asDict();
    if(!dict) {
        cout << "dict is null" << endl;
        return false;
    }
    if(!dict->get("documents"_sl)) {
        cout << "documents is not a key" << endl;
        return false;
    }
    const Dict* document = dict->get("documents"_sl)->asDict();
    if(!document) {
        cout << "documents is not Dictionary" << endl;
        return false;
    }
    Retained<MutableDict> download = MutableDict::newDict();
    for (Dict::iterator document_iterator(document); document_iterator; ++document_iterator) {
        const Dict* internal_dict = document_iterator.value()->asDict();
        if(!internal_dict) {
            cout << "something went wrong!" << endl;
            return false;
        }
        if(document_iterator.value()->type() == kDict) {
            Retained<MutableArray> mutable_array = MutableArray::newArray();
            cout << "key:" << document_iterator.keyString().asString() << endl;
            for (Dict::iterator internal_dict_iterator(internal_dict); internal_dict_iterator; ++internal_dict_iterator) {
                string key = internal_dict_iterator.keyString().asString();
                cout << "key:" << key << endl;
                if(key.back() == '-') {
                    //new elemtns in the array
                    // for each array append to the main array
                    for (Array::iterator array_iterator(internal_dict_iterator.value()->asArray()); array_iterator; ++array_iterator) {
                        mutable_array->append(array_iterator.value());
                    }
                }
                else {
                    //element has some members changed
                    int index_to_be_updated = std::stoi(key);
                    const Dict* current_document = original_dict->get("documents"_sl)->asDict();
                    if(!current_document) {
                        cout << "current _document is not valid dict or does not have documents key" << endl;
                        return false;
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
        }
        else {
            // Add the new key and value as it is
            download->set(document_iterator.keyString(), document_iterator.value());
        }
    }
    newdict->set("documents"_sl, download);
    return true;
}
