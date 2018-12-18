/**
******************************************************************************
* @file SGMutableDocument .CPP
* @author Luay Alshawi
* $Rev: 1 $
* $Date:
* @brief Add mutability functionality to SGDocument
******************************************************************************
* @copyright Copyright 2018 On Semiconductor
*/
#include "SGMutableDocument.h"
#define DEBUG(...) printf("SGMutableDocument: "); printf(__VA_ARGS__)

SGMutableDocument::SGMutableDocument(class SGDatabase *database, std::string docId):SGDocument(database, docId) {}

/** SGMutableDocument setBody.
* @brief Given a string in json format this will convert it to fleece mutable dictionary. true on success, false otherwise
* @param body The reference to the string json format.
*/
bool SGMutableDocument::setBody(const std::string &body) {
    try{
        fleece::Retained<fleece::impl::Doc> doc = fleece::impl::Doc::fromJSON(body);
        mutable_dict_ = fleece::impl::MutableDict::newDict(doc->asDict());
        DEBUG("Set body: %s\n", body.c_str());
        return true;

    }catch (fleece::FleeceException){
        DEBUG("Can't set body of invalid json string: %s\n", body.c_str());
        return false;
    };
}