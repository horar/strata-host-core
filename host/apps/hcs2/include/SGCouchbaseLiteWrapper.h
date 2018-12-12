/**
******************************************************************************
* @file SGCouchbaseWrapper.h
* @author Prasanth Vivek
* $Rev: 1 $
* $Date: 2018-12-07
* @brief Implements the public Class for SGCouchbaseLiteCPP wrapper
******************************************************************************

* @copyright Copyright 2018 On Semiconductor
*/

#ifndef SGCOUCHBASELITE_WRAPPER_H
#define SGCOUCHBASELITE_WRAPPER_H

// standard library
#include <iostream>
#include <list>

#include "FleeceImpl.hh"
#include "MutableArray.hh"
#include "MutableDict.hh"
#include "Doc.hh"

#include "SGReplicator.h"
#include "SGDatabase.h"
#include "SGDocument.h"
#include "SGMutableDocument.h"
#include "SGAuthenticator.h"

#define PRINT_DEBUG 1
#define LOG_DEBUG(lvl, fmt, ...)						\
	do { if (lvl>0) fprintf(stderr, fmt, __VA_ARGS__); } while (0)
// struct that will be added to the list
typedef struct{
    std::string platform_uuid;
    std::string platform_verbose;
    std::string connection_status;
}platform_details;
typedef std::list<platform_details> platformList;

class SGCouchbaseLiteWrapper {
public:
    // constructor
    SGCouchbaseLiteWrapper(std::string database);
    ~SGCouchbaseLiteWrapper();
    bool openDocument(std::string document_name);
    bool getStoredPlatforms(platformList &);
    bool addPlatformtoDB(const std::string& platform_uuid, const std::string& verbose);
private:
    SGDatabase *sgDatabase_;
    SGMutableDocument *sg_platform_document_;
};

#endif
