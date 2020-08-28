#include "RestClient.h"
#include "Authenticator.h"
#include "logging/LoggingQtCategories.h"

Deferred::Deferred(QObject *parent)
    : QObject(parent)
{
}

void Deferred::callSuccess(int status, QByteArray data)
{
    emit finishedSuccessfully(status, data);
}

void Deferred::callError(int status, QString errorString)
{
    emit finishedWithError(status, errorString);
}

RestClient::RestClient(QObject *parent)
    : QObject(parent)
{
}

RestClient::~RestClient()
{
    qDeleteAll(deferredList_);
    qDeleteAll(replyList_);
}

void RestClient::init(
        QUrl &baseUrl,
        QNetworkAccessManager *manager,
        Authenticator *authenticator)
{
    baseUrl_ = baseUrl;
    networkManager_ = manager;
    authenticator_ = authenticator;
}

Deferred* RestClient::post(
        QUrl endpoint,
        QVariantMap rawHeaderData,
        QByteArray data)
{
    QNetworkRequest request = resolveRequest(endpoint, rawHeaderData);
    Deferred *deferred = resolveDeferred(request);
    QNetworkReply *reply = networkManager_->post(request, data);

    connect(reply, &QNetworkReply::finished, this, &RestClient::replyFinished);
    replyList_.append(reply);

    return deferred;
}

Deferred* RestClient::get(
        QUrl endpoint,
        QVariantMap rawHeaderData)
{
    QNetworkRequest request = resolveRequest(endpoint, rawHeaderData);
    Deferred *deferred = resolveDeferred(request);
    QNetworkReply *reply = networkManager_->get(request);

    connect(reply, &QNetworkReply::finished, this, &RestClient::replyFinished);
    replyList_.append(reply);

    return deferred;
}

void RestClient::replyFinished()
{
    QNetworkReply* reply = qobject_cast<QNetworkReply*>( QObject::sender() );
    if (reply == nullptr) {
        qCCritical(logCategoryPrtRestClient) << "cannot cast reply";
        return;
    }

    Deferred *deferred = qobject_cast<Deferred*>(reply->request().originatingObject());
    if (deferred == nullptr) {
        qCCritical(logCategoryPrtRestClient) << "cannot cast originating object";
        return;
    }

    int statusCode =  reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    QByteArray data = reply->readAll();

    if (reply->error() == QNetworkReply::NoError) {
        deferred->callSuccess(statusCode, data);
    } else {
        deferred->callError(statusCode, reply->errorString());
    }

    deferredList_.removeOne(deferred);
    replyList_.removeOne(reply);

    deferred->deleteLater();
    reply->deleteLater();
}

QNetworkRequest RestClient::resolveRequest(
        QUrl endpoint,
        QVariantMap &rawHeaderData)
{
    QUrl url = baseUrl_.resolved(endpoint);
    QNetworkRequest request(url);

    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    if (authenticator_->xAccessToken().isEmpty() == false) {
        request.setRawHeader("x-access-token", authenticator_->xAccessToken());
    }

    QVariantMap::const_iterator iter = rawHeaderData.constBegin();
    while (iter != rawHeaderData.constEnd()) {
        request.setRawHeader(iter.key().toUtf8(), iter.value().toByteArray());
        ++iter;
    }

    return request;
}

Deferred *RestClient::resolveDeferred(QNetworkRequest &request)
{
    Deferred *deferred = new Deferred();
    request.setOriginatingObject(deferred);
    deferredList_.append(deferred);

    return deferred;
}
