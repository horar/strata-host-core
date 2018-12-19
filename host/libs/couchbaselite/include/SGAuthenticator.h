/**
******************************************************************************
* @file SGAuthenticator .H
* @author Luay Alshawi
* $Rev: 1 $
* $Date: 11/27/18
* @brief Authenticate Interface for the replicator.
******************************************************************************
* @copyright Copyright 2018 On Semiconductor
*/
#ifndef SGAUTHENTICATOR_H
#define SGAUTHENTICATOR_H

#include <string>
#include "fleece/FLSlice.h"
#include "FleeceImpl.hh"
#include "MutableArray.hh"
#include "MutableDict.hh"
class SGAuthenticator {
public:
    SGAuthenticator(){}
    virtual ~SGAuthenticator(){}
    virtual void authenticate(fleece::Retained<fleece::impl::MutableDict> options) = 0;
};

class SGBasicAuthenticator: public SGAuthenticator{
public:
    SGBasicAuthenticator();
    SGBasicAuthenticator(const std::string &username, const std::string &password);
    virtual ~SGBasicAuthenticator();

    void setUserName(const std::string &username);
    const std::string getUserName() const;
    void setPassword(const std::string &password);
    const std::string getPassword() const;

    void authenticate(fleece::Retained<fleece::impl::MutableDict> options);

private:
    std::string username_;
    std::string password_;

};


#endif //SGAUTHENTICATOR_H
