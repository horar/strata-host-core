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
#include "FleeceImpl.hh"
#include "MutableArray.hh"
#include "MutableDict.hh"
#include "Doc.hh"
#include "c4Document+Fleece.h"
#include "SGDatabase.h"
#include "SGDocument.h"

using namespace std;
using namespace fleece;
using namespace fleece::impl;

#define DEBUG(...) printf("SGDatabase: "); printf(__VA_ARGS__)
SGDatabase::SGDatabase() {}
SGDatabase::SGDatabase(const std::string& db_name) {
    open(db_name);
}

SGDatabase::~SGDatabase() {
    close();
}

/** SGDatabase Open.
* @brief Open or create a local embedded database if name does not exist
* @param db_name The couchebase lite embeeded database name.
*/
void SGDatabase::open(const std::string db_name) {

    db_lock_.lock();
    DEBUG("Calling open\n");

    // Check for empty db name
    if (db_name.length() == 0){
        DEBUG("DB name can't be empty! \n");
        return;
    }
    /*
        Make a db folder to store all future databases
        Use a system call as experimental::filesystem wouldn't compile with clang
        System call will work with Windows/Mac/Linux
    */
    system("mkdir db");

    // Configure database attributes
    // This is the default DB configuration taken from the Java bindings
    c4db_config_.flags          = kC4DB_Create | kC4DB_AutoCompact | kC4DB_SharedKeys;
    c4db_config_.storageEngine  = kC4SQLiteStorageEngine;
    c4db_config_.versioning     = kC4RevisionTrees;
    c4db_config_.encryptionKey.algorithm    = kC4EncryptionNone;

    std::string db_path = "./db/" + db_name;
    c4error_.code = 0;
    c4db_ = c4db_open(c4str(db_path.c_str()), &c4db_config_, &c4error_);
    if (c4error_.code !=NO_CB_ERROR){
        DEBUG("Error opening the db: %s. Error Code:%d.\n", db_path.c_str(), c4error_.code);
    }
    DEBUG("Leaving open\n");

    db_lock_.unlock();


}
/** SGDatabase Close.
* @brief Close the local database if it's open
*/
void SGDatabase::close() {
    db_lock_.lock();
    DEBUG("Calling close\n");

    c4db_close(c4db_, &c4error_);
    c4db_free(c4db_);

    DEBUG("Leaving close\n");
    db_lock_.unlock();
}

C4Database *SGDatabase::getC4db() const {
    return c4db_;
}

/** SGDatabase save.
* @brief Create/Edit a document
* @param SGDocument The reference to the document object
*/
void SGDatabase::save(SGDocument *doc) {
    db_lock_.lock();
    c4db_beginTransaction(c4db_, &c4error_);
    DEBUG("Calling save\n");

    // Set error code 0.
    c4error_.code = 0;

    C4Document *c4doc = doc->getC4document();

    // Encode document mutable dictionary to fleece format
    Encoder encoder;
    encoder.writeValue(doc->mutable_dict_);
    alloc_slice fleece_data = encoder.finish();

    if( c4doc == NULL ){
        // Document does not exist. Creating a new one
        DEBUG("Creating a new document\n");

        C4RevisionFlags revisionFlags = kRevNew;
        C4String docId = c4str(doc->getId().c_str());

        C4Document *newdoc = c4doc_create(c4db_, docId, fleece_data, revisionFlags,&c4error_);
        if (c4error_.code != NO_CB_ERROR && (c4error_.code < kC4NumErrorCodesPlus1) ) {
            DEBUG("Could not insert the body of new document. Error Code:%d.\n",  c4error_.code);
        }else{
            doc->c4document_ = newdoc;
        }

    }else{
        // Docuement exist. Make modifications to the body
        DEBUG("document Exist. Working on updating the document: %s\n", doc->getId().c_str());
        C4String rev_id = c4doc->revID;
        std::string rev_id_string = std::string((const char *) rev_id.buf, rev_id.size);
        DEBUG("REV id: %s\n", rev_id_string.c_str());

        C4Document *newdoc = c4doc_update(c4doc, fleece_data, c4doc->selectedRev.flags, &c4error_);

        if (c4error_.code != NO_CB_ERROR && (c4error_.code < kC4NumErrorCodesPlus1) ) {
            C4SliceResult sliceResult = c4error_getDescription(c4error_);
            string slice2string = string((char*)sliceResult.buf,sliceResult.size);

            DEBUG("Could not update the body of an existing document.\n");
            DEBUG("Error Msg:%s\n", slice2string.c_str());

            // free sliceResult
            c4slice_free(sliceResult);

        }else{
            // All good
            doc->c4document_ = newdoc;
        }
    }

    DEBUG("Leaving save\n");
    c4db_endTransaction(c4db_, true, &c4error_);

    db_lock_.unlock();

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
    c4doc = c4doc_get(c4db_, c4str(doc_id.c_str()), true, &error);
    c4db_endTransaction(c4db_, true, &error);
    if (error.code !=NO_CB_ERROR && (error.code < kC4NumErrorCodesPlus1)){
        DEBUG("Error Code:%d.\n",  error.code);
    }
    DEBUG("END getDocumentById: %s\n", doc_id.c_str());

    return c4doc;
}
/** SGDatabase deleteDocument.
* @brief delete existing document from the DB. True successful, otherwise false
* @param SGDocument The document object
*/
bool SGDatabase::deleteDocument(SGDocument *doc) {
    C4Error error;
    c4db_beginTransaction(c4db_, &error);

    const char *doc_id = doc->getId().c_str();
    DEBUG("START deleteDocument: %s\n", doc_id);

    bool result = c4db_purgeDoc(c4db_, c4str(doc_id), &error);

    if (result) {
        DEBUG("Document %s deleted\n", doc_id);
        // TODO: Do we need to have a delete flag in the document?
        doc->setId("");
    }

    DEBUG("END deleteDocument: %s\n", doc_id);
    c4db_endTransaction(c4db_, true, &error);

    return result;
}
