#include "CouchbaseDocument.h"
#include "logging/LoggingQtCategories.h"
#include <iostream>
CouchbaseDocument::CouchbaseDocument(const std::string id) {
    mutable_doc_ = std::make_unique<cbl::MutableDocument>(id);
}

bool CouchbaseDocument::setBody(const std::string &body) {
    fleece::Doc fleece_doc = fleece::Doc::fromJSON(body);
    if (!fleece_doc) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error setting document. Verify the body is valid JSON.";
        return false;
    }
    mutable_doc_->setProperties(fleece_doc);
    return true;
}

bool CouchbaseDocument::setBody(const QString &body) {
    return setBody(body.toStdString());
}

fleece::keyref<fleece::MutableDict, fleece::slice> CouchbaseDocument::operator[](const std::string &key) {
    auto doc_ref = mutable_doc_.get();
    auto fleece_ref = (*doc_ref)[key.c_str()];
    return fleece_ref;
}