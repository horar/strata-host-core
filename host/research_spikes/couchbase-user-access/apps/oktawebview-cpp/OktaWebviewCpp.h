#pragma once

#include <QObject>
#include <QQmlApplicationEngine>

#include <QNetworkReply>

class OktaWebviewCpp: public QObject {
    Q_OBJECT

public:
    QQmlApplicationEngine* engine_;

    explicit OktaWebviewCpp(QQmlApplicationEngine *engine = nullptr, QObject *parent = nullptr);

    Q_INVOKABLE QString buildOAuthUrl();

    Q_INVOKABLE QString getHost(const QUrl &url);

    Q_INVOKABLE QString queryItemValue(const QUrl &url, const QString &key);

    Q_INVOKABLE QString authenticate(const QString &authorizationCode);

    Q_INVOKABLE QString getUserInfo(const QString &accessToken);

private:
    QString clientId = "";
    QString scope = "";
    QString redirectUri = "";
    QString codeChallengeMethod = "";
    QString authServerVersion = "";
    QString tokenEndpoint = "";
    QString userInfoEndpoint = "";
    QString authorizationServerUrl = "";
    QString codeChallenge = "";
    QString codeVerifier = "";

    QNetworkReply *sessionNetworkReply = nullptr;
    QNetworkReply *accessNetworkReply = nullptr;

    QNetworkAccessManager *netmgr = nullptr;

    void PKCEGenerate(unsigned int length = 43);

    QString generateRandomString(unsigned int length = 43);
};
