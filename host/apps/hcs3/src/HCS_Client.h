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

private:
    QByteArray client_id_;    //or dealerId
};

#endif //HOST_HCS_CLIENT_H__
