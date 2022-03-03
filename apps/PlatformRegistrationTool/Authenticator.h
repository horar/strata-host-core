/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QPointer>
#include <QObject>
#include <QNetworkAccessManager>

class Deferred;
class RestClient;

class Authenticator : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(Authenticator)

    Q_PROPERTY(QByteArray sessionId READ sessionId NOTIFY sessionIdChanged)
    Q_PROPERTY(QByteArray xAccessToken READ xAccessToken NOTIFY xAccessTokenChanged)
    Q_PROPERTY(QString username READ username NOTIFY usernameChanged)
    Q_PROPERTY(QString firstname READ firstname NOTIFY firstnameChanged)
    Q_PROPERTY(QString lastname READ lastname NOTIFY lastnameChanged)

public:
    Authenticator(RestClient *restClient, QObject* parent = nullptr);
    ~Authenticator() override;

    Q_INVOKABLE void renewSession();
    Q_INVOKABLE void login(
            const QString &username,
            const QString &password,
            bool storeXAccessToken=false);

    Q_INVOKABLE void logout();

    QByteArray sessionId() const;
    QByteArray xAccessToken() const;
    QString username() const;
    QString firstname() const;
    QString lastname() const;

signals:
    void loginStarted();
    void loginFinished(bool status, QString errorString);
    void renewSessionStarted();
    void renewSessionFinished(bool status, QString errorString);
    void logoutStarted();
    void logoutFinished(bool status);
    void sessionIdChanged();
    void xAccessTokenChanged();
    void usernameChanged();
    void firstnameChanged();
    void lastnameChanged();

private:
    QPointer<RestClient> restClient_;
    QUrl baseUrl_;
    QByteArray sessionId_;
    QByteArray xAccessToken_;
    QString username_;
    QString firstname_;
    QString lastname_;

    void writeSettings(bool storeXAccessToken=false);
    void readSettings();

    void setSessionId(const QByteArray &sessionId);
    void setXAccessToken(const QByteArray &xAccessToken);
    void setUsername(const QString &username);
    void setFirstname(const QString &firstname);
    void setLastname(const QString &lastname);

    bool parseLoginReply(const QByteArray &data);
    bool parseRenewSessionReply(const QByteArray &data);
};
