/**
******************************************************************************
* @file CBLDatabase .CPP
* @author Luay Alshawi
* $Rev: 1 $
* $Date:
* @brief Database c++ object for the local couchbase database
******************************************************************************
* @copyright Copyright 2018 On Semiconductor
*/
#include <iostream>
#include "CBLDatabase.h"

#define DEBUG(...) printf("CBLDatabase: "); printf(__VA_ARGS__)
using namespace std;
CBLDatabase::CBLDatabase(const std::string db_name) {
    // TODO: Check if db_name is empty
    open(db_name);

}

CBLDatabase::~CBLDatabase() {
    close();
}

/** CBLDatabase Open.
* @brief Open or create a local embedded database if name does not exist
* @param db_name The couchebase lite embeeded database name.
*/
void CBLDatabase::open(const std::string db_name) {
    /*
        Make a db folder to store all future databases
        Use a system call as experimental::filesystem wouldn't compile with clang
        System call will work with Windows/Mac/Linux
    */
    system("mkdir db");

    // Configure database attributes
    // This is the default DB configuration
    c4db_config_.flags          = kC4DB_Create;
    c4db_config_.storageEngine  = kC4SQLiteStorageEngine;
    c4db_config_.versioning     = kC4RevisionTrees;
    c4db_config_.encryptionKey.algorithm    = kC4EncryptionNone;

    std::string db_path = "./db/" + db_name;

    c4db_ = c4db_open(c4str(db_path.c_str()), &c4db_config_, &c4error_);

    if (c4error_.code !=NO_CB_ERROR){
        DEBUG("Error opening the db: %s. Error Code:%d.", db_path.c_str(), c4error_.code);
    }
}
/** CBLDatabase Close.
* @brief Close the local database if it's open
*/
void CBLDatabase::close() {
    c4db_close(c4db_, &c4error_);
    c4db_free(c4db_);
}
