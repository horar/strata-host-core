#pragma once

#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QVariantMap>
#include <QUrl>
#include <QPointer>

class RestClient;
class Authenticator;

class Deferred: public QObject
{
    Q_OBJECT;
    Q_DISABLE_COPY(Deferred);

public:
    Deferred(QObject *parent = nullptr);

signals:
    void finishedSuccessfully(int status, QByteArray data);
    void finishedWithError(int status, QString errorString);

private:
    friend class RestClient;
    void callSuccess(int status, QByteArray data);
    void callError(int status, QString errorString);
};

class RestClient: public QObject {

    Q_OBJECT;
    Q_DISABLE_COPY(RestClient);

public:
    RestClient(QObject *parent = nullptr);
    ~RestClient();

    void init(
            QUrl &baseUrl,
            QNetworkAccessManager *manager,
            Authenticator *authenticator);

    Q_INVOKABLE Deferred *post(
            QUrl endpoint,
            QVariantMap rawHeaderData,
            QByteArray data);

    Q_INVOKABLE Deferred* get(
            QUrl endpoint,
            QVariantMap rawHeaderData=QVariantMap());

private slots:
    void replyFinished();

private:
    QPointer<QNetworkAccessManager> networkManager_;
    QPointer<Authenticator> authenticator_;
    QUrl baseUrl_;
    QList<QNetworkReply*> replyList_;
    QList<Deferred*> deferredList_;

    QNetworkRequest resolveRequest(QUrl endpoint, QVariantMap &rawHeaderData);
    Deferred *resolveDeferred(QNetworkRequest &request);
};
