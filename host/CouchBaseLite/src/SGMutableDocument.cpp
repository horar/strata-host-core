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

SGMutableDocument::SGMutableDocument(class SGDatabase *database, std::string docId):SGDocument(database, docId) {
    DEBUG("Constructor\n");
}
