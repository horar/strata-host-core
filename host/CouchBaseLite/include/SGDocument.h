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
//#include "c4Document.h"
#include "SGDatabase.h"

class SGDocument {
public:
    SGDocument();
    SGDocument(class SGDatabase *database, std::string docId);
    const std::string &getId() const;
    void setId(const std::string &id);
    const std::string &getBody() const;
    void setBody(const std::string &body_);



    // Check if document exist in DB
    bool exist();

private:
    C4Database*     c4db_;
    C4Document*     c4document_;

    // Document ID
    std::string     id_;
    std::string     body_;

};


#endif //SGDOCUMENT_H
