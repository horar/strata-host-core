/**
******************************************************************************
* @file SGDatabase .CPP
* @author Luay Alshawi
* $Rev: 1 $
* $Date:
* @brief Database c++ object for the local couchbase database
******************************************************************************
* @copyright Copyright 2018 On Semiconductor
*/
#include <iostream>

#include "SGDatabase.h"

#include "FleeceImpl.hh"
#include "MutableArray.hh"
#include "MutableDict.hh"
#include "Doc.hh"
#include "c4Document+Fleece.h"

#include "SGDocument.h"

using namespace std;
using namespace fleece;
using namespace fleece::impl;

#define DEBUG(...) printf("SGDatabase: "); printf(__VA_ARGS__)
SGDatabase::SGDatabase() {}
SGDatabase::SGDatabase(const std::string& db_name) {
    setDBName(db_name);
}

SGDatabase::~SGDatabase() {
    close();
}

void SGDatabase::setDBName(const std::string& name){
    db_name_ = name;
}

const std::string& SGDatabase::getDBName() const{
    return db_name_;
}

/** SGDatabase Open.
* @brief Open or create a local embedded database if name does not exist
* @param db_name The couchebase lite embeeded database name.
*/
SGDatabaseReturnStatus SGDatabase::open() {

    lock_guard<mutex> lock(db_lock_);
    DEBUG("Calling open\n");

    // Check for empty db name
    if ( db_name_.empty() ){
        DEBUG("DB name can't be empty! \n");
        return SGDatabaseReturnStatus::kDBNameError;
    }
    /*
        Make a db folder to store all future databases
        Use a system call as experimental::filesystem wouldn't compile with clang
        System call will work with Windows/Mac/Linux
    */
    // System returns the processor exit status. In this case mkdir return 0 on success.
    string command = string("mkdir ") + kSGDatabasesDirectory_;
    system(command.c_str());

    // Configure database attributes
    // This is the default DB configuration taken from the Java bindings
    c4db_config_.flags          = kC4DB_Create | kC4DB_AutoCompact;
    c4db_config_.storageEngine  = kC4SQLiteStorageEngine;
    c4db_config_.versioning     = kC4RevisionTrees;
    c4db_config_.encryptionKey.algorithm    = kC4EncryptionNone;

    string db_path = string(kSGDatabasesDirectory_) + string("/") + db_name_;

    c4error_.code = 0;

    c4db_ = c4db_open(slice(db_path), &c4db_config_, &c4error_);

    if (c4error_.code != kSGNoCouchBaseError_ && c4error_.code < kC4NumErrorCodesPlus1){
        DEBUG("Error opening the db: %s. Error Code:%d.\n", db_path.c_str(), c4error_.code);
        return SGDatabaseReturnStatus::kOpenDBError;
    }

    return SGDatabaseReturnStatus::kNoError;
}

/** SGDatabase isOpen.
* @brief Check if database is open
*/
bool SGDatabase::isOpen(){
    return c4db_ != nullptr;
}

/** SGDatabase Close.
* @brief Close the local database if it's open
*/
SGDatabaseReturnStatus SGDatabase::close() {
    lock_guard<mutex> lock(db_lock_);
    DEBUG("Calling close\n");

    c4db_close(c4db_, &c4error_);
    if(c4error_.code != kSGNoCouchBaseError_ && c4error_.code < kC4NumErrorCodesPlus1){
        return SGDatabaseReturnStatus::kCloseDBError;
    }
    c4db_free(c4db_);

    DEBUG("Leaving close\n");
    return SGDatabaseReturnStatus::kNoError;
}

C4Database *SGDatabase::getC4db() const {
    return c4db_;
}

/** SGDatabase createNewDocument.
* @brief Create new couchebase document.
* @param doc The SGDocument reference.
* @param body The fleece slice data which will be stored in the body of the document.
*/
SGDatabaseReturnStatus SGDatabase::createNewDocument(SGDocument *doc, alloc_slice body){
    // Document does not exist. Creating a new one
    DEBUG("Creating a new document\n");

    C4RevisionFlags revisionFlags = kRevNew;

    C4Document *newdoc = c4doc_create(c4db_, slice(doc->getId()), body, revisionFlags,&c4error_);
    if (c4error_.code != kSGNoCouchBaseError_ && c4error_.code < kC4NumErrorCodesPlus1) {
        DEBUG("Could not create new document. Error Code:%d.\n",  c4error_.code);
        return SGDatabaseReturnStatus::kCreateDocumentError;
    }else{
        doc->c4document_ = newdoc;
    }
    return SGDatabaseReturnStatus::kNoError;
}

/** SGDatabase updateDocument.
* @brief Update existing couchebase document.
* @param doc The SGDocument reference.
* @param body The fleece slice data which will update the body.
*/
SGDatabaseReturnStatus SGDatabase::updateDocument(SGDocument *doc, alloc_slice new_body){
    // Document exist. Make modifications to the body
    DEBUG("document Exist. Working on updating the document: %s\n", doc->getId().c_str());
    string rev_id = slice(doc->c4document_->revID).asString();
    DEBUG("REV id: %s\n", rev_id.c_str());

    C4Document *newdoc = c4doc_update(doc->c4document_, new_body, doc->c4document_->selectedRev.flags, &c4error_);

    if (c4error_.code != kSGNoCouchBaseError_ && (c4error_.code < kC4NumErrorCodesPlus1) ) {
        alloc_slice sliceResult = c4error_getDescription(c4error_);

        DEBUG("Could not update the body of an existing document.\n");
        DEBUG("Error Msg:%s\n", sliceResult.asString().c_str());

        return SGDatabaseReturnStatus::kUpdatDocumentError;
    }else{
        // All good
        doc->setC4document(newdoc);
    }
    return SGDatabaseReturnStatus::kNoError;
}

/** SGDatabase save.
* @brief Create/Edit a document
* @param SGDocument The reference to the document object
*/
SGDatabaseReturnStatus SGDatabase::save(SGDocument *doc) {
    lock_guard<mutex> lock(db_lock_);

    SGDatabaseReturnStatus status = SGDatabaseReturnStatus::kNoError;

    c4db_beginTransaction(c4db_, &c4error_);
    if(c4error_.code != kSGNoCouchBaseError_ && c4error_.code < kC4NumErrorCodesPlus1){
        DEBUG("save kBeginTransactionError\n");
        return SGDatabaseReturnStatus::kBeginTransactionError;
    }
    DEBUG("Calling save\n");

    // Set error code 0.
    c4error_.code = 0;

    C4Document *c4doc = doc->getC4document();

    // Encode document mutable dictionary to fleece format
    Encoder encoder;
    encoder.writeValue(doc->mutable_dict_);
    alloc_slice fleece_data = encoder.finish();

    if( c4doc == nullptr ){
        status = createNewDocument(doc, fleece_data);

    }else{
        status = updateDocument(doc, fleece_data);
    }

    DEBUG("Leaving save\n");
    c4db_endTransaction(c4db_, true, &c4error_);
    if(c4error_.code != kSGNoCouchBaseError_ && c4error_.code < kC4NumErrorCodesPlus1){
        DEBUG("save kEndTransactionError\n");
        return SGDatabaseReturnStatus::kEndTransactionError;
    }

    return status;
}
/** SGDatabase getDocumentById.
* @brief return C4Document if there is such a document exist in the DB, otherwise return null
* @param docId The document id
*/
C4Document *SGDatabase::getDocumentById(const std::string &doc_id) {
    C4Document *c4doc;
    C4Error error;

    DEBUG("START getDocumentById: %s\n", doc_id.c_str());

    c4db_beginTransaction(c4db_, &error);
    c4doc = c4doc_get(c4db_, slice(doc_id), true, &error);
    c4db_endTransaction(c4db_, true, &error);
    if (error.code !=kSGNoCouchBaseError_ && (error.code < kC4NumErrorCodesPlus1)){
        DEBUG("Error Code:%d.\n",  error.code);
    }
    DEBUG("END getDocumentById: %s\n", doc_id.c_str());

    return c4doc;
}
/** SGDatabase deleteDocument.
* @brief delete existing document from the DB. True successful, otherwise false
* @param SGDocument The document object
*/
SGDatabaseReturnStatus SGDatabase::deleteDocument(SGDocument *doc) {
    c4db_beginTransaction(c4db_, &c4error_);
    if(c4error_.code != kSGNoCouchBaseError_ && c4error_.code < kC4NumErrorCodesPlus1){
        DEBUG("deleteDocument kBeginTransactionError\n");
        return SGDatabaseReturnStatus::kBeginTransactionError;
    }
    DEBUG("START deleteDocument: %s\n", doc->getId().c_str());

    // Try to delete the document
    bool is_deleted = c4db_purgeDoc(c4db_, slice(doc->getId()), &c4error_);

    c4db_endTransaction(c4db_, true, &c4error_);

    if(c4error_.code != kSGNoCouchBaseError_ && c4error_.code < kC4NumErrorCodesPlus1){
        DEBUG("deleteDocument kEndTransactionError\n");
        return SGDatabaseReturnStatus::kEndTransactionError;
    }

    if(!is_deleted){
        return SGDatabaseReturnStatus::kDeleteDocumentError;
    }

    DEBUG("Document %s deleted\n", doc->getId().c_str());

    doc->setId( string() );
    doc->setC4document(nullptr);

    DEBUG("END deleteDocument: %s\n", doc->getId().c_str());
    return SGDatabaseReturnStatus::kNoError;
}

/** SGDatabase getAllDocumentsKey.
* @brief Runs local database query to get list of document keys.
*/
vector<std::string> SGDatabase::getAllDocumentsKey() {
    vector<string> document_keys;
    C4Error c4error = {};
    string json = "[\"SELECT\", {\"WHAT\": [[\"._id\"]]}]";
    C4Query *query = c4query_new(c4db_, slice(json),&c4error);
    if(c4error.code == kSGNoCouchBaseError_ ){

        C4QueryOptions options = kC4DefaultQueryOptions;
        C4QueryEnumerator *query_enumerator = c4query_run(query, &options, c4str(nullptr), &c4error);

        if(c4error.code == kSGNoCouchBaseError_){
            while (c4queryenum_next(query_enumerator, &c4error)) {
                slice doc_name = FLValue_AsString(FLArrayIterator_GetValueAt(&query_enumerator->columns,0));
                document_keys.push_back( doc_name.asString() );
            }
        }else{
            DEBUG("C4QueryEnumerator failed to run. Error code:%d\n", c4error.code);
        }

    }else{
        DEBUG("C4Query failed to execute a query. Error code:%d\n", c4error.code);
    }

    return document_keys;
}
