#ifndef CBLDATABASE_H
#define CBLDATABASE_H
/**
******************************************************************************
* @file CBLDatabase .H
* @author Luay Alshawi
* $Rev: 1 $
* $Date:
* @brief Database c++ object for the local couchbase database
******************************************************************************
* @copyright Copyright 2018 On Semiconductor
*/

#include<string>
#include "c4Database.h"
#include "c4.hh"

#define NO_CB_ERROR     0      // Declare value rather than use a magic number

class CBLDatabase {

public:
    CBLDatabase(const std::string db_name);

    virtual ~CBLDatabase();

private:

    C4Database          *c4db_;
    C4DatabaseConfig    c4db_config_;
    C4Error             c4error_;
    std::string         db_name_;

    void open(const std::string db_name);
    void close();
};


#endif //CBLDATABASE_H
