/**
******************************************************************************
* @file SGBasicAuthenticator .CPP
* @author Luay Alshawi
* $Rev: 1 $
* $Date: 11/27/18
* @brief Basic Authenticator Interface for the replicator.
******************************************************************************
* @copyright Copyright 2018 On Semiconductor
*/
#include "SGAuthenticator.h"
#include <c4Replicator.h>
using namespace fleece;
using namespace fleece::impl;
#define DEBUG(...) printf("SGBasicAuthenticator: "); printf(__VA_ARGS__)

namespace Spyglass {
    SGBasicAuthenticator::SGBasicAuthenticator() {}

    SGBasicAuthenticator::SGBasicAuthenticator(const std::string &username, const std::string &password) {
        setUserName(username);
        setPassword(password);
    }

    SGBasicAuthenticator::~SGBasicAuthenticator() {}

    void SGBasicAuthenticator::setUserName(const std::string &username) {
        username_ = username;
    }

    const std::string SGBasicAuthenticator::getUserName() const {
        return username_;
    }

    void SGBasicAuthenticator::setPassword(const std::string &password) {
        password_ = password;
    }

    const std::string SGBasicAuthenticator::getPassword() const {
        return password_;
    }

    void SGBasicAuthenticator::authenticate(fleece::Retained<fleece::impl::MutableDict> options) {
        fleece::Retained<fleece::impl::MutableDict> auth = fleece::impl::MutableDict::newDict();
        auth->set(slice(kC4ReplicatorAuthType), slice(kC4AuthTypeBasic));
        auth->set(slice(kC4ReplicatorAuthUserName), slice(username_));
        auth->set(slice(kC4ReplicatorAuthPassword), slice(password_));
        options->set(slice(kC4ReplicatorOptionAuthentication), auth);
    }
}