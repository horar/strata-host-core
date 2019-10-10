
#include "HCS_Client.h"

#include <algorithm>

HCS_Client::HCS_Client(const std::string& client_id) : client_id_(client_id)
{

}

HCS_Client::~HCS_Client()
{

}

void HCS_Client::setPlatformId(const std::string& classId)
{
    platformId_ = classId;
}

void HCS_Client::resetPlatformId()
{
    platformId_.clear();
}

void HCS_Client::setJWT(const std::string& token)
{
    jwt_ = token;
}

void HCS_Client::setUsername(const std::string& name)
{
    user_name_ = name;

    // store them as lower case, since we use the username to check with
    // discovery service subscriber socket value of usernames that are always
    // lower case
    std::transform(user_name_.begin(),user_name_.end(),user_name_.begin(), ::tolower);
}

void HCS_Client::clearUsernameAndToken()
{
    jwt_.clear();
    user_name_.clear();
}
