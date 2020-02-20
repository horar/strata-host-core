#include "StorageManager.h"
#include "DownloadManager.h"
#include "PlatformDocument.h"
#include "Dispatcher.h"
#include "Database.h"

#include "logging/LoggingQtCategories.h"

#include <QStandardPaths>
#include <QFile>
#include <QDir>
#include <QCryptographicHash>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonValue>
#include <QJsonObject>


static const std::string g_document_views("views");
static const std::string g_platform_selector("platform_selector");

StorageManager::StorageManager(QObject* parent)
    : QObject(parent)
{
}

StorageManager::~StorageManager()
{
    qDeleteAll(documents_);
    documents_.clear();
}

void StorageManager::setDatabase(Database* db)
{
    db_ = db;
}

void StorageManager::setBaseUrl(const QString& url)
{
    baseUrl_ = url;
    init();
}

void StorageManager::init()
{
    if (downloadManager_) {
        return;
    }

    baseFolder_ = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    Q_ASSERT(baseFolder_.isEmpty() == false);

    if (baseUrl_.isEmpty()) {
        qCWarning(logCategoryHcsStorage) << "Base URL is empty.";
        return;
    }

    downloadManager_.reset(new DownloadManager);
    downloadManager_->setBaseUrl(baseUrl_);

    connect(downloadManager_.get(), &DownloadManager::filePathChanged, this, &StorageManager::filePathChangedHandler);
    connect(downloadManager_.get(), &DownloadManager::singleDownloadProgress, this, &StorageManager::singleDownloadProgressHandler);
    connect(downloadManager_.get(), &DownloadManager::singleDownloadFinished , this, &StorageManager::singleDownloadFinishedHandler);

    connect(downloadManager_.get(), &DownloadManager::groupDownloadProgress, this, &StorageManager::groupDownloadProgressHandler);
    connect(downloadManager_.get(), &DownloadManager::groupDownloadFinished, this, &StorageManager::groupDownloadFinishedHandler);
}

bool StorageManager::isInitialized() const
{
    return downloadManager_.isNull() == false;
}

QString StorageManager::createFilePathFromItem(const QString& item, const QString& prefix)
{
    QString tmpName = QDir(prefix).filePath( item );
    return QDir(baseFolder_).filePath(tmpName);
}

void StorageManager::filePathChangedHandler(QString groupId, QString originalFilePath, QString effectiveFilePath)
{
    DownloadRequest *request = downloadRequests_.value(groupId, nullptr);
    if (request == nullptr) {
        return;
    }

    emit downloadFilePathChanged(request->clientId, originalFilePath, effectiveFilePath);
}

void StorageManager::singleDownloadProgressHandler(const QString &groupId, const QString &filePath, const qint64 &bytesReceived, const qint64 &bytesTotal)
{
    DownloadRequest *request = downloadRequests_.value(groupId, nullptr);
    if (request == nullptr) {
        return;
    }

    emit singleDownloadProgress(request->clientId, filePath, bytesReceived, bytesTotal);
}

void StorageManager::singleDownloadFinishedHandler(const QString &groupId, const QString &filePath, const QString &error)
{
    DownloadRequest *request = downloadRequests_.value(groupId, nullptr);
    if (request == nullptr) {
        return;
    }

    emit singleDownloadFinished(request->clientId, filePath, error);
}

void StorageManager::groupDownloadProgressHandler(const QString &groupId, int filesCompleted, int filesTotal)
{
    qDebug() << groupId << filesCompleted << filesTotal;
}

void StorageManager::groupDownloadFinishedHandler(const QString &groupId, const QString &errorString)
{
    DownloadRequest *request = downloadRequests_.value(groupId, nullptr);
    if (request == nullptr) {
        return;
    }

    if (request->type == RequestType::PlatformList) {
        //do nothing
    } else if (request->type == RequestType::PlatformDocuments) {
        handlePlatformDocumentsResponse(request, errorString);
    } else if (request->type == RequestType::FileDownload) {
        //do nothing
    } else {
        qCWarning(logCategoryHcsStorage) << "unknown request type";
    }

    downloadRequests_.remove(groupId);
}

void StorageManager::handlePlatformListResponse(const QByteArray &clientId, const QJsonArray &platformList)
{
    emit platformListResponseRequested(clientId, platformList);
}

void StorageManager::handlePlatformDocumentsResponse(StorageManager::DownloadRequest *requestItem, const QString &errorString)
{
    QJsonArray documentList;
    QString  finalErrorString = errorString;

    PlatformDocument *platDoc = fetchPlatformDoc(requestItem->classId);

    if (platDoc == nullptr) {
        finalErrorString = "Could not handle request as classId could not be found anymore" + requestItem->classId;
    } else if (finalErrorString.isEmpty()) {
        //add views
        QList<PlatformFileItem> viewList = platDoc->getViewList();
        QList<DownloadManager::DownloadResponseItem> downloadedFilesList = downloadManager_->getResponseList(requestItem->groupId);

        for (const auto &item : viewList) {
            QJsonObject object;
            object.insert("category", "view");
            object.insert("name", item.name);
            object.insert("prettyname", item.prettyName);

            //lets find filePath
            for (const auto &response : downloadedFilesList) {
                if (response.originalFilePath.endsWith(item.partialUri)) {
                    object.insert("uri", response.originalFilePath);
                    break;
                }
            }

            documentList.append(object);
        }

        //add downloadable documents
        QList<PlatformFileItem> downloadList = platDoc->getDownloadList();
        for (const auto &item : downloadList) {
            QJsonObject object;
            object.insert("category", "download");
            object.insert("name", item.name);
            object.insert("uri", item.partialUri);
            object.insert("filesize", item.filesize);
            object.insert("prettyname", item.prettyName);

            documentList.append(object);
        }
    }

    emit platformDocumentsResponseRequested(requestItem->clientId, documentList, finalErrorString);
}

PlatformDocument* StorageManager::fetchPlatformDoc(const QString &classId)
{
    PlatformDocument* platDoc = documents_.value(classId, nullptr);
    if (platDoc == nullptr) {
        std::string document;
        if (db_->getDocument(classId.toStdString(), document) == false) {
            qCWarning(logCategoryHcsStorage) << "Platform document not found.";
            return nullptr;
        }

        platDoc = new PlatformDocument(classId);

        if (platDoc->parseDocument(QString::fromStdString(document)) == false) {
            qCWarning(logCategoryHcsStorage) << "Parse platform document failed!";

            delete platDoc;
            return nullptr;
        }

        //cache
        documents_.insert(classId, platDoc);
    }

    return platDoc;
}

void StorageManager::requestPlatformList(const QByteArray &clientId)
{
    if (isInitialized() == false) {
        qCWarning(logCategoryHcsStorage) << "StorageManager is not initialized";
        handlePlatformListResponse(clientId, QJsonArray());
        return;
    }

    std::string platform_list_body;
    if (db_->getDocument("platform_list", platform_list_body) == false) {
        qCWarning(logCategoryHcsStorage) << "platform_list document not found";
        handlePlatformListResponse(clientId, QJsonArray());
        return;
    }

    QJsonParseError parseError;
    QJsonDocument jsonDoc = QJsonDocument::fromJson(platform_list_body.c_str(), &parseError);
    if (parseError.error != QJsonParseError::NoError ) {
        qCWarning(logCategoryHcsStorage) << "Parse error" << parseError.errorString();
        handlePlatformListResponse(clientId, QJsonArray());
        return;
    }

    QJsonArray jsonPlatformList = jsonDoc.object().value("platform_list").toArray();
    if (jsonPlatformList.isEmpty()) {
        qCWarning(logCategoryHcsStorage) << "platform_list key is missing";
        handlePlatformListResponse(clientId, QJsonArray());
        return;
    }

    QJsonArray jsonPlatformListResponse;
    QList<DownloadManager::DownloadRequestItem> downloadList;

    QString pathPrefix = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    pathPrefix.append("/documents/platform_selector/");

    for (const QJsonValue &value : jsonPlatformList) {
        QString classId = value.toObject().value("class_id").toString();
        if (classId.isEmpty()) {
            qCWarning(logCategoryHcsStorage) << "class_id key is missing";
            continue;
        }

        PlatformDocument *platDoc = fetchPlatformDoc(classId);
        if (platDoc == nullptr) {
            qCWarning(logCategoryHcsStorage) << "Failed to fetch platform data with classId" << classId;
            continue;
        }

        QString imageFile = platDoc->platformSelector().partialUri;
        QString filePath = createFilePathFromItem(platDoc->platformSelector().partialUri, pathPrefix);

        DownloadManager::DownloadRequestItem item;
        item.partialUrl = platDoc->platformSelector().partialUri;
        item.filePath = filePath;
        item.md5 = platDoc->platformSelector().md5;
        downloadList << item;

        QJsonObject jsonPlatform(value.toObject());
        jsonPlatform.insert("image", pathPrefix + platDoc->platformSelector().partialUri);
        jsonPlatform.insert("connection", "view");

        jsonPlatformListResponse.append(jsonPlatform);
    }

    DownloadManager::Settings settings;
    settings.keepOriginalName = true;
    settings.oneFailsAllFail = false;

    downloadManager_->download(downloadList, settings);

    handlePlatformListResponse(clientId, jsonPlatformListResponse);
}

void StorageManager::requestPlatformDocuments(
        const QByteArray &clientId,
        const QString &classId)
{
    if (isInitialized() == false) {
        return;
    }

    PlatformDocument* platDoc = fetchPlatformDoc(classId);

    if (platDoc == nullptr){
        platformDocumentsResponseRequested(clientId, QJsonArray(), "Failed to fetch platform data");
        qCWarning(logCategoryHcsStorage) << "Failed to fetch platform data with id:" << classId;
        return;
    }

    QString pathPrefix("documents/");
    pathPrefix += QString::fromStdString(g_document_views);

    QList<PlatformFileItem> viewList = platDoc->getViewList();

    QList<DownloadManager::DownloadRequestItem> downloadList;

    for (const PlatformFileItem &fileItem : viewList) {
        QString filePath = createFilePathFromItem(fileItem.partialUri, pathPrefix);

        DownloadManager::DownloadRequestItem item;
        item.partialUrl = fileItem.partialUri;
        item.filePath = filePath;
        item.md5 = fileItem.md5;
        downloadList << item;
    }

    DownloadRequest *request = new DownloadRequest();
    request->clientId = clientId;
    request->classId = classId;
    request->type = RequestType::PlatformDocuments;

    DownloadManager::Settings settings;
    settings.keepOriginalName = true;

    request->groupId = downloadManager_->download(downloadList, settings);

    downloadRequests_.insert(request->groupId, request);
}

void StorageManager::requestDownloadPlatformFiles(
        const QByteArray &clientId,
        const QStringList &partialUriList,
        const QString &destinationDir)
{
    if (partialUriList.isEmpty()) {
        qInfo(logCategoryHcsStorage()) << "nothing to download";
        return;
    }

    //suplement info from db
    QStringList splitPath = partialUriList.first().split("/");
    if (splitPath.isEmpty()) {
        qCWarning(logCategoryHcsStorage) << "Failed to resolve classId from request";
        return;
    }

    QString classId = splitPath.first();
    PlatformDocument *platDoc = fetchPlatformDoc(classId);
    if (platDoc == nullptr) {
        qCWarning(logCategoryHcsStorage) << "Failed to fetch platform data with classId" << classId;
        return;
    }

    QList<DownloadManager::DownloadRequestItem> downloadList;
    QDir dir(destinationDir);
    QList<PlatformFileItem> downloadableFileList = platDoc->getDownloadList();
    for (const auto &fileItem : downloadableFileList) {
        if (partialUriList.indexOf(fileItem.partialUri) < 0) {
            continue;
        }

        DownloadManager::DownloadRequestItem item;
        item.partialUrl = fileItem.partialUri;
        item.filePath = dir.filePath(fileItem.prettyName);
        item.md5 = fileItem.md5;

        downloadList << item;
    }

    DownloadRequest *request = new DownloadRequest();
    request->clientId = clientId;
    request->type = RequestType::FileDownload;

    DownloadManager::Settings settings;
    settings.keepOriginalName = false;
    settings.oneFailsAllFail = false;
    settings.notifySingleDownloadProgress = true;
    settings.notifySingleDownloadFinished = true;

    request->groupId = downloadManager_->download(downloadList, settings);

    downloadRequests_.insert(request->groupId, request);
}

void StorageManager::requestCancelPlatformDocument(const QByteArray &clientId)
{
    QString groupId;

    for (auto &request : downloadRequests_) {
        if (clientId == request->clientId
                && request->type == RequestType::PlatformDocuments) {
            groupId = request->groupId;
            break;
        }
    }

    if (groupId.isEmpty() == false ) {
        qDebug(logCategoryHcsStorage()) << "canceling all downloads" << groupId;
        downloadRequests_.remove(groupId);

        downloadManager_->abortAll(groupId);
    }
}

void StorageManager::updatePlatformDoc(const QString& classId)
{
    qCInfo(logCategoryHcsStorage()) << classId << "not implemented yet";
}
