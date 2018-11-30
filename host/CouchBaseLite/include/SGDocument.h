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
#ifndef SGDOCUMENT_H
#define SGDOCUMENT_H

#include <string>
#include "SGDatabase.h"
#include "c4Document+Fleece.h"
#include "FleeceImpl.hh"
#include "MutableArray.hh"
#include "MutableDict.hh"
class SGDocument{
public:
    SGDocument();

    virtual ~SGDocument();

    SGDocument(class SGDatabase *database, const std::string &docId);

    C4Document *getC4document() const;

    const std::string &getId() const;
    void setId(const std::string &id);
    const std::string &getBody() const;
    void setBody(const std::string &body_);

    bool empty();
    const fleece::impl::Value* get(const std::string &keyToFind);

    // Check if document exist in DB
    bool exist();

private:
    C4Database*     c4db_;
    C4Document*     c4document_;
    // Document ID
    std::string     id_;
    std::string     body_;
    friend class    SGDatabase;
protected:
    bool setC4Document(SGDatabase *database, const std::string &docId);
    fleece::Retained<fleece::impl::MutableDict> mutable_dict_;
};


#endif //SGDOCUMENT_H
