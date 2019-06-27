
#include "DownloadManager.h"
#include "logging/LoggingQtCategories.h"

#include <QFile>

DownloadManager::DownloadManager(QObject* parent) : QObject(parent), numberOfDownloads_(4)
{
    manager_.reset(new QNetworkAccessManager(this) );

    QObject::connect(manager_.get(), &QNetworkAccessManager::finished, this, &DownloadManager::onDownloadFinished);
}

DownloadManager::~DownloadManager()
{
    //stop all downloads
    for (QNetworkReply* reply : currentDownloads_) {
        reply->abort();
        reply->deleteLater();
    }
}

void DownloadManager::setBaseUrl(const QString& baseUrl)
{
    baseUrl_ = baseUrl;

    qCDebug(logCategoryHcsDownloader) << "baseUrl:" << baseUrl_;
}

void DownloadManager::setMaxDownloadCount(uint count)
{
    if (count == 0) {
        return;
    }

    numberOfDownloads_ = count;
}

void DownloadManager::download(const QString& url, const QString& filename)
{
    DownloadItem item;
    item.url = url;
    item.filename = filename;
    item.state = "idle";

    downloadList_.push_back(item);

    qCDebug(logCategoryHcsDownloader) << "Download:" << url << "to file:" << filename;

    if (static_cast<uint>(currentDownloads_.size()) < numberOfDownloads_) {

        QList<DownloadItem>::iterator findIt = findNextDownload();
        if (findIt == downloadList_.end()) {
            return;
        }

        beginDownload(*findIt);
    }
}

void DownloadManager::beginDownload(DownloadItem& item)
{
    QString realUrl(baseUrl_ + item.url);
    QNetworkReply* reply = downloadFile(realUrl);
    if (reply == nullptr) {
        qCDebug(logCategoryHcsDownloader) << "downloadFile failed! url:" << item.url;
        return;
    }

    mapReplyToFile_.insert(reply, item.filename);
    qCDebug(logCategoryHcsDownloader) << "Begin downloading" << item.filename;

    item.state = "pending";
}

QNetworkReply* DownloadManager::downloadFile(const QString& url)
{
    QNetworkRequest request( QUrl::fromUserInput(url) );
    QNetworkReply *reply = manager_->get(request);
    if (reply == Q_NULLPTR) {
        return reply;
    }

    QObject::connect(reply, &QNetworkReply::readyRead, this, &DownloadManager::readyRead);
    QObject::connect(reply, QOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::error),
                      this, &DownloadManager::slotError);

#if QT_CONFIG(ssl)
    connect(reply, &QNetworkReply::sslErrors, this, &DownloadManager::sslErrors);
#endif

    currentDownloads_.append(reply);
    return reply;
}

bool DownloadManager::isHttpRedirect(QNetworkReply *reply)
{
    int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    return statusCode == 301 || statusCode == 302 || statusCode == 303
           || statusCode == 305 || statusCode == 307 || statusCode == 308;
}

void DownloadManager::readyRead()
{
    QNetworkReply* reply = qobject_cast<QNetworkReply*>( QObject::sender() );
    Q_ASSERT(reply);
    QByteArray buffer = reply->readAll();
    if (buffer.size() > 0) {
        writeToFile(reply, buffer);
    }
}

void DownloadManager::onDownloadFinished(QNetworkReply *reply)
{
    QUrl url = reply->url();
    if (reply->error()) {

        auto findIt = mapReplyToFile_.find(reply);
        if (findIt == mapReplyToFile_.end()) {
            return;
        }

        auto findItItem = findItemByFilename(findIt.value());
        if (findItItem != downloadList_.end()) {
            findItItem->state = "done";
        }

        qCWarning(logCategoryHcsDownloader) << "download error on:" << reply->url();
        emit downloadFinishedError(findItItem->url, reply->errorString());

    }
    else {
        if (isHttpRedirect(reply)) {
            qCWarning(logCategoryHcsDownloader) << "Redirection on a file download. " << reply->url().toString();
            //TODO: do we support redirects ?
            //   fputs("Request was redirected.\n", stderr);

        }
        else {

            QByteArray buffer = reply->readAll();
            if (buffer.size() > 0) {
                writeToFile(reply, buffer);
            }

            auto findIt = mapReplyToFile_.find(reply);
            if (findIt == mapReplyToFile_.end()) {
                return;
            }

            auto findItItem = findItemByFilename(findIt.value());
            if (findItItem != downloadList_.end()) {
                findItItem->state = "done";
            }

            qCInfo(logCategoryHcsDownloader) << "Downloaded:" << findItItem->url;

            emit downloadFinished(findItItem->url);

            if (static_cast<uint>(currentDownloads_.size()) <= numberOfDownloads_) {
                auto it = findNextDownload();
                if (it != downloadList_.end()) {
                    beginDownload(*it);
                }
            }
        }
    }

    currentDownloads_.removeAll(reply);
    reply->deleteLater();
}

void DownloadManager::writeToFile(QNetworkReply* reply, const QByteArray& buffer)
{
    auto findIt = mapReplyToFile_.find(reply);
    if (findIt == mapReplyToFile_.end()) {
        qCDebug(logCategoryHcsDownloader) << "Reply:" << reply->url() << "not found in map.";
        return;
    }

    QFile file( findIt.value() );
    if (file.open(QIODevice::ReadWrite) == false) {
        qCWarning(logCategoryHcsDownloader) << "Unable to open file:" << findIt.value() << "for:" << reply->url();
        return;
    }
    uint64_t file_size = file.size();
    file.seek(file_size);

    qint64 written = file.write(buffer);
    if (written != buffer.size()) {
        qCWarning(logCategoryHcsDownloader) << "Unable to write to file:" << findIt.value() << "for:" << reply->url();
    }
}

QList<DownloadManager::DownloadItem>::iterator DownloadManager::findNextDownload()
{
    QList<DownloadItem>::iterator findIt;
    for(findIt = downloadList_.begin(); findIt != downloadList_.end(); ++findIt) {
        if (findIt->state == "idle") {
            break;
        }
    }

    return findIt;
}

QList<DownloadManager::DownloadItem>::iterator DownloadManager::findItemByFilename(const QString& filename)
{
    QList<DownloadItem>::iterator findIt;
    for(findIt = downloadList_.begin(); findIt != downloadList_.end(); ++findIt) {
        if (findIt->filename == filename) {
            break;
        }
    }

    return findIt;
}

void DownloadManager::slotError(QNetworkReply::NetworkError /*err*/)
{
    QNetworkReply* reply = qobject_cast<QNetworkReply*>( QObject::sender() );
    Q_ASSERT(reply);

    qCWarning(logCategoryHcsDownloader) << "download error on:" << reply->url() << "err:" << reply->errorString();
}

void DownloadManager::sslErrors(const QList<QSslError>& errors)
{
    QNetworkReply* reply = qobject_cast<QNetworkReply*>( QObject::sender() );
    Q_ASSERT(reply);

    QString errorText;
    for(const auto item : errors) {
        errorText += item.errorString();
        errorText += ",";
    }

    qCWarning(logCategoryHcsDownloader) << "download SSL error on:" << reply->url() << "err:" << errorText;
}

void DownloadManager::stopAllDownloads()
{
    for(auto item : currentDownloads_) {
        item->abort();
    }

    currentDownloads_.clear();
}

