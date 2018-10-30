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
#include "Fleece.hh"
#include "FleeceCpp.hh"
#include "Fleece.h"
#include "c4Document+Fleece.h"
#include "SGDatabase.h"
#include "SGDocument.h"

using namespace std;
using namespace fleeceapi;

#define DEBUG(...) printf("SGDatabase: "); printf(__VA_ARGS__)

SGDatabase::SGDatabase(const std::string db_name) {
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
    c4db_config_.flags          = kC4DB_Create;// | kC4DB_AutoCompact | kC4DB_SharedKeys;
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

    // Set error code 0.
    c4error_.code = 0;

    DEBUG("Calling save\n");
    FLError             fl_error = (FLError)0;
    FLSliceResult       fleece_result;

    // This is a hard coded value. This used to insert t the docment.
    // This API for creating key/value will be in SGDocument Soon!!!
    std::string         json_data = R"foo({"name":"luay","age":100})foo";

    //TODO: get c4doc from the SGDocument object
    C4Document          *c4doc = getDocumentById(doc->getId());
    if( !doc->exist() ){
        // Document does not exist. Creating a new one
        DEBUG("Creating new document\n");

        fleece_result = fleeceapi::Encoder::convertJSON(c4str(json_data.c_str()), &fl_error);

        if (fl_error != NO_CB_ERROR) {
            DEBUG("Fleece encoding failed: %d.\n", fl_error);
        }

        C4String docId;
        docId = c4str(doc->getId().c_str());
        DEBUG("data:%s.\n",  json_data.c_str());

        C4RevisionFlags revisionFlags = kRevNew | kRevHasAttachments;

        c4db_beginTransaction(c4db_, &c4error_);
        c4doc_create(c4db_, docId, (C4Slice) fleece_result, revisionFlags,&c4error_);
        if (c4error_.code !=NO_CB_ERROR && (c4error_.code < kC4NumErrorCodesPlus1)){
            DEBUG("Error Code:%d.\n",  c4error_.code);
        }
        c4db_endTransaction(c4db_, true, &c4error_);
    }else{
        // Docuement exist. Make modifications to the body
        DEBUG("document Exist\n");

        C4String fleece_body_data = c4doc->selectedRev.body;
        C4SliceResult body = c4doc_bodyAsJSON(c4doc,false,&c4error_);
        std::string string_body = string((char*)body.buf, body.size);
        DEBUG("Read data %s\n", string_body.c_str());

        // Fleece value of read body from the document
        FLValue flValue = FLValue_FromData(fleece_body_data);

        FLDict dict = FLValue_AsDict(flValue);

        DEBUG("Keys Count:%d\n", FLDict_Count(dict));

        Dict dict1 = Value::fromData(fleece_body_data).asDict();
        Value name_str = dict1.get("name");
        Value age_str = dict1.get("age");
        DEBUG("key: name, value:%s\n", name_str.asstring().c_str());
        DEBUG("key: age, value:%d\n", age_str.asInt());

        Value val_fleece_body(flValue);


        // These are just test fleece
        Encoder encoder;

        encoder.beginDict();
        encoder.writeValue(val_fleece_body);
        encoder.writeKey(c4str("new-double-key"));
        encoder.writeDouble(2.2221);
        encoder.writeKey(c4str("age2"));
        encoder.writeInt(age_str.asInt() + 1);
        //encoder.convertJSON((FLSlice)body);
        encoder.endDict();

        FLError flError;
        FLSliceResult new_encoded_fleece = encoder.finish(&flError);

        if(flError != kFLNoError && flError <=kFLSharedKeysStateError){
            DEBUG("Encoder failed: Error %d\n",flError);
        }else{
            //To make update to existing document: PUT request
            c4db_beginTransaction(c4db_, &c4error_);
            c4doc = c4doc_update(c4doc, (FLSlice)new_encoded_fleece, c4doc->selectedRev.flags, &c4error_);
            c4db_endTransaction(c4db_, true, &c4error_);
            if (c4error_.code !=NO_CB_ERROR && (c4error_.code < kC4NumErrorCodesPlus1)){
                DEBUG("Update field - Error Code:%d.\n",  c4error_.code);
            }
        }

    }

    DEBUG("Leaving save\n");

    db_lock_.unlock();

}
/** SGDatabase getDocumentById.
* @brief return C4Document if there is such a document exist in the DB, otherwise return null
* @param docId The document id
*/
C4Document *SGDatabase::getDocumentById(const std::string &docId) {
    C4Document      *c4doc;
    C4Error         error;

    DEBUG("START getDocumentById: %s\n", docId.c_str());

    c4db_beginTransaction(c4db_, &error);
    c4doc = c4doc_get(c4db_, c4str(docId.c_str()), true, &error);
    c4db_endTransaction(c4db_, true, &error);
    if (error.code !=NO_CB_ERROR && (error.code < kC4NumErrorCodesPlus1)){
        DEBUG("Error Code:%d.\n",  error.code);
    }
    DEBUG("END getDocumentById: %s\n", docId.c_str());

    return c4doc;
}
/** SGDatabase deleteDocument.
* @brief delete existing docuemtn from the DB. True successful, otherwise false
* @param SGDocument The document object
*/
bool SGDatabase::deleteDocument(class SGDocument *doc) {
    C4Error         error;
    c4db_beginTransaction(c4db_, &error);

    const char *docId = doc->getId().c_str();
    DEBUG("START deleteDocument: %s\n", docId);

    bool result = c4db_purgeDoc(c4db_, c4str(docId), &error);

    if (result) {
        DEBUG("Document %s deleted\n", docId);
        // TODO: Do we need to have a delete flag in the document?
        doc->setId("");
    }

    c4db_endTransaction(c4db_, true, &error);
    DEBUG("END deleteDocument: %s\n", docId);

    return result;
}
