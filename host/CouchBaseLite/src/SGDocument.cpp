/**
******************************************************************************
* @file SGDocument .H
* @author Luay Alshawi
* $Rev: 1 $
* $Date:
* @brief Document c++ object to map a raw docuemtn in DB to c++ object. Similar to ORM
******************************************************************************
* @copyright Copyright 2018 On Semiconductor
*/
#include <string>
#include "c4Document+Fleece.h"
#include "SGDocument.h"
#define DEBUG(...) printf("SGDocument: "); printf(__VA_ARGS__)

SGDocument::SGDocument() {
    c4db_       = NULL;
    c4document_ = NULL;
    id_         = "";
}
SGDocument::SGDocument(SGDatabase *database, std::string docId) {
    c4db_       = database->getC4db();
    c4document_ = database->getDocumentById(docId);
    id_         = docId;
    if(c4document_ !=NULL){
        DEBUG("SGDocument\n");
        C4Error c4error;
        C4String revid = c4document_->revID;
        std::string revid_str = std::string((const char *)revid.buf, revid.size);

        C4String fleece_body_data = c4document_->selectedRev.body;
        C4SliceResult body = c4doc_bodyAsJSON(c4document_,false,&c4error);

        // Set the document body content to the internal body_
        body_ = std::string((char*)body.buf, body.size);

        DEBUG("revision:%s\n", revid_str.c_str());
        return;
    }
    DEBUG("c4document_ is null\n");
}
const std::string &SGDocument::getId() const {
    return id_;
}

void SGDocument::setId(const std::string &id) {
    id_ = id;
}

bool SGDocument::exist() {
    if (c4document_ == NULL){
        return false;
    }
    return true;
}

const std::string &SGDocument::getBody() const {
    return body_;
}

void SGDocument::setBody(const std::string &body) {
    body_ = body;
}


