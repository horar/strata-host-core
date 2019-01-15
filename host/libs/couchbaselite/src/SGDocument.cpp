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
SGDocument::SGDocument() {
    c4db_       = nullptr;
    c4document_ = nullptr;
}
SGDocument::~SGDocument() {
    c4doc_free(c4document_);
}

SGDocument::SGDocument(SGDatabase *database, const std::string &docId) {
    setC4Document(database, docId);
}
const std::string &SGDocument::getId() const {
    return id_;
}

void SGDocument::setId(const std::string &id) {
    id_ = id;
}

/** SGDocument exist.
* @brief Check if the document exist in the DB.
*/
bool SGDocument::exist() {
    return c4document_ != nullptr;
}

/** SGDocument getBody.
* @brief Stringify fleece object (mutable_dict_) to string json format.
*/
const std::string &SGDocument::getBody() const {
    return mutable_dict_->asDict()->toJSONString();
}

/** SGDocument asDict.
* @brief Return the internal mutable_dict_ as fleece Dict object.
*/
const fleece::impl::Dict* SGDocument::asDict() const{
    return mutable_dict_->asDict();
}

/** SGDocument setC4Document.
* @brief Open a document and sets its body to to the existing mutable_dict, if the document exist. Otherwise init mutable_dict_
 * NOTE: This is not a public function, it's protected!
* @param database The reference to the opened SGDatabase.
* @param docId The reference to the docId to be opened.
*/
bool SGDocument::setC4Document(SGDatabase *database,const std::string &docId) {
    c4db_       = database->getC4db();
    c4document_ = database->getDocumentById(docId);
    id_         = docId;
    if(c4document_ != nullptr){
        DEBUG("SGDocument\n");
        C4Error c4error;
        C4String rev_id = c4document_->revID;
        std::string rev_id_str = std::string((const char *)rev_id.buf, rev_id.size);

        // TODO: Luay: Check for the body type. We are expecting the body to be in dictionary format (key,value) but this is not guaranteed!
        mutable_dict_ = fleece::impl::MutableDict::newDict(Value::fromData(c4document_->selectedRev.body)->asDict());

        DEBUG("body: %s,object member counts:%d, revision:%s\n",getBody().c_str(),mutable_dict_->count(), rev_id_str.c_str());
        return true;
    }
    // Init a new mutable dict
    mutable_dict_ = fleece::impl::MutableDict::newDict();
    DEBUG("c4document_ is null\n");
    return false;
}

/** SGDocument get.
* @brief MutableDict wrapper to access document data.
* @param keyToFind The reference to the key.
*/
const fleece::impl::Value *SGDocument::get(const std::string &keyToFind) {
    return mutable_dict_->get(keyToFind);
}

bool SGDocument::empty() {
    return mutable_dict_->empty();
}
C4Document *SGDocument::getC4document() const {
    return c4document_;
}