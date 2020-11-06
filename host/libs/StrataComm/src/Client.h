#pragma once

#include <QtCore>
#include <QByteArray>
#include <QString>

namespace strata::strataComm {
class Client
{
public:
    Client(const QByteArray clientId, const QString APIVersion);
    ~Client();
    QByteArray getClientID() const;
    QString getApiVersion() const;

private:
    QByteArray clientId_;
    QString APIVersion_;
};

}   // namespace strata::strataComm
