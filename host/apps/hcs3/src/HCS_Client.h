
#ifndef HOST_HCS_CLIENT_H__
#define HOST_HCS_CLIENT_H__

#include <string>

class Connector;

class HCS_Client final
{
public:
    HCS_Client(const std::string& client_id);
    ~HCS_Client();

    std::string getClientId() const { return client_id_; }

    //sets the PlatformId that client is connected to.
    void setPlatformId(const std::string& platformId);
    void resetPlatformId();
    std::string getPlatformId() const { return platformId_; }

private:
    std::string client_id_;    //or dealerId
    std::string platformId_;   //selected platformId by client
};

#endif //HOST_HCS_CLIENT_H__
