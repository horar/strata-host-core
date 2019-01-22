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
#include "FleeceImpl.hh"
#include "SGDocument.h"
#ifndef NO_CB_ERROR
#define NO_CB_ERROR     0      // Declare value rather than use a magic number
#endif

namespace Spyglass {
    enum class SGDatabaseReturnStatus {
        kNoError,
        kOpenDBError,
        kCloseDBError,
        kCreateDocumentError,
        kUpdatDocumentError,
        kBeginTransactionError,
        kEndTransactionError,
        kDBNameError,
        kCreateDBDirectoryError,
        kDeleteDocumentError
    };

    class SGDatabase {

    public:
        SGDatabase();

        SGDatabase(const std::string &db_name);
        SGDatabase(const std::string &db_name, const std::string &path);

        virtual ~SGDatabase();

        void setDBName(const std::string &name);

        const std::string &getDBName() const;

        void setDBPath(const std::string &name);

        const std::string &getDBPath() const;

        C4Database *getC4db() const;

        SGDatabaseReturnStatus save(class SGDocument *doc);

        SGDatabaseReturnStatus deleteDocument(class SGDocument *doc);

        C4Document *getDocumentById(const std::string &doc_id);


        std::vector<std::string> getAllDocumentsKey();

        SGDatabaseReturnStatus open();

        SGDatabaseReturnStatus close();

        bool isOpen();

    private:

        C4Database *c4db_{nullptr};
        C4DatabaseConfig c4db_config_;
        C4Error c4error_ {};
        std::string db_name_;
        std::string db_path_;
        std::mutex db_lock_;

        static const uint32_t kSGNoCouchBaseError_ = 0;
        static constexpr const char *kSGDatabasesDirectory_ = "db";

        SGDatabaseReturnStatus createNewDocument(SGDocument *doc, fleece::alloc_slice body);

        SGDatabaseReturnStatus updateDocument(SGDocument *doc, fleece::alloc_slice new_body);

    };
}

#endif //SGDDATABASE_H
