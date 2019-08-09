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

#ifndef SGCOUCHBASELITE_WRAPPER_H
#define SGCOUCHBASELITE_WRAPPER_H

// standard library
#include <iostream>
#include <list>

#include <SGCouchBaseLite.h>
#include<SGFleece.h>

#define PRINT_DEBUG 1
#define LOG_DEBUG(lvl, fmt, ...)						\
	do { if (lvl>0) fprintf(stderr, fmt, __VA_ARGS__); } while (0)
// struct that will be added to the list
typedef struct{
    std::string platform_uuid;
    std::string platform_verbose;
    std::string connection_status;
}platform_details;
typedef std::list<platform_details> platformList;

class SGCouchbaseLiteWrapper {
public:
    // @f constructor
    SGCouchbaseLiteWrapper(const std::string& database,const std::string& url);

    ~SGCouchbaseLiteWrapper();

    /** @f openDatabase
    * @brief Open a local database
    */
    bool openDatabase();

    /** @f openDocument
    * @brief gets the document name and opens it
    * @param document name
    */
    bool openDocument(const std::string& document_name);

    /** @f getStoredPlatforms
    * @brief gets the platformlist(list of struct) and populates the list with the details
    * that are stored in database
    * @param platformlist(list of struct)
    */
    bool getStoredPlatforms(platformList &);

    /** @f getStoredPlatforms
    * @brief gets the platform uuid/class and platform verbose and pushes to db
    * @param platform uuid/class string and platform verbose name string
    */
    bool addPlatformtoDB(const std::string& platform_uuid, const std::string& verbose);

    /** @f setAuthentication
    * @brief gets the username and password to sync gateway
    * @param username and password for connecting to sync gateway
    */
    bool setAuthentication(const std::string& user_name, const std::string& password);

    /** @f addChannels
    * @brief gets the channel name and set it to the replicator
    * @param channel name
    */
    bool addChannels(const std::string& channel_name);

    /** @f startReplicator
    * @brief starts the replication process
    */
    bool startReplicator();

    /** @f stopReplicator
    * @brief stops the replication process
    */
    bool stopReplicator();

    void setChangeListenerCallback(const std::function<void(Spyglass::SGReplicator::ActivityLevel, Spyglass::SGReplicatorProgress)>& callback );

    void setDocumentEndedListener(const std::function<void(bool pushing, std::string doc_id, std::string error_message, bool is_error,bool error_is_transient)>& callback );

    void setValidationListener(const std::function<void(const std::string& doc_id, const std::string& json_body )>& callback);

    /** @f readExistingDocument
    * @brief read the existing document(based on uuid class) in db
    * if existing, parse the json body and send the json in ui
    * recognised format
    * @param platform uuid
    */
    bool readExistingDocument(std::string& platform_uuid, std::string& json_body);

    /** @f getDiff
    * @brief gets the proposed change from replicator and then reads the existing document
    * and then calls the function that returns the json string with the difference only
    * @param document id and the proposed json body
    */
    bool getDiff(const std::string& doc_id, const std::string& json_body,std::string& new_json_body);

    /** @f diffString
    * @brief compares the proposed and current document as dict
    * and stores the diff as dict into the third parameter
    * @param original dict, delta changes, diff dict
    * @author Luay Alshawi
    */
    bool diffString(const fleece::impl::Dict* original_dict, const fleece::impl::Value *delta, fleece::Retained<fleece::impl::MutableDict> newdict);

private:
    Spyglass::SGDatabase *sg_database_;
    Spyglass::SGMutableDocument *sg_platform_document_;
    Spyglass::SGReplicatorConfiguration *sg_replicator_configuration_;
    Spyglass::SGReplicator *sg_replicator_;
    Spyglass::SGURLEndpoint *url_endpoint_;
    Spyglass::SGBasicAuthenticator *basic_authenticator_;
    std::vector<std::string> channels_;
    bool replication_called_;
    std::string url_;

    /** @f initURL
    * @brief initializes the URL for replication process
    */
    bool initURL();
};

#endif
