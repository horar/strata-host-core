
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
