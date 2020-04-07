
#include "DownloadManager.h"
#include "logging/LoggingQtCategories.h"

#include <QFile>
#include <QUuid>
#include <QFileInfo>
#include <QDir>
#include <QRandomGenerator>
#include <QTimer>

DownloadManager::DownloadManager(QObject *parent)
    : QObject(parent)
{
    accessManager_ = new QNetworkAccessManager(this);
}

DownloadManager::~DownloadManager()
{
    for (QNetworkReply* reply : currentDownloads_) {
        reply->abort();
        reply->deleteLater();
    }

    qDeleteAll(groupHash_);
    groupHash_.clear();
}

void DownloadManager::setBaseUrl(const QString &baseUrl)
{
    baseUrl_ = baseUrl;
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

    DownloadGroup *group = new DownloadGroup;
    group->id = QUuid::createUuid().toString(QUuid::WithoutBraces);
    group->settings = settings;
    groupHash_.insert(group->id, group);

    qCDebug(logCategoryHcsDownloader()) << "new download request" << group->id;

    for (const auto& requestItem : itemList) {
        DownloadItem item;
        item.url = baseUrl_ + requestItem.partialUrl;
        item.originalFilePath = requestItem.filePath;
        item.effectiveFilePath = requestItem.filePath;
        item.md5 = requestItem.md5;
        item.groupId = group->id;
        item.state = DownloadState::Pending;

        itemList_.append(item);
        itemHash_.insert(item.url, &itemList_.last());

        qCDebug(logCategoryHcsDownloader())
                << "download item"
                << item.url << item.originalFilePath;
    }

    //to make sure reponse is always asynchronious
    QTimer::singleShot(1, [this]() {
        for (int i = 0; i < maxDownloadCount_; ++i) {
            startNextDownload();
        }
    });

    return group->id;
}

bool DownloadManager::verifyFileChecksum(
        const QString &filePath,
        const QString &checksum,
        const QCryptographicHash::Algorithm &method)
{
    QFile file(filePath);
    if (file.open(QIODevice::ReadOnly) == false) {
        return false;
    }

    QCryptographicHash hash(method);
    hash.addData(&file);

    return checksum == hash.result().toHex();
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
    for (const auto& item : itemList_) {

        if (item.groupId != groupId) {
            continue;
        }

        DownloadResponseItem responseItem;
        responseItem.originalFilePath = item.originalFilePath;
        responseItem.effectiveFilePath = item.effectiveFilePath;
        responseItem.errorString = item.errorString;

        list.append(responseItem);
    }

    return list;
}

void DownloadManager::abortAll(const QString &groupId)
{
    //stops pending requests
    for (auto &item : itemList_) {
        if (item.groupId != groupId) {
            continue;
        }

        if (item.state == DownloadState::Pending) {
            prepareResponse(&item, "All downloads in group aborted");
        }
    }

    //stops running requests
    for (auto const &reply : currentDownloads_) {
        DownloadItem *downloadItem = itemHash_.value(reply->url().toString(), nullptr);
        if (downloadItem == nullptr) {
            continue;
        }

        if (downloadItem->groupId != groupId) {
            continue;
        }

        downloadItem->errorString = "All downloads in group aborted";

        reply->abort();
    }
}

void DownloadManager::readyReadHandler()
{
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(QObject::sender());
    if (reply == nullptr) {
        return;
    }

    DownloadItem *downloadItem = itemHash_.value(reply->url().toString(), nullptr);
    if (downloadItem == nullptr) {
        qCWarning(logCategoryHcsDownloader) << "cannot find item with url" << reply->url().toString();
        return;
    }

    QByteArray buffer = reply->readAll();

    if (buffer.size() > 0) {
        downloadItem->errorString = writeToFile(downloadItem->effectiveFilePath, buffer);
        if (downloadItem->errorString.isEmpty() == false) {
            reply->abort();
        }
    }
}

void DownloadManager::downloadProgressHandler(qint64 bytesReceived, qint64 bytesTotal)
{
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(QObject::sender());
    if (reply == nullptr) {
        return;
    }

    DownloadItem *downloadItem = itemHash_.value(reply->url().toString(), nullptr);
    if (downloadItem == nullptr) {
        qDebug(logCategoryHcsDownloader) << "cannot find item with url" << reply->url().toString();
        return;
    }

    reply->setProperty("newProgress", true);

    DownloadGroup *group = groupHash_.value(downloadItem->groupId, nullptr);
    if (group == nullptr) {
        qWarning(logCategoryHcsDownloader) << "cannot find groupId" << downloadItem->groupId;
        return;
    }

    if (group->settings.notifySingleDownloadProgress) {
        emit singleDownloadProgress(downloadItem->groupId, downloadItem->originalFilePath, bytesReceived, bytesTotal);
    }
}

void DownloadManager::finishedHandler()
{
    QNetworkReply* reply = qobject_cast<QNetworkReply*>( QObject::sender() );
    if (reply == nullptr) {
        return;
    }

    qCDebug(logCategoryHcsDownloader) << reply->url().toString();

    DownloadItem *downloadItem = itemHash_.value(reply->url().toString(), nullptr);
    if (downloadItem == nullptr) {
        qCWarning(logCategoryHcsDownloader) << "cannot find item with url" << reply->url().toString();
        return;
    }

    QString errorString;
    if (reply->error() == QNetworkReply::NoError) {
        if (isHttpRedirect(reply)) {

            qCWarning(logCategoryHcsDownloader)
                    << "Download request redirected"
                    << reply->url().toString();

            errorString = "request redirected";
        } else {
            QByteArray buffer = reply->readAll();

            if (buffer.size() > 0) {
                errorString = writeToFile(downloadItem->effectiveFilePath, buffer);
            }

            if (downloadItem->md5.isEmpty() == false) {
                if (verifyFileChecksum(downloadItem->effectiveFilePath, downloadItem->md5) == false) {
                    errorString = "checksum verification failed";
                }
            }
        }
    } else {
        errorString = "Network Error: " + reply->errorString();
    }

    prepareResponse(downloadItem, errorString);

    currentDownloads_.removeAll(reply);
    reply->deleteLater();

    if (downloadItem->state == DownloadState::FinishedWithError) {
        DownloadGroup *group = groupHash_.value(downloadItem->groupId, nullptr);
        if (group == nullptr) {
            qWarning(logCategoryHcsDownloader) << "cannot find groupId" << downloadItem->groupId;
        } else if (group->settings.oneFailsAllFail) {
            abortAll(downloadItem->groupId);
        }
    }

    startNextDownload();
}

void DownloadManager::startNextDownload()
{
    if (currentDownloads_.length() >= maxDownloadCount_) {
        return;
    }

    while (true) {
        DownloadItem *nextDownload = findNextDownload();
        if (nextDownload == nullptr) {
            //nothing else to download
            break;
        }

        DownloadGroup *group = groupHash_.value(nextDownload->groupId, nullptr);
        if (group == nullptr) {
            qWarning(logCategoryHcsDownloader) << "cannot find groupId" << nextDownload->groupId;
            continue;
        }

        createFolderForFile(nextDownload->originalFilePath);

        if (QFileInfo::exists(nextDownload->originalFilePath)) {
            if (group->settings.keepOriginalName) {
                if (nextDownload->md5.isEmpty()
                        || verifyFileChecksum(nextDownload->effectiveFilePath, nextDownload->md5) == false) {
                    //remove file, so it can be downloaded again
                    if (QFile::remove(nextDownload->originalFilePath) == false) {
                        prepareResponse(nextDownload, "file already exists and removal failed");
                        continue;
                    }
                } else {
                    //skip download
                    qCDebug(logCategoryHcsDownloader())
                            << "file exists => skip" << nextDownload->originalFilePath;

                    prepareResponse(nextDownload);
                    continue;
                }
            } else {
                //rename
                nextDownload->effectiveFilePath = resolveUniqueFilePath(nextDownload->originalFilePath);

                emit filePathChanged(nextDownload->groupId, nextDownload->originalFilePath, nextDownload->effectiveFilePath);
            }
        }

        QNetworkReply* reply = postRequest(nextDownload->url);
        if (reply != nullptr) {
            qCDebug(logCategoryHcsDownloader) << "start download " << nextDownload->url << "into" << nextDownload->effectiveFilePath;

            nextDownload->state = DownloadState::Running;
            break;
        }

        prepareResponse(nextDownload, "could not post a download request");
    }
}

DownloadManager::DownloadItem* DownloadManager::findNextDownload()
{
    for (DownloadItem &item : itemList_) {
        if (item.state == DownloadState::Pending) {
            return &item;
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

QNetworkReply *DownloadManager::postRequest(const QString &url)
{
    QNetworkRequest request(QUrl::fromUserInput(url));
    QNetworkReply *reply = accessManager_->get(request);

    if (reply == nullptr) {
        return reply;
    }

    ReplyTimeout::set(reply, 20000);
    reply->setProperty("newProgress", false);

    connect(reply, &QNetworkReply::readyRead, this, &DownloadManager::readyReadHandler);

    connect(reply, &QNetworkReply::downloadProgress, this, &DownloadManager::downloadProgressHandler);

    connect(reply, &QNetworkReply::finished, this, &DownloadManager::finishedHandler);

    currentDownloads_.append(reply);

    return reply;
}

bool DownloadManager::isHttpRedirect(QNetworkReply *reply)
{
    int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    return statusCode == 301 || statusCode == 302 || statusCode == 303
            || statusCode == 305 || statusCode == 307 || statusCode == 308;
}

QString DownloadManager::writeToFile(const QString &filePath, const QByteArray &buffer)
{
     QFile file(filePath);
     if (file.open(QIODevice::ReadWrite) == false) {
         return "Unable to open file: " + file.errorString();
     }

     uint64_t file_size = file.size();
     file.seek(file_size);

     qint64 written = file.write(buffer);
     if (written != buffer.size()) {
         return "Unable to write to file: " + file.errorString();
     }

     return QString();
}

void DownloadManager::prepareResponse(DownloadItem *downloadItem, const QString &errorString)
{
    if (downloadItem == nullptr) {
        return;
    }

    DownloadGroup *group = groupHash_.value(downloadItem->groupId, nullptr);
    if (group == nullptr) {
        qWarning(logCategoryHcsDownloader) << "cannot find groupId" << downloadItem->groupId;
        return;
    }

    if (errorString.isEmpty()) {
        downloadItem->state = DownloadState::Finished;
    } else {
        qCWarning(logCategoryHcsDownloader())
                << errorString
                << downloadItem->effectiveFilePath
                << downloadItem->url;

        if (downloadItem->state == DownloadState::Running) {
            qCDebug(logCategoryHcsDownloader) << "removing unfinished file" << downloadItem->effectiveFilePath;
            QFile::remove(downloadItem->effectiveFilePath);
        }

        if (downloadItem->errorString.isEmpty()) {
            downloadItem->errorString = errorString;
        }

        downloadItem->state = DownloadState::FinishedWithError;

        if (group->errorString.isEmpty()) {
            group->errorString = downloadItem->errorString;
        }
    }

    if (group->settings.notifySingleDownloadFinished) {
        emit singleDownloadFinished(downloadItem->groupId, downloadItem->originalFilePath, downloadItem->errorString);
    }

    int filesFailed, filesCompleted, filesTotal;
    resolveGroupProgress(downloadItem->groupId, filesFailed, filesCompleted, filesTotal);

    qCDebug(logCategoryHcsDownloader) << downloadItem->groupId
             << "failed=" << filesFailed
             << "completed=" << filesCompleted
             << "total=" << filesTotal;

    if (group->settings.notifyGroupDownloadProgress) {
        emit groupDownloadProgress(downloadItem->groupId, filesCompleted, filesTotal);
    }

    if (filesCompleted == filesTotal) {
        emit groupDownloadFinished(downloadItem->groupId, group->errorString);

        //clear all requests for this group
        clearData(downloadItem->groupId);
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

    for (auto const &item : itemList_) {
        if (item.groupId == groupId) {
            ++filesTotal;
            if (item.state == DownloadState::Finished
                    || item.state == DownloadState::FinishedWithError) {

                ++filesCompleted;
            }

            if (item.state == DownloadState::FinishedWithError) {
                ++filesFailed;
            }
        }
    }
}

void DownloadManager::clearData(const QString groupId)
{
    QMutableListIterator<DownloadItem> iter(itemList_);
    while (iter.hasNext()) {
        DownloadItem &item = iter.next();
        if (item.groupId == groupId) {
            itemHash_.remove(item.url);
            iter.remove();
        }
    }

    groupHash_.remove(groupId);
}

void ReplyTimeout::timerEvent(QTimerEvent *ev)
{
    if (mSec_timer_.isActive() == false
            || ev->timerId() != mSec_timer_.timerId()) {
        return;
    }

    QNetworkReply* reply = qobject_cast<QNetworkReply*>(QObject::parent());

    if (reply->isRunning()){
        if (reply->property("newProgress").toBool()) {
            qCDebug(logCategoryHcsDownloader) << "Restarting timeout timer for:" << reply->url();
            mSec_timer_.start(this->milliseconds_, this);
            reply->setProperty("newProgress", false);
            return;
        } else {
            qCDebug(logCategoryHcsDownloader) << "Time is up. Manually closing:" << reply->url();
            reply->close();
        }
    }
    mSec_timer_.stop();
}
