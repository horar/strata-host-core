/**
******************************************************************************
* @file SGDatabase .H
* @author Luay Alshawi
* $Rev: 1 $
* $Date:
* @brief c++ Database object for the local couchbase database
******************************************************************************
* @copyright Copyright 2018 On Semiconductor
*/

#ifndef SGDATABASE_H
#define SGDATABASE_H

#include <string>
#include <thread>         // std::thread
#include <mutex>          // std::mutex
#include "c4.h"
#include "SGDocument.h"

#ifndef NO_CB_ERROR
#define NO_CB_ERROR     0      // Declare value rather than use a magic number
#endif
class SGDatabase {

public:
    SGDatabase();
    SGDatabase(const std::string& db_name);

    C4Database *getC4db() const;

    void save(class SGDocument *doc);
    bool deleteDocument(class SGDocument *doc);

    C4Document* getDocumentById(const std::string &doc_id);

    virtual ~SGDatabase();

    std::vector<std::string> getAllDocumentsKey();

private:

    C4Database          *c4db_;
    C4DatabaseConfig    c4db_config_;
    C4Error             c4error_;
    std::string         db_name_;
    std::mutex          db_lock_;

    void open(const std::string db_name);
    void close();

};


#endif //SGDDATABASE_H
