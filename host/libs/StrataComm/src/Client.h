#pragma once

#include <QtCore>
#include <QByteArray>
#include <QString>

namespace strata::strataComm {
    
enum class ApiVersion {
        v1,
        v2,
        none
};

class Client
{
    

public:
    Client(const QByteArray clientId, const ApiVersion APIVersion);
    ~Client();
    QByteArray getClientID() const;
    ApiVersion getApiVersion() const;

private:
    QByteArray clientId_;
    ApiVersion APIVersion_;
};

}   // namespace strata::strataComm
