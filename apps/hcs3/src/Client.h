#pragma once

#include <QByteArray>
#include <QString>

class Connector;

class Client final
{
public:
    Client(const QByteArray& client_id);
    ~Client();

    QByteArray getClientId() const;

private:
    QByteArray client_id_;  // or dealerId
};
