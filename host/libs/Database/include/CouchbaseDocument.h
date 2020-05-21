#pragma once

#include <string>

#include <QObject>

#include "Database.h"
#include "CouchbaseDatabase.h"

class Database;
class CouchbaseDatabase;

class CouchbaseDocument : public QObject
{
    Q_OBJECT
    friend class CouchbaseDatabase;

public:
    CouchbaseDocument(Database *db, const std::string id);

    CouchbaseDocument(CouchbaseDatabase *cbdb, const std::string id);

    bool setBody(const std::string &body);

    bool setBody(const QString &body);

    template <typename T> void set(const std::string &key, T value) {mutable_doc_->set(key, value);}

    template <typename T> void set(const QString &key, const T &value) {mutable_doc_->set(key.toStdString(), value);}

private:
    std::unique_ptr<Strata::SGMutableDocument> mutable_doc_;
};