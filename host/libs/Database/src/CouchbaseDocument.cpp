#include "CouchbaseDocument.h"

CouchbaseDocument::CouchbaseDocument(Database *db, const std::string id) {
    mutable_doc_ = std::make_unique<Strata::SGMutableDocument>(db->database_.get()->database_.get(), id);
}

CouchbaseDocument::CouchbaseDocument(CouchbaseDatabase *cbdb, const std::string id) {
    mutable_doc_ = std::make_unique<Strata::SGMutableDocument>(cbdb->database_.get(), id);
}

bool CouchbaseDocument::setBody(const std::string &body) {
    return mutable_doc_->setBody(body);
}

bool CouchbaseDocument::setBody(const QString &body) {
    return mutable_doc_->setBody(body.toStdString());
}