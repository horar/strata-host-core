#ifndef HOST_HCS_CLIENT_H__
#define HOST_HCS_CLIENT_H__

#include <QString>
#include <QByteArray>

class Connector;

class HCS_Client final
{
public:
    HCS_Client(const QByteArray& client_id);
    ~HCS_Client();

    QByteArray getClientId() const { return client_id_; }

    //sets the PlatformId that client is connected to.
    void setPlatformId(const QString& platformId);
    void resetPlatformId();
    QString getPlatformId() const { return platformId_; }

private:
    QByteArray client_id_;    //or dealerId
    QString platformId_;   //selected platformId by client
};

#endif //HOST_HCS_CLIENT_H__
