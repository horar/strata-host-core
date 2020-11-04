#pragma once

#include <QtCore>
#include <QByteArray>
#include <QString>

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
