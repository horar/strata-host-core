#include "HCS_Client.h"

HCS_Client::HCS_Client(const QByteArray& client_id) : client_id_(client_id)
{

}

HCS_Client::~HCS_Client()
{

}

void HCS_Client::setPlatformId(const QString& classId)
{
    platformId_ = classId;
}

void HCS_Client::resetPlatformId()
{
    platformId_.clear();
}
