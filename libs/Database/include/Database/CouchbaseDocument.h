/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <string>

namespace cbl {
    class MutableDocument;
}

namespace fleece {
    class MutableDict;
    struct slice;
    template <class Collection, class Key> class keyref;
}

namespace strata::Database
{

class CouchbaseDocument
{
    friend class CouchbaseDatabase;

public:
    CouchbaseDocument(const std::string id);

    bool setBody(const std::string &body);

    bool setBody(const QString &body);

    void tagChannelField(const std::vector<std::string> &channels);

    fleece::keyref<fleece::MutableDict, fleece::slice> operator[] (const std::string &key);

private:
    std::unique_ptr<cbl::MutableDocument> mutable_doc_;

    std::string doc_ID_;
};

} // namespace strata::Database
