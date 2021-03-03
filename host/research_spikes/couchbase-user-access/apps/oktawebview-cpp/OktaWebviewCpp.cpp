#include "OktaWebviewCpp.h"

#include <QJsonDocument>
#include <QJsonObject>

#include <QUrl>
#include <QNetworkRequest>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkCookie>
#include <QUrlQuery>
#include <QEventLoop>

#include <QtMath>
#include <QRandomGenerator>
#include <QCryptographicHash>
#include <QRegularExpression>

#include <QDebug>

OktaWebviewCpp::OktaWebviewCpp(QQmlApplicationEngine *engine, QObject *parent) : QObject(parent) {
    engine_ = engine;

    netmgr = new QNetworkAccessManager(this);

    clientId = "0oa8akdtteXGDfRz61d6";
    scope = "openid+profile";
    redirectUri = "www.onsemi.com";
    codeChallengeMethod = "S256";
    authServerVersion = "v1";
    authorizationServerUrl = "https://onsemi.oktapreview.com/oauth2";

    tokenEndpoint = "/" + authServerVersion + "/token";
    userInfoEndpoint = "/" + authServerVersion + "/userinfo";

    PKCEGenerate();
}

QString OktaWebviewCpp::buildOAuthUrl() {
    QUrlQuery query(authorizationServerUrl + "/" + authServerVersion + "/authorize?");
    query.addQueryItem("client_id", clientId);
    query.addQueryItem("response_type", "code");
    query.addQueryItem("scope", scope);
    query.addQueryItem("redirect_uri", "https://" + redirectUri);
    query.addQueryItem("state", "state0");
    query.addQueryItem("code_challenge_method", codeChallengeMethod);
    query.addQueryItem("code_challenge", codeChallenge);

    return query.toString();
}

QString OktaWebviewCpp::authenticate(const QString &authorizationCode) {
    QUrlQuery query;
    query.addQueryItem("grant_type", "authorization_code");
    query.addQueryItem("client_id", clientId);
    query.addQueryItem("code", authorizationCode);
    query.addQueryItem("code_verifier", codeVerifier);
    query.addQueryItem("redirect_uri", "https://" + redirectUri);

    QByteArray queryData = query.toString(QUrl::FullyEncoded).toUtf8();

    QEventLoop loop;
    QObject::connect(netmgr, &QNetworkAccessManager::finished, &loop, &QEventLoop::quit);

    QUrl authURL = QUrl((authorizationServerUrl + tokenEndpoint));
    QNetworkRequest networkRequest(authURL);
    networkRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");

    sessionNetworkReply = netmgr->post(networkRequest, queryData);
    loop.exec();
    QByteArray networkReplyData = sessionNetworkReply->readAll();

    QJsonDocument networkReplyJson = QJsonDocument::fromJson(networkReplyData);
    if (networkReplyJson.isNull() || networkReplyJson.isEmpty() || !networkReplyJson.isObject()) {
        qDebug() << "Error: received empty or invalid reply";
        return "";
    }

    QJsonObject networkReplyJsonObj = networkReplyJson.object();
    if (networkReplyJsonObj.isEmpty()) {
        qDebug() << "Error: received empty or invalid reply";
        return "";
    }

    const QJsonValue accessToken = networkReplyJsonObj.value("access_token");

    return accessToken.toString();;
}

QString OktaWebviewCpp::getUserInfo(const QString &accessToken) {
    QString BearerToken = "Bearer " + accessToken;

    QUrlQuery query;
    query.addQueryItem("Authorization", BearerToken.toLocal8Bit());
    QByteArray queryData = query.toString(QUrl::FullyEncoded).toUtf8();

    QEventLoop loop;
    QObject::connect(netmgr, &QNetworkAccessManager::finished, &loop, &QEventLoop::quit);

    QUrl authURL = QUrl(authorizationServerUrl + userInfoEndpoint);
    QNetworkRequest networkRequest(authURL);
    networkRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    networkRequest.setRawHeader("Authorization", BearerToken.toLocal8Bit());
    accessNetworkReply = netmgr->post(networkRequest, queryData);

    loop.exec();

    QByteArray networkReplyData = accessNetworkReply->readAll();

    return networkReplyData;
}

QString OktaWebviewCpp::getHost(const QUrl &url) {
    return url.host();
}

QString OktaWebviewCpp::queryItemValue(const QUrl &url, const QString &key) {
    QUrlQuery query(url);
    return query.queryItemValue(key);
}

void OktaWebviewCpp::PKCEGenerate(unsigned int length) {
    if (length < 43 || length > 128) {
        return;
    }
    codeVerifier = generateRandomString(length);
    codeChallenge = QCryptographicHash::hash(codeVerifier.toUtf8(), QCryptographicHash::Sha256).toBase64();

    codeChallenge = codeChallenge.replace(QRegularExpression("="), "")
                                 .replace(QRegularExpression("\\+"), "-")
                                 .replace(QRegularExpression("\\/"), "_");
}

QString OktaWebviewCpp::generateRandomString(unsigned int length) {
    const QString possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~";
    QString randomString;
    for (unsigned int i = 0; i < length; i++) {
        randomString += possible[ qFloor( QRandomGenerator::global()->bounded(possible.size()) ) ];
    }

    return randomString;
}
