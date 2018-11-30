/**
******************************************************************************
* @file SGMutableDocument .H
* @author Luay Alshawi
* $Rev: 1 $
* $Date:
* @brief Add mutability functionality to SGDocument
******************************************************************************
* @copyright Copyright 2018 On Semiconductor
*/
#ifndef SGMUTABLEDOCUMENT_H
#define SGMUTABLEDOCUMENT_H

#include "SGDocument.h"

class SGMutableDocument: public SGDocument{
public:
    SGMutableDocument(class SGDatabase *database, std::string docId);
    template <typename T>
    void set(const std::string &key, T value)                           {mutable_dict_->set(key,value);}

    fleece::impl::MutableArray* getMutableArray(fleece::slice key)      {return mutable_dict_->getMutableArray(key);}
    fleece::impl::MutableDict* getMutableDict(fleece::slice key)        {return mutable_dict_->getMutableDict(key);}
    void setBody(const std::string &body);
};
#endif //SGMUTABLEDOCUMENT_H
