#include "TokenManager.h"

#include "logging/LoggingQtCategories.h"

#include <QUrl>
#include <QNetworkRequest>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkCookie>
#include <QUrlQuery>
#include <QEventLoop>

#include <QJsonDocument>
#include <QJsonObject>

TokenManager::TokenManager(QObject *parent) : QObject(parent) {
    USER = "paul";
    PASSWORD = "password";
    SG_SESSION_URL = "http://sync-gateway:4984/french_cuisine/_session";
    OIDC_TOKEN_URL = "http://keycloak:8080/auth/realms/couchbase/protocol/openid-connect/token/";
    CLIENT_ID = "SyncGatewayFrenchCuisine";
}

QString TokenManager::getTokenID() {
    QUrlQuery query;
    query.addQueryItem("username", USER);
    query.addQueryItem("password", PASSWORD);
    query.addQueryItem("client_id", CLIENT_ID);

    query.addQueryItem("grant_type", "password");
    query.addQueryItem("scope", "openid");

    QByteArray queryData = query.toString(QUrl::FullyEncoded).toUtf8();

    netmgr = new QNetworkAccessManager(this);
    QEventLoop loop;
    QObject::connect(netmgr, &QNetworkAccessManager::finished, &loop, &QEventLoop::quit);

    QUrl authURL = QUrl(OIDC_TOKEN_URL);
    QNetworkRequest networkRequest(authURL);
    networkRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");

    networkReply_OIDC = netmgr->post(networkRequest, queryData);
    loop.exec();
    QByteArray networkReplyData_OIDC = networkReply_OIDC->readAll();

    QJsonDocument networkReplyJsonDoc_OIDC = QJsonDocument::fromJson(networkReplyData_OIDC);
    if (networkReplyJsonDoc_OIDC.isNull() || networkReplyJsonDoc_OIDC.isEmpty() || !networkReplyJsonDoc_OIDC.isObject()) {
        qDebug() <<"Error: received empty or invalid reply to password_grant request";
        return "";
    }

    QJsonObject networkReplyJsonObj_OIDC = networkReplyJsonDoc_OIDC.object();
    if (networkReplyJsonObj_OIDC.isEmpty()) {
        qDebug() <<"Error: received empty or invalid reply to password_grant request";
        return "";
    }

    const QJsonValue idToken = networkReplyJsonObj_OIDC.value("id_token");
    const QString idTokenStr = idToken.toString();

    const QString cookie = createSessionCookie(idTokenStr, SG_SESSION_URL);
    if (cookie.isEmpty()) {
        qDebug() <<"Error: received empty or invalid cookie";
        return "";
    }

    return cookie;
}

QString TokenManager::createSessionCookie(const QString &idToken, const QString &SG_SESSION_URL) {
    QString BearerToken = "Bearer " + idToken;

    QUrlQuery query;
    query.addQueryItem("Authorization", BearerToken.toLocal8Bit());
    QByteArray queryData = query.toString(QUrl::FullyEncoded).toUtf8();

    QEventLoop loop;
    QObject::connect(netmgr, &QNetworkAccessManager::finished, &loop, &QEventLoop::quit);

    QUrl authURL = QUrl(SG_SESSION_URL);
    QNetworkRequest networkRequest(authURL);
    networkRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    networkRequest.setRawHeader("Authorization", BearerToken.toLocal8Bit());
    networkReply_SG = netmgr->post(networkRequest, queryData);

    loop.exec();

    if (!networkReply_SG->hasRawHeader("Set-Cookie")) {
        qDebug() <<"Error: invalid Set-Cookie header from SG reply";
        return "";
    }

    QByteArray setCookieHeader = networkReply_SG->rawHeader("Set-Cookie");

    return setCookieHeader;
}
