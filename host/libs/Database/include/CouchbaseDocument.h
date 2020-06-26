#pragma once

#include <string>

#include "Database.h"
#include "CouchbaseDatabase.h"

class Database;
class CouchbaseDatabase;

class CouchbaseDocument
{
    friend class CouchbaseDatabase;

public:
    CouchbaseDocument(const std::string id);

    bool setBody(const std::string &body);

    bool setBody(const QString &body);

    fleece::keyref<fleece::MutableDict, fleece::slice> operator[] (const std::string &key);

private:
    std::unique_ptr<cbl::MutableDocument> mutable_doc_;
};