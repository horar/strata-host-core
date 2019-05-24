/**
******************************************************************************
* @file SGDocument .H
* @author Luay Alshawi
* $Rev: 1 $
* $Date:
* @brief Document c++ object to map a raw document in DB to c++ object. Similar to ORM. Gives read only to the document body
******************************************************************************
* @copyright Copyright 2018 ON Semiconductor
*/
#ifndef SGDOCUMENT_H
#define SGDOCUMENT_H

#include <string>
#include "SGDatabase.h"
#include <c4Document+Fleece.h>
#include <FleeceImpl.hh>
#include <MutableArray.hh>
#include <MutableDict.hh>

namespace Spyglass {
    // Forward declaration is required due to the circular include for SGDatabase<->SGDocument.
    class SGDatabase;

    class SGDocument {
    public:
        SGDocument();

        virtual ~SGDocument();

        SGDocument(SGDatabase *database, const std::string &docId);

        C4Document *getC4document() const;

        const std::string &getId() const;

        void setId(const std::string &id);

        /** SGDocument getBody.
        * @brief Stringify fleece object (mutable_dict_) to string json format.
        */
        const std::string getBody() const;

        /** SGDocument asDict.
        * @brief Return the internal mutable_dict_ as fleece Dict object.
        */
        const fleece::impl::Dict *asDict() const;

        /** SGDocument empty.
        * @brief check if MutableDict is empty.
        */
        bool empty() const;

        /** SGDocument get.
        * @brief MutableDict wrapper to access document data.
        * @param keyToFind The reference to the key.
        */
        const fleece::impl::Value *get(const std::string &keyToFind);

        /** SGDocument exist.
        * @brief Check if the document exist in the DB.
        */
        bool exist() const;

    private:
        C4Database *c4db_{nullptr};
        C4Document *c4document_{nullptr};
        // Document ID
        std::string id_;

        void setC4document(C4Document *);

        friend SGDatabase;
    protected:

        /** SGDocument initMutableDict.
        * @brief Loads the document's body and set it to mutable_dict_, if the document exist. Otherwise init mutable_dict_
        */
        void initMutableDict();

        fleece::Retained<fleece::impl::MutableDict> mutable_dict_;
    };
}

#endif //SGDOCUMENT_H
