/**
******************************************************************************
* @file SGDocument .H
* @author Luay Alshawi
* $Rev: 1 $
* $Date:
* @brief Document c++ object to map a raw document in DB to c++ object. Similar to ORM. Gives read only to the document body
******************************************************************************
* @copyright Copyright 2018 On Semiconductor
*/
#include <string>
#include "SGDocument.h"

#define DEBUG(...) printf("SGDocument: "); printf(__VA_ARGS__)
using fleece::impl::Value;
using namespace std;
namespace Spyglass {
    SGDocument::SGDocument() {}

    SGDocument::~SGDocument() {
        c4doc_free(c4document_);
    }

    SGDocument::SGDocument(SGDatabase *database, const std::string &docId) {
        setC4document(database->getDocumentById(docId));
        setId(docId);
        initMutableDict();
    }

    const std::string &SGDocument::getId() const {
        return id_;
    }

    void SGDocument::setId(const std::string &id) {
        id_ = id;
    }

    bool SGDocument::exist() const {
        return c4document_ != nullptr;
    }

    const std::string SGDocument::getBody() const {
        return mutable_dict_->asDict()->toJSONString();
    }

    const fleece::impl::Dict *SGDocument::asDict() const {
        return mutable_dict_->asDict();
    }

    void SGDocument::initMutableDict() {
        if ( exist() ) {
            mutable_dict_ = fleece::impl::MutableDict::newDict(Value::fromData(c4document_->selectedRev.body)->asDict());
            DEBUG("Doc Id: %s, body: %s, revision:%s\n", id_.c_str(), getBody().c_str(), fleece::slice(c4document_->selectedRev.revID).asString().c_str());
            return;
        }
        // Init a new mutable dict
        mutable_dict_ = fleece::impl::MutableDict::newDict();
        DEBUG("c4document_ is null\n");
    }

    const fleece::impl::Value *SGDocument::get(const std::string &keyToFind) {
        return mutable_dict_->get(keyToFind);
    }

    bool SGDocument::empty() const {
        return mutable_dict_->empty();
    }

    C4Document *SGDocument::getC4document() const {
        return c4document_;
    }

    void SGDocument::setC4document(C4Document *doc) {
        c4document_ = doc;
    }
}