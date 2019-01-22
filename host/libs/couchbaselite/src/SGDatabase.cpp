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
#include "SGUtility.h"

using namespace std;
using namespace fleece;
using namespace fleece::impl;

#define DEBUG(...) printf("SGDatabase: "); printf(__VA_ARGS__)
namespace Spyglass {
    SGDatabase::SGDatabase() {}


    SGDatabase::SGDatabase(const std::string &db_name, const std::string &path) {
        setDBName(db_name);
        setDBPath(path);
    }

    SGDatabase::~SGDatabase() {
        close();
    }

    void SGDatabase::setDBName(const std::string &name) {
        db_name_ = name;
    }

    const std::string &SGDatabase::getDBName() const {
        return db_name_;
    }

    void SGDatabase::setDBPath(const std::string &path) {
        db_path_ = path;
    }

    const std::string &SGDatabase::getDBPath() const {
        return db_path_;
    }

    /** SGDatabase Open.
    * @brief Open or create a local embedded database if name does not exist
    * @param db_name The couchebase lite embeeded database name.
    */
    SGDatabaseReturnStatus SGDatabase::open() {

        lock_guard<mutex> lock(db_lock_);
        DEBUG("Calling open\n");

        // Check for empty db name
        if (db_name_.empty() || db_path_.empty()) {
            DEBUG("DB name can't be empty! \n");
            return SGDatabaseReturnStatus::kDBNameError;
        }
        /*
            Make a db folder to store all future databases
            Use a system call as experimental::filesystem wouldn't compile with clang
            System call will work with Windows/Mac/Linux
        */
        // System returns the processor exit status. In this case mkdir return 0 on success.
        //TODO: Replace system call to make a directory using standard C/C++ API
        string command = string("mkdir ") + getDBPath() + kSGDatabasesDirectory_;
        system(command.c_str());

        // Configure database attributes
        // This is the default DB configuration taken from the Java bindings
        c4db_config_.flags = kC4DB_Create | kC4DB_AutoCompact;
        c4db_config_.storageEngine = kC4SQLiteStorageEngine;
        c4db_config_.versioning = kC4RevisionTrees;
        c4db_config_.encryptionKey.algorithm = kC4EncryptionNone;

        string db_path = getDBPath() + string(kSGDatabasesDirectory_) + string("/") + db_name_;
        
        c4db_ = c4db_open(slice(db_path), &c4db_config_, &c4error_);

        if (isC4Error(c4error_)) {
            DEBUG("Error opening the db: %s.\n", db_path.c_str());
            return SGDatabaseReturnStatus::kOpenDBError;
        }

        return SGDatabaseReturnStatus::kNoError;
    }

    /** SGDatabase isOpen.
    * @brief Check if database is open
    */
    bool SGDatabase::isOpen() {
        return c4db_ != nullptr;
    }

    /** SGDatabase Close.
    * @brief Close the local database if it's open
    */
    SGDatabaseReturnStatus SGDatabase::close() {
        lock_guard<mutex> lock(db_lock_);
        DEBUG("Calling close\n");

        c4db_close(c4db_, &c4error_);
        if (isC4Error(c4error_)) {
            return SGDatabaseReturnStatus::kCloseDBError;
        }
        c4db_free(c4db_);

        // c4db_free Deallocate but won't set c4db_ to nullptr
        c4db_ = nullptr;

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
    SGDatabaseReturnStatus SGDatabase::createNewDocument(SGDocument *doc, alloc_slice body) {
        // Document does not exist. Creating a new one
        DEBUG("Creating a new document\n");

        C4RevisionFlags revisionFlags = kRevNew;

        C4Document *newdoc = c4doc_create(c4db_, slice(doc->getId()), body, revisionFlags, &c4error_);
        if (isC4Error(c4error_)) {
            DEBUG("Could not create new document.");
            return SGDatabaseReturnStatus::kCreateDocumentError;
        } else {
            doc->c4document_ = newdoc;
        }
        return SGDatabaseReturnStatus::kNoError;
    }

    /** SGDatabase updateDocument.
    * @brief Update existing couchebase document.
    * @param doc The SGDocument reference.
    * @param body The fleece slice data which will update the body.
    */
    SGDatabaseReturnStatus SGDatabase::updateDocument(SGDocument *doc, alloc_slice new_body) {
        // Document exist. Make modifications to the body
        DEBUG("document Exist. Working on updating the document: %s\n", doc->getId().c_str());
        string rev_id = slice(doc->c4document_->revID).asString();
        DEBUG("REV id: %s\n", rev_id.c_str());

        C4Document *newdoc = c4doc_update(doc->c4document_, new_body, doc->c4document_->selectedRev.flags, &c4error_);

        if (isC4Error(c4error_)) {
            DEBUG("Could not update the body of an existing document.\n");
            return SGDatabaseReturnStatus::kUpdatDocumentError;
        }

        doc->setC4document(newdoc);

        return SGDatabaseReturnStatus::kNoError;
    }

    /** SGDatabase save.
    * @brief Create/Edit a document
    * @param SGDocument The reference to the document object
    */
    SGDatabaseReturnStatus SGDatabase::save(SGDocument *doc) {
        lock_guard<mutex> lock(db_lock_);

        if(!isOpen()){
            DEBUG("Calling save() while DB is not open\n");
            return SGDatabaseReturnStatus::kOpenDBError;
        }

        if(doc == nullptr){
            DEBUG("Passing uninitialized/invalid SGDocument to save()\n");
            return SGDatabaseReturnStatus::kInvalidArgumentError;
        }

        SGDatabaseReturnStatus status = SGDatabaseReturnStatus::kNoError;

        c4db_beginTransaction(c4db_, &c4error_);
        if (isC4Error(c4error_)) {
            DEBUG("save kBeginTransactionError\n");
            return SGDatabaseReturnStatus::kBeginTransactionError;
        }
        DEBUG("Calling save\n");

        C4Document *c4doc = doc->getC4document();

        // Encode document mutable dictionary to fleece format
        Encoder encoder;
        encoder.writeValue(doc->mutable_dict_);
        alloc_slice fleece_data = encoder.finish();

        if (c4doc == nullptr) {
            status = createNewDocument(doc, fleece_data);

        } else {
            status = updateDocument(doc, fleece_data);
        }

        DEBUG("Leaving save\n");
        c4db_endTransaction(c4db_, true, &c4error_);
        if (isC4Error(c4error_)) {
            DEBUG("save kEndTransactionError\n");
            return SGDatabaseReturnStatus::kEndTransactionError;
        }

        return status;
    }

    /** SGDatabase getDocumentById.
    * @brief return C4Document if there is such a document exist in the DB, otherwise return nullptr
    * @param docId The document id
    */
    C4Document *SGDatabase::getDocumentById(const std::string &doc_id) {
        lock_guard<mutex> lock(db_lock_);

        if(!isOpen() || doc_id.empty()){
            return nullptr;
        }

        C4Document *c4doc;

        DEBUG("START getDocumentById: %s\n", doc_id.c_str());

        c4db_beginTransaction(c4db_, &c4error_);
        if (isC4Error(c4error_)) {
            DEBUG("getDocumentById starting transaction failed\n");
            return nullptr;
        }

        c4doc = c4doc_get(c4db_, slice(doc_id), true, &c4error_);

        // HACK. There is no straightforward API to check if document exist in local DB.
        // Since c4doc_get has must_exist parameter sets to true.
        // It will output an error saying document not found and sets code to kC4ErrorNotFound.
        // In this case C4Error needs to be cleared. Otherwise, it will flag c4db_endTransaction as failure.
        if(c4error_.code == kC4ErrorNotFound){
            c4error_ = {};
        }

        c4db_endTransaction(c4db_, true, &c4error_);
        if (isC4Error(c4error_)) {
            DEBUG("getDocumentById ending transaction failed\n");
            return nullptr;
        }
        DEBUG("END getDocumentById: %s\n", doc_id.c_str());
        return c4doc;
    }

    /** SGDatabase deleteDocument.
    * @brief delete existing document from the DB. True successful, otherwise false
    * @param SGDocument The document object
    */
    SGDatabaseReturnStatus SGDatabase::deleteDocument(SGDocument *doc) {
        lock_guard<mutex> lock(db_lock_);

        if(!isOpen()){
            DEBUG("Calling deleteDocument() while DB is not open\n");
            return SGDatabaseReturnStatus::kOpenDBError;
        }

        if(doc == nullptr){
            DEBUG("Passing uninitialized/invalid SGDocument to deleteDocument()\n");
            return SGDatabaseReturnStatus::kInvalidArgumentError;
        }

        c4db_beginTransaction(c4db_, &c4error_);
        if (isC4Error(c4error_)) {
            DEBUG("deleteDocument kBeginTransactionError\n");
            return SGDatabaseReturnStatus::kBeginTransactionError;
        }
        DEBUG("START deleteDocument: %s\n", doc->getId().c_str());

        // Try to delete the document
        bool is_deleted = c4db_purgeDoc(c4db_, slice(doc->getId()), &c4error_);

        c4db_endTransaction(c4db_, true, &c4error_);
        if (isC4Error(c4error_)) {
            DEBUG("deleteDocument kEndTransactionError\n");
            return SGDatabaseReturnStatus::kEndTransactionError;
        }

        if (!is_deleted) {
            return SGDatabaseReturnStatus::kDeleteDocumentError;
        }

        DEBUG("Document %s deleted\n", doc->getId().c_str());

        doc->setId(string());
        doc->setC4document(nullptr);

        DEBUG("END deleteDocument: %s\n", doc->getId().c_str());
        return SGDatabaseReturnStatus::kNoError;
    }

    /** SGDatabase getAllDocumentsKey.
    * @brief Runs local database query to get list of document keys.
    */
    vector<std::string> SGDatabase::getAllDocumentsKey() {
        lock_guard<mutex> lock(db_lock_);

        if(!isOpen()){
            throw runtime_error("Trying to run database query while DB is not open!");
        }

        vector<string> document_keys;
        const static string json = "[\"SELECT\", {\"WHAT\": [[\"._id\"]]}]";
        C4Query *query = c4query_new(c4db_, slice(json), &c4error_);

        if(!isC4Error(c4error_)){
            C4QueryOptions options = kC4DefaultQueryOptions;
            C4QueryEnumerator *query_enumerator = c4query_run(query, &options, c4str(nullptr), &c4error_);

            if(!isC4Error(c4error_)){

                while (c4queryenum_next(query_enumerator, &c4error_)) {

                    if(!isC4Error(c4error_)){
                        slice doc_name = FLValue_AsString(FLArrayIterator_GetValueAt(&query_enumerator->columns, 0));
                        document_keys.push_back(doc_name.asString());
                    }else{
                        DEBUG("c4queryenum_next failed to run.\n");
                        throw runtime_error("c4queryenum_next failed to run.");
                    }
                }

            }else{
                DEBUG("C4QueryEnumerator failed to run.\n");
                throw runtime_error("C4QueryEnumerator failed to run.");
            }

        }else{
            DEBUG("C4Query failed to execute a query.\n");
            throw runtime_error("C4Query failed to execute a query.");
        }

        return document_keys;
    }
}