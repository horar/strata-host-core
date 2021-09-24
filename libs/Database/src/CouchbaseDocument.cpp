/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "logging/LoggingQtCategories.h"

#include "Database/CouchbaseDocument.h"
#include "CouchbaseDatabase.h"

#include <QUuid>

using namespace strata::Database;

CouchbaseDocument::CouchbaseDocument(const std::string id) {
    doc_ID_ = id;
    auto uuid = QUuid::createUuid();
    mutable_doc_ = std::make_unique<cbl::MutableDocument>("StrataDocID_" + uuid.toString(QUuid::WithoutBraces).toStdString());
}

bool CouchbaseDocument::setBody(const std::string &body) {
    auto fleece_doc = fleece::Doc::fromJSON(body);
    if (!fleece_doc) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error setting document. Verify the body is valid JSON.";
        return false;
    }
    mutable_doc_->setProperties(fleece_doc);
    (*mutable_doc_.get())["StrataExternalDocID"] = doc_ID_;
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

void CouchbaseDocument::tagChannelField(const std::vector<std::string> &channels) {
    auto doc_ref = mutable_doc_.get();
    if (channels.size() != 1) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: size of 'channels' field must be exactly 1.";
        return;
    }
    (*doc_ref)["StrataExternalChannelID"] = channels.at(0);
}
