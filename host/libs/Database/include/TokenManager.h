#pragma once

#include <QObject>

#include <QNetworkReply>

class TokenManager final : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(TokenManager)

public:
    TokenManager(QObject *parent = nullptr);

    QString getTokenID();

private:
    QString USER;
    QString PASSWORD;
    QString SG_SESSION_URL;
    QString OIDC_TOKEN_URL;
    QString CLIENT_ID;

    QNetworkReply *networkReply_OIDC = nullptr;
    QNetworkReply *networkReply_SG = nullptr;
    QNetworkAccessManager *netmgr = nullptr;

    QString createSessionCookie(const QString &idToken, const QString &SG_SESSION_URL);
};
