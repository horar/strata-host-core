/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */

#include "DownloadManager.h"
#include "logging/LoggingQtCategories.h"
#include "InternalDownloadRequest.h"
#include "ReplyTimeout.h"

#include <QFile>
#include <QUuid>
#include <QFileInfo>
#include <QDir>
#include <QRandomGenerator>
#include <QTimer>
#include <chrono>


using namespace std::literals::chrono_literals;

namespace strata {

DownloadManager::DownloadManager(QNetworkAccessManager *manager, QObject *parent)
    : QObject(parent),
      networkManager_(manager)
{
}

DownloadManager::~DownloadManager()
{
    for (QNetworkReply* reply : currentDownloads_) {
        reply->abort();
        reply->deleteLater();
    }

    qDeleteAll(internalRequestList_);
    qDeleteAll(groupHash_);
    groupHash_.clear();
}

void DownloadManager::setMaxDownloadCount(int maxDownloadCount)
{
    if (maxDownloadCount < 1) {
        return;
    }

    maxDownloadCount_ = maxDownloadCount;
}

QString DownloadManager::download(
        const QList<DownloadRequestItem> &itemList,
        const Settings &settings)
{
    QString groupId = QUuid::createUuid().toString(QUuid::WithoutBraces);

    qCDebug(logCategoryDownloadManager) << "new download request" << groupId;

    if (itemList.isEmpty()) {
        QTimer::singleShot(1ms, [this, groupId]() {
            emit groupDownloadFinished(groupId, "Nothing to download");
        });

       return groupId;
    }

    DownloadGroup *group = new DownloadGroup;
    group->id = groupId;
    group->settings = settings;
    groupHash_.insert(group->id, group);
    bool oneValidRequest = false;

    for (const auto& requestItem : itemList) {
        InternalDownloadRequest *internalRequest = new InternalDownloadRequest();
        internalRequest->groupId = group->id;

        processRequest(internalRequest, requestItem);

        if (internalRequest->state == InternalDownloadRequest::DownloadState::Pending) {
            oneValidRequest = true;
        }
    }

    //to make sure response is always asynchronious
    QTimer::singleShot(1ms, [this, oneValidRequest]() {
        if (oneValidRequest) {
            for (int i = 0; i < maxDownloadCount_; ++i) {
                startNextDownload();
            }
        } else {
            prepareResponse(internalRequestList_.last());
        }
    });

    return group->id;
}

bool DownloadManager::verifyFileHash(
        const QString &filePath,
        const QString &checksum,
        const QCryptographicHash::Algorithm method)
{
    QFile file(filePath);
    if (file.open(QIODevice::ReadOnly) == false) {
        return false;
    }

    QCryptographicHash hash(method);
    hash.addData(&file);

    return checksum.toLower() == hash.result().toHex();
}

/*
file.txt -> file-1.txt -> file-2.txt
*/
QString DownloadManager::resolveUniqueFilePath(const QString &filePath)
{
    QFileInfo info(filePath);

    QString uniqueFilePath = filePath;
    int index = 1;
    while (QFileInfo::exists(uniqueFilePath))
    {
        QString addition = "-" + QString::number(index);
        uniqueFilePath = filePath;
        uniqueFilePath.insert(uniqueFilePath.length() - info.completeSuffix().length() - 1, addition);

        ++index;
    }

    return uniqueFilePath;
}

QList<DownloadManager::DownloadResponseItem> DownloadManager::getResponseList(const QString &groupId)
{
    QList<DownloadResponseItem> list;
    for (const auto item : internalRequestList_) {

        if (item->groupId != groupId) {
            continue;
        }

        DownloadResponseItem responseItem;
        responseItem.originalFilePath = item->originalFilePath;
        responseItem.effectiveFilePath = item->savedFile.fileName();
        responseItem.errorString = item->errorString;

        list.append(responseItem);
    }

    return list;
}

void DownloadManager::abortAll(const QString &groupId)
{
    DownloadGroup *group = groupHash_.value(groupId, nullptr);
    if (group == nullptr) {
        qCCritical(logCategoryDownloadManager) << "cannot find groupId" << groupId;
        return;
    }

    if (group->aborted) {
        return;
    }

    group->aborted = true;

    //stops pending requests
    for (auto item : internalRequestList_) {
        if (item->groupId != groupId) {
            continue;
        }

        if (item->state == InternalDownloadRequest::DownloadState::Pending) {
            prepareResponse(item, "All downloads in group aborted");
        }
    }

    //stops running requests
    for (auto const &reply : currentDownloads_) {
        InternalDownloadRequest *internalRequest = qobject_cast<InternalDownloadRequest*>(reply->request().originatingObject());
        if (internalRequest == nullptr) {
            qCCritical(logCategoryDownloadManager) << "cannot cast originating object";
            continue;
        }

        if (internalRequest->groupId != groupId) {
            continue;
        }

        internalRequest->errorString = "All downloads in group aborted";

        if (reply->isRunning()) {
            abortReply(reply);
        }
    }
}

void DownloadManager::networkReplyReadyReadHandler()
{
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(QObject::sender());
    if (reply == nullptr) {
        return;
    }

    InternalDownloadRequest *internalRequest = qobject_cast<InternalDownloadRequest*>(reply->request().originatingObject());
    if (internalRequest == nullptr) {
        qCCritical(logCategoryDownloadManager) << "cannot cast originating object";
        return;
    }

    QByteArray buffer = reply->readAll();
    if (buffer.size() > 0) {
        internalRequest->errorString = writeToFile(internalRequest->savedFile, buffer);
        if (internalRequest->errorString.isEmpty() == false) {
            reply->abort();
        }
    }
}

void DownloadManager::networkReplyProgressHandler(qint64 bytesReceived, qint64 bytesTotal)
{
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(QObject::sender());
    if (reply == nullptr) {
        return;
    }


    InternalDownloadRequest *internalRequest = qobject_cast<InternalDownloadRequest*>(reply->request().originatingObject());
    if (internalRequest == nullptr) {
        qCCritical(logCategoryDownloadManager) << "cannot cast originating object";
        return;
    }

    reply->setProperty("newProgress", true);

    DownloadGroup *group = groupHash_.value(internalRequest->groupId, nullptr);
    if (group == nullptr) {
        qCCritical(logCategoryDownloadManager) << "cannot find groupId" << internalRequest->groupId;
        return;
    }

    if (group->settings.notifySingleDownloadProgress) {
        emit singleDownloadProgress(internalRequest->groupId, internalRequest->originalFilePath, bytesReceived, bytesTotal);
    }
}

void DownloadManager::networkReplyFinishedHandler()
{
    QNetworkReply* reply = qobject_cast<QNetworkReply*>( QObject::sender() );
    if (reply == nullptr) {
        return;
    }

    qCDebug(logCategoryDownloadManager) << reply->url().toString();

    InternalDownloadRequest *internalRequest = qobject_cast<InternalDownloadRequest*>(reply->request().originatingObject());
    if (internalRequest == nullptr) {
        qCCritical(logCategoryDownloadManager) << "cannot cast originating object";

        currentDownloads_.removeAll(reply);
        reply->deleteLater();
        startNextDownload();
        return;
    }

    internalRequest->savedFile.close();

    QString errorString;
    if (reply->error() == QNetworkReply::NoError) {
        if (isHttpRedirect(reply)) {

            qCWarning(logCategoryDownloadManager)
                    << "Download request redirected"
                    << reply->url().toString();

            errorString = "request redirected";
        } else {
            QByteArray data = reply->readAll();
            if (data.size() > 0) {
                errorString = writeToFile(internalRequest->savedFile, data);
            }

            if (internalRequest->md5.isEmpty() == false) {
                if (verifyFileHash(internalRequest->savedFile.fileName(), internalRequest->md5) == false) {
                    errorString = "hash verification failed";
                }
            }
        }
    } else {
        errorString = "Network Error: " + reply->errorString();
    }

    prepareResponse(internalRequest, errorString);

    currentDownloads_.removeAll(reply);
    reply->deleteLater();

    startNextDownload();
}

void DownloadManager::startNextDownload()
{
    if (currentDownloads_.length() >= maxDownloadCount_) {
        return;
    }

    while (true) {
        InternalDownloadRequest *nextDownload = findNextPendingDownload();
        if (nextDownload == nullptr) {
            //nothing else to download
            break;
        }

        bool ok = postNextDownloadRequest(nextDownload);
        if (ok) {
            break;
        }
    }
}

bool DownloadManager::postNextDownloadRequest(InternalDownloadRequest *internalRequest)
{
    if (internalRequest == nullptr) {
        qCCritical(logCategoryDownloadManager) << "internalRequest is NULL";
        return false;
    }

    DownloadGroup *group = groupHash_.value(internalRequest->groupId, nullptr);
    if (group == nullptr) {
        qCCritical(logCategoryDownloadManager) << "cannot find groupId" << internalRequest->groupId;
        return false;
    }

    if (QFileInfo::exists(internalRequest->savedFile.fileName())) {
        if (group->settings.keepOriginalName) {
            if (internalRequest->md5.length() > 0
                    && verifyFileHash(internalRequest->savedFile.fileName(), internalRequest->md5))
            {
                //md5 matches => no need to download it again => skip it
                prepareResponse(internalRequest);
                return false;
            }
        } else {
            //add suffix
            internalRequest->savedFile.setFileName(resolveUniqueFilePath(internalRequest->savedFile.fileName()));
        }
    } else {
        createFolderForFile(internalRequest->savedFile.fileName());
    }

    if (internalRequest->originalFilePath != internalRequest->savedFile.fileName()) {
        emit filePathChanged(internalRequest->groupId, internalRequest->originalFilePath, internalRequest->savedFile.fileName());
    }

    bool ok = internalRequest->savedFile.open(QIODevice::WriteOnly | QIODevice::Truncate);
    if (ok == false) {
        prepareResponse(internalRequest, "cannot open file");
        return false;
    }

    qCDebug(logCategoryDownloadManager) << "start download " << internalRequest->url.toString() << "into" << internalRequest->savedFile.fileName();

    QNetworkReply *reply = postNetworkRequest(internalRequest->url, internalRequest);
    if (reply == nullptr) {
        prepareResponse(internalRequest, "could not post a download request");
        return false;
    }

    internalRequest->state = InternalDownloadRequest::DownloadState::Running;

    return true;
}

void DownloadManager::processRequest(InternalDownloadRequest *internalRequest, const DownloadRequestItem &request)
{
    internalRequest->url = request.url;
    internalRequest->originalFilePath = request.filePath;
    internalRequest->savedFile.setFileName(request.filePath);
    internalRequest->md5 = request.md5;

    qCDebug(logCategoryDownloadManager)
            << "download item"
            << internalRequest->url.toString() << "to" << internalRequest->originalFilePath;

    if (request.url.isValid() == false) {
        internalRequest->state = InternalDownloadRequest::DownloadState::FinishedWithError;
        internalRequest->errorString = "url is not valid";
        qCCritical(logCategoryDownloadManager) << internalRequest->errorString << request.url.toString();
    } else if (request.url.scheme().length() == 0) {
        internalRequest->state = InternalDownloadRequest::DownloadState::FinishedWithError;
        internalRequest->errorString = "url does not have scheme";
        qCCritical(logCategoryDownloadManager) << internalRequest->errorString << request.url.toString();
    } else {
        internalRequest->state = InternalDownloadRequest::DownloadState::Pending;
    }

    internalRequestList_.append(internalRequest);
}

InternalDownloadRequest* DownloadManager::findNextPendingDownload()
{
    for (InternalDownloadRequest *item : internalRequestList_) {
        if (item->state == InternalDownloadRequest::DownloadState::Pending) {
            return item;
        }
    }

    return nullptr;
}

void DownloadManager::createFolderForFile(const QString &filePath)
{
    QFileInfo info(filePath);
    QDir basePath;
    basePath.mkpath(info.absolutePath());
}

QNetworkReply* DownloadManager::postNetworkRequest(const QUrl &url, QObject *originatingObject)
{
    QNetworkRequest request(url);
    request.setOriginatingObject(originatingObject);

    QNetworkReply *reply = networkManager_->get(request);

    if (reply == nullptr) {
        return reply;
    }

    ReplyTimeout::set(reply, 20000);
    reply->setProperty("newProgress", false);

    connect(reply, &QNetworkReply::readyRead, this, &DownloadManager::networkReplyReadyReadHandler);

    connect(reply, &QNetworkReply::downloadProgress, this, &DownloadManager::networkReplyProgressHandler);

    connect(reply, &QNetworkReply::finished, this, &DownloadManager::networkReplyFinishedHandler);

    currentDownloads_.append(reply);

    return reply;
}

bool DownloadManager::isHttpRedirect(QNetworkReply *reply)
{
    int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    return statusCode == 301 || statusCode == 302 || statusCode == 303
            || statusCode == 305 || statusCode == 307 || statusCode == 308;
}

QString DownloadManager::writeToFile(QFile &file, const QByteArray &data)
{
    if (file.openMode() == QIODevice::NotOpen) {
        return "File is not open.";
    }

    qint64 written = file.write(data);
    if (written != data.size()) {
        return "Unable to write to file. " + file.errorString();
    }

    return QString();
}

void DownloadManager::prepareResponse(InternalDownloadRequest *internalRequest, const QString &errorString)
{
    if (internalRequest == nullptr) {
        return;
    }

    DownloadGroup *group = groupHash_.value(internalRequest->groupId, nullptr);
    if (group == nullptr) {
        qCCritical(logCategoryDownloadManager) << "cannot find groupId" << internalRequest->groupId;
        return;
    }

    internalRequest->savedFile.close();

    if (errorString.isEmpty() && internalRequest->state != InternalDownloadRequest::DownloadState::FinishedWithError) {
        internalRequest->state = InternalDownloadRequest::DownloadState::Finished;
    } else {
        qCWarning(logCategoryDownloadManager)
                << "error=" << errorString
                << "filename=" << internalRequest->savedFile.fileName()
                << "url=" << internalRequest->url.toString();

        if (internalRequest->state == InternalDownloadRequest::DownloadState::Running && group->settings.removeCorruptedFile) {
            qCDebug(logCategoryDownloadManager) << "removing unfinished file" << internalRequest->savedFile.fileName();
            QFile::remove(internalRequest->savedFile.fileName());
        }

        if (internalRequest->errorString.isEmpty()) {
            internalRequest->errorString = errorString;
        }

        internalRequest->state = InternalDownloadRequest::DownloadState::FinishedWithError;

        if (group->errorString.isEmpty()) {
            group->errorString = internalRequest->errorString;
        }
    }

    if (group->settings.notifySingleDownloadFinished) {
        emit singleDownloadFinished(internalRequest->groupId, internalRequest->originalFilePath, internalRequest->errorString);
    }

    int filesFailed, filesCompleted, filesTotal;
    resolveGroupProgress(internalRequest->groupId, filesFailed, filesCompleted, filesTotal);

    qCDebug(logCategoryDownloadManager) << internalRequest->groupId
             << "failed=" << filesFailed
             << "completed=" << filesCompleted
             << "total=" << filesTotal;

    if (group->settings.notifyGroupDownloadProgress) {
        emit groupDownloadProgress(internalRequest->groupId, filesCompleted, filesTotal);
    }

    if (internalRequest->state == InternalDownloadRequest::DownloadState::FinishedWithError
            && group->settings.oneFailsAllFail)
    {
        abortAll(internalRequest->groupId);
    }

    if (filesCompleted == filesTotal) {
        emit groupDownloadFinished(internalRequest->groupId, group->errorString);

        clearData(internalRequest->groupId);
    }
}

void DownloadManager::resolveGroupProgress(
        const QString &groupId,
        int &filesFailed,
        int &filesCompleted,
        int &filesTotal)
{
    filesFailed = 0;
    filesCompleted = 0;
    filesTotal = 0;

    for (auto const item : internalRequestList_) {
        if (item->groupId == groupId) {
            ++filesTotal;
            if (item->state == InternalDownloadRequest::DownloadState::Finished
                    || item->state == InternalDownloadRequest::DownloadState::FinishedWithError) {

                ++filesCompleted;
            }

            if (item->state == InternalDownloadRequest::DownloadState::FinishedWithError) {
                ++filesFailed;
            }
        }
    }
}

void DownloadManager::clearData(const QString groupId)
{
    QMutableListIterator<InternalDownloadRequest*> iter(internalRequestList_);
    while (iter.hasNext()) {
        InternalDownloadRequest *item = iter.next();
        if (item->groupId == groupId) {
            delete item;
            iter.remove();
        }
    }

    groupHash_.remove(groupId);
}

void DownloadManager::abortReply(QNetworkReply *reply)
{
    //disconnect all except finished signal
    disconnect(reply, &QNetworkReply::readyRead, nullptr, nullptr);
    disconnect(reply, &QNetworkReply::downloadProgress, nullptr, nullptr);

    reply->abort();
}


} //namespace
