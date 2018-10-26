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

#define DEBUG(...) printf("SGDatabase: "); printf(__VA_ARGS__)
using namespace std;
SGDatabase::SGDatabase(const std::string db_name) {
    // TODO: Check if db_name is empty
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
    c4db_config_.flags          = kC4DB_Create | kC4DB_AutoCompact | kC4DB_SharedKeys;
    c4db_config_.storageEngine  = kC4SQLiteStorageEngine;
    c4db_config_.versioning     = kC4RevisionTrees;
    c4db_config_.encryptionKey.algorithm    = kC4EncryptionNone;

    std::string db_path = "./db/" + db_name;

    c4db_ = c4db_open(c4str(db_path.c_str()), &c4db_config_, &c4error_);

    if (c4error_.code !=NO_CB_ERROR){
        DEBUG("Error opening the db: %s. Error Code:%d.", db_path.c_str(), c4error_.code);
    }
}
/** SGDatabase Close.
* @brief Close the local database if it's open
*/
void SGDatabase::close() {
    c4db_close(c4db_, &c4error_);
    c4db_free(c4db_);
}
