/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "StorageManager.h"
#include "StorageInfo.h"
#include <DownloadManager.h>

#include "PlatformDocument.h"
#include "Database.h"

#include "SGVersionUtils.h"

#include "logging/LoggingQtCategories.h"

#include <QStandardPaths>
#include <QFile>
#include <QDir>
#include <QCryptographicHash>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonValue>
#include <QJsonObject>


using strata::DownloadManager;

StorageManager::StorageManager(strata::DownloadManager *downloadManager, QObject* parent)
    : QObject(parent), downloadManager_(downloadManager)
{
    Q_ASSERT(downloadManager_ != nullptr);
}

StorageManager::~StorageManager()
{
    qDeleteAll(documents_);
    documents_.clear();
    qDeleteAll(downloadRequests_);

    QString prefix = "documents/data_sheets";
    QDir dataSheetDir = QDir(baseFolder_).filePath(prefix);
    if (dataSheetDir.exists()) {
        // erase temporary data_sheets directory if present
        dataSheetDir.removeRecursively();
    }
}

void StorageManager::setDatabase(Database* db)
{
    db_ = db;

    connect(db_, &Database::documentUpdated, this, &StorageManager::updatePlatformDoc);
}

void StorageManager::setBaseFolder(const QString& baseFolder)
{
    baseFolder_ = baseFolder;

    StorageInfo info(nullptr, baseFolder_);
    info.calculateSize();
}

void StorageManager::setBaseUrl(const QUrl &url)
{
    if (baseUrl_.isEmpty() == false) {
        qCCritical(lcHcsStorage) << "Base url is already set";
        return;
    }

    if (url.scheme().isEmpty()) {
        qCCritical(lcHcsStorage) << "Base url does not have scheme";
    }

    baseUrl_ = url;

    connect(downloadManager_, &DownloadManager::filePathChanged, this, &StorageManager::filePathChangedHandler);
    connect(downloadManager_, &DownloadManager::singleDownloadProgress, this, &StorageManager::singleDownloadProgressHandler);
    connect(downloadManager_, &DownloadManager::singleDownloadFinished , this, &StorageManager::singleDownloadFinishedHandler);

    connect(downloadManager_, &DownloadManager::groupDownloadProgress, this, &StorageManager::groupDownloadProgressHandler);
    connect(downloadManager_, &DownloadManager::groupDownloadFinished, this, &StorageManager::groupDownloadFinishedHandler);
}

QUrl StorageManager::getBaseUrl() const
{
    return baseUrl_;
}

const FirmwareFileItem *StorageManager::findFirmware(const QString &classId, const QString &controllerClassId, const QString &version)
{
    qCDebug(lcHcsStorage) << "Searching firmware " << version << " for" << classId << "and" << controllerClassId;

    PlatformDocument *platfDoc = fetchPlatformDoc(classId);
    if (platfDoc == nullptr) {
        return nullptr;
    }

    const FirmwareFileItem* firmware = nullptr;
    QList<FirmwareFileItem> firmwareList = platfDoc->getFirmwareList();
    for (int i = 0; i < firmwareList.length(); ++i) {
        if (firmwareList.at(i).controllerClassId == controllerClassId && firmwareList.at(i).version == version) {
            firmware = &firmwareList.at(i);
            break;
        }
    }

    return firmware;
}

const FirmwareFileItem* StorageManager::findHighestFirmware(const QString &classId, const QString &controllerClassId)
{
    qCDebug(lcHcsStorage) << "Searching for highest firmware for " << classId << "and" << controllerClassId;

    PlatformDocument *platfDoc = fetchPlatformDoc(classId);
    if (platfDoc == nullptr) {
        return nullptr;
    }

    const FirmwareFileItem* firmware = nullptr;
    QList<FirmwareFileItem> firmwareList = platfDoc->getFirmwareList();
    for (int i = 0; i < firmwareList.length(); ++i) {
        if (firmwareList.at(i).controllerClassId == controllerClassId) {
            if (firmware == nullptr || SGVersionUtils::lessThan(firmware->version, firmwareList.at(i).version)) {
                firmware = &firmwareList.at(i);
            }
        }
    }

    return firmware;
}

const FirmwareFileItem* StorageManager::findHighestFirmware(const QString &classId)
{
    qCDebug(lcHcsStorage) << "Searching for highest firmware for" << classId;

    PlatformDocument *platfDoc = fetchPlatformDoc(classId);
    if (platfDoc == nullptr) {
        return nullptr;
    }

    const FirmwareFileItem* firmware = nullptr;
    QList<FirmwareFileItem> firmwareList = platfDoc->getFirmwareList();

    for (int i = 0; i < firmwareList.length(); ++i) {
        if (firmware == nullptr || SGVersionUtils::lessThan(firmware->version, firmwareList.at(i).version)) {
            firmware = &firmwareList.at(i);
        }
    }

    return firmware;
}

QString StorageManager::createFilePathFromItem(const QString& item, const QString& prefix) const
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

    if (request->type == RequestType::FileDownload) {
        emit downloadPlatformFilePathChanged(request->clientId, downloadUrls_[groupId], originalFilePath, effectiveFilePath);
    }
}

void StorageManager::singleDownloadProgressHandler(const QString &groupId, const QString &filePath, const qint64 &bytesReceived, const qint64 &bytesTotal)
{
    DownloadRequest *request = downloadRequests_.value(groupId, nullptr);
    if (request == nullptr) {
        return;
    }

    if (request->type == RequestType::FileDownload) {
        emit downloadPlatformSingleFileProgress(request->clientId, downloadUrls_[groupId], filePath, bytesReceived, bytesTotal);
    } else if (request->type == RequestType::ControlViewDownload) {
        emit downloadControlViewProgress(request->clientId, downloadControlViewUris_[groupId], filePath, bytesReceived, bytesTotal);
    }
}

void StorageManager::singleDownloadFinishedHandler(const QString &groupId, const QString &filePath, const QString &error)
{
    DownloadRequest *request = downloadRequests_.value(groupId, nullptr);
    if (request == nullptr) {
        return;
    }

    if (request->type == RequestType::FileDownload) {
        emit downloadPlatformSingleFileFinished(request->clientId, downloadUrls_[groupId], filePath, error);
    }
}

void StorageManager::groupDownloadProgressHandler(const QString &groupId, int filesCompleted, int filesTotal)
{
    DownloadRequest *request = downloadRequests_.value(groupId, nullptr);
    if (request == nullptr) {
        return;
    }

    if (request->type == RequestType::PlatformDocuments) {
        emit downloadPlatformDocumentsProgress(request->clientId, request->classId, filesCompleted, filesTotal);
    }
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
        emit downloadPlatformFilesFinished(request->clientId, errorString);
        downloadUrls_.remove(groupId);
    } else if (request->type == RequestType::ControlViewDownload) {
        QList<DownloadManager::DownloadResponseItem> responseList = downloadManager_->getResponseList(groupId);
        if (responseList.isEmpty() == false) {
            const DownloadManager::DownloadResponseItem &responseItem = responseList.first();
            emit downloadControlViewFinished(request->clientId,
                                             downloadControlViewUris_[groupId],
                                             responseItem.effectiveFilePath,
                                             responseItem.errorString);
        }
        downloadControlViewUris_.remove(groupId);
    } else {
        qCCritical(lcHcsStorage) << "unknown request type";
    }

    downloadRequests_.remove(groupId);
    delete request;
}

void StorageManager::handlePlatformListResponse(const QByteArray &clientId, const QJsonArray &platformList)
{
    emit platformListResponseRequested(clientId, platformList);
}

void StorageManager::handlePlatformDocumentsResponse(StorageManager::DownloadRequest *requestItem, const QString &errorString)
{
    QJsonArray documentList, datasheetList;
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
            object.insert("md5", item.md5);

            //lets find filePath
            for (const auto &response : downloadedFilesList) {
                if (response.originalFilePath.endsWith(item.partialUri)) {
                    object.insert("uri", response.originalFilePath);
                    break;
                }
            }

            documentList.append(object);
        }

        //add datasheet documents
        QList<PlatformDatasheetItem> datasheetDownloadList = platDoc->getDatasheetList();
        for (const auto &item : datasheetDownloadList) {
            QJsonObject object;
            object.insert("category", item.category);
            object.insert("datasheet", item.datasheet);
            object.insert("name", item.name);
            object.insert("opn", item.opn);
            object.insert("subcategory", item.subcategory);

            datasheetList.append(object);
        }

        // If the datasheetDownloadList is empty, then we download datasheet.csv
        // This is to handle older platforms that don't have the datasheets property
        bool downloadDatasheetCSV = datasheetDownloadList.isEmpty();

        //add downloadable documents
        QList<PlatformFileItem> downloadList = platDoc->getDownloadList();
        for (const auto &item : downloadList) {
            if (downloadDatasheetCSV == false && item.name == "datasheet") {
                continue;
            }

            QJsonObject object;
            object.insert("category", "download");
            object.insert("name", item.name);
            object.insert("uri", item.partialUri);
            object.insert("filesize", item.filesize);
            object.insert("prettyname", item.prettyName);
            object.insert("md5", item.md5);

            documentList.append(object);
        }
    }

    emit platformDocumentsResponseRequested(requestItem->clientId,
                                            requestItem->classId,
                                            datasheetList,
                                            documentList,
                                            finalErrorString);
}

PlatformDocument* StorageManager::fetchPlatformDoc(const QString &classId)
{
    PlatformDocument* platDoc = documents_.value(classId, nullptr);
    if (platDoc == nullptr) {
        QString dbDoc;
        if (db_->getDocument(classId, dbDoc) == false) {
            qCCritical(lcHcsStorage).noquote().nospace()
                << "Platform document not found (class ID " << classId << ").";
            return nullptr;
        }
        QByteArray document(dbDoc.toUtf8());

        platDoc = new PlatformDocument(classId);

        if (platDoc->parseDocument(document) == false) {
            qCCritical(lcHcsStorage).noquote().nospace()
                << "Parsing of platform document " << classId << " failed!";
            qCWarning(lcHcsStorage).noquote().nospace()
                << "Faulty document: '" << document << '\'';

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
    QString platform_list_body;
    if (db_->getDocument("platform_list", platform_list_body) == false) {
        qCCritical(lcHcsStorage) << "platform_list document not found";
        handlePlatformListResponse(clientId, QJsonArray());
        return;
    }

    QJsonParseError parseError;
    QJsonDocument jsonDoc = QJsonDocument::fromJson(platform_list_body.toUtf8(), &parseError);
    if (parseError.error != QJsonParseError::NoError ) {
        qCCritical(lcHcsStorage) << "Parse error" << parseError.errorString();
        handlePlatformListResponse(clientId, QJsonArray());
        return;
    }

    QJsonArray jsonPlatformList = jsonDoc.object().value("platform_list").toArray();
    if (jsonPlatformList.isEmpty()) {
        qCCritical(lcHcsStorage) << "platform_list key is missing";
        handlePlatformListResponse(clientId, QJsonArray());
        return;
    }

    QJsonArray jsonPlatformListResponse;
    QList<DownloadManager::DownloadRequestItem> downloadList;

    const QString pathPrefix{QString("%1/documents/platform_selector/").arg(baseFolder_)};

    for (const QJsonValueRef value : jsonPlatformList) {
        QString classId = value.toObject().value("class_id").toString();
        if (classId.isEmpty()) {
            qCCritical(lcHcsStorage) << "class_id key is missing";
            continue;
        }

        PlatformDocument *platDoc = fetchPlatformDoc(classId);
        if (platDoc == nullptr) {
            qCCritical(lcHcsStorage) << "Failed to fetch platform data with classId" << classId;
            continue;
        }

        QString filePath = createFilePathFromItem(platDoc->platformSelector().partialUri, pathPrefix);

        DownloadManager::DownloadRequestItem item;
        item.url = baseUrl_.resolved(platDoc->platformSelector().partialUri);
        item.filePath = filePath;
        item.md5 = platDoc->platformSelector().md5;
        downloadList << item;

        QUrl url;
        url.setScheme("file");
        url.setPath(pathPrefix + platDoc->platformSelector().partialUri);

        QJsonObject jsonPlatform(value.toObject());
        jsonPlatform.insert("image", url.toString());
        jsonPlatform.insert("first_normal_published_timestamp", platDoc->firstNormalPublishedTimestamp());

        QJsonArray parts_list;

        for (const PlatformDatasheetItem &i : platDoc->getDatasheetList()) {
            parts_list.append(i.opn);
        }

        jsonPlatform.insert("parts_list", parts_list);
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
    PlatformDocument* platDoc = fetchPlatformDoc(classId);

    if (platDoc == nullptr) {
        emit platformMetaData(clientId, classId,  QJsonArray(), QJsonArray(), "Failed to fetch platform metadata");
        emit platformDocumentsResponseRequested(clientId, classId, QJsonArray(), QJsonArray(), "Failed to fetch platform data");

        qCCritical(lcHcsStorage) << "Failed to fetch platform data with id:" << classId;
        return;
    }

    // Here we return metadata about the platform before downloading items
    QJsonArray controlViewList, firmwareList;

    //firmwares
    QList<FirmwareFileItem> firmwareItems = platDoc->getFirmwareList();
    for (const auto &item : firmwareItems) {
        QJsonObject object {
            {"uri", item.partialUri},
            {"md5", item.md5},
            {"timestamp", item.timestamp},
            {"version", item.version}
        };
        if (item.controllerClassId.isNull() == false) {
            object["controller_class_id"] = item.controllerClassId;
        }

        firmwareList.append(object);
    }

    //control views
    QList<ControlViewFileItem> controlViewItems = platDoc->getControlViewList();
    for (const auto &item : controlViewItems) {
        QString filePath = createFilePathFromItem(item.partialUri, "documents/control_views" + (classId.isEmpty() ? "" : "/" + classId));
        if (downloadManager_->verifyFileHash(filePath, item.md5) == false) {
            filePath.clear();
        }

        QJsonObject object {
            {"uri", item.partialUri},
            {"md5", item.md5},
            {"name", item.name},
            {"timestamp", item.timestamp},
            {"version", item.version},
            {"filepath", filePath}
        };

        controlViewList.append(object);
    }
    emit platformMetaData(clientId, classId, controlViewList, firmwareList, "");

    // Now continue to start the downloads for platform documents
    QString pathPrefix("documents/views");

    QList<PlatformFileItem> viewList = platDoc->getViewList();

    QList<DownloadManager::DownloadRequestItem> downloadList;

    for (const PlatformFileItem &fileItem : viewList) {
        QString filePath = createFilePathFromItem(fileItem.partialUri, pathPrefix);

        DownloadManager::DownloadRequestItem item;
        item.url = baseUrl_.resolved(fileItem.partialUri);
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
    settings.notifyGroupDownloadProgress = true;

    if (downloadList.isEmpty()) {
        qCInfo(lcHcsStorage()) << "No documents to be downloaded";
        handlePlatformDocumentsResponse(request, QString());
        return;
    }

    request->groupId = downloadManager_->download(downloadList, settings);

    downloadRequests_.insert(request->groupId, request);
}

void StorageManager::requestDownloadPlatformFiles(
        const QByteArray &clientId,
        const QStringList &partialUriList,
        const QString &destinationDir)
{
    if (partialUriList.isEmpty()) {
        qCInfo(lcHcsStorage()) << "nothing to download";
        emit downloadPlatformFilesFinished(clientId, QString());
        return;
    }

    //suplement info from db
    QStringList splitPath = partialUriList.first().split("/");
    if (splitPath.isEmpty()) {
        qCCritical(lcHcsStorage) << "Failed to resolve classId from request";
        emit downloadPlatformFilesFinished(clientId, "Failed to resolve classId from request");
        return;
    }

    QString classId = splitPath.first();
    PlatformDocument *platDoc = fetchPlatformDoc(classId);
    if (platDoc == nullptr) {
        qCCritical(lcHcsStorage) << "Failed to fetch platform data with classId" << classId;
        emit downloadPlatformFilesFinished(clientId, "Failed to fetch platform data");
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
        item.url = baseUrl_.resolved(fileItem.partialUri);
        item.filePath = dir.filePath(fileItem.prettyName);
        item.md5 = fileItem.md5;

        downloadList << item;
    }

    if (downloadList.isEmpty()) {
        qCWarning(lcHcsStorage()) << "requested files not valid";
        emit downloadPlatformFilesFinished(clientId, "requested files not valid");
        return;
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

void StorageManager::requestDownloadDatasheetFile(
        const QByteArray &clientId,
        const QString &fileUrl,
        const QString &classId)
{
    if (fileUrl.isEmpty()) {
        qCInfo(lcHcsStorage()) << "nothing to download";
        emit downloadPlatformFilesFinished(clientId, QString());
        return;
    }

    DownloadRequest *request = new DownloadRequest();
    request->clientId = clientId;
    request->classId = classId;
    request->type = RequestType::FileDownload;

    QString prefix = "documents/data_sheets";
    if (classId.isEmpty() == false) {
        prefix += "/" + classId;
    }

    DownloadManager::DownloadRequestItem downloadItem;
    downloadItem.url = fileUrl;
    downloadItem.filePath = createFilePathFromItem(downloadItem.url.fileName(), prefix);

    DownloadManager::Settings settings;
    settings.keepOriginalName = false;
    settings.oneFailsAllFail = false;
    settings.notifySingleDownloadProgress = true;
    settings.notifySingleDownloadFinished = true;

    request->groupId = downloadManager_->download({downloadItem}, settings);

    downloadRequests_.insert(request->groupId, request);

    downloadUrls_[request->groupId] = fileUrl;
}

void StorageManager::requestDownloadControlView(const QByteArray &clientId, const QString &partialUri, const QString &md5, const QString &class_id)
{
    DownloadManager::DownloadRequestItem item;
    item.url = baseUrl_.resolved(partialUri);
    QString prefix = "documents/control_views";
    if (!class_id.isEmpty()) {
        prefix += "/" + class_id;
    }
    item.filePath = createFilePathFromItem(partialUri, prefix);
    item.md5 = md5;

    QList<DownloadManager::DownloadRequestItem> downloadList({item});

    DownloadRequest *request = new DownloadRequest();
    request->clientId = clientId;
    request->type = RequestType::ControlViewDownload;

    DownloadManager::Settings settings;
    settings.notifySingleDownloadProgress = true;
    settings.keepOriginalName = true;

    request->groupId = downloadManager_->download(downloadList, settings);

    downloadRequests_.insert(request->groupId, request);

    downloadControlViewUris_[request->groupId] = partialUri;
}

void StorageManager::requestCancelAllDownloads(const QByteArray &clientId)
{
    qCInfo(lcHcsStorage).nospace().noquote() << "clientId: 0x" << clientId.toHex();

    QMutableHashIterator<QString, DownloadRequest*> iter(downloadRequests_);
    while (iter.hasNext()) {
        DownloadRequest *request = iter.next().value();
        if (clientId == request->clientId) {
            QString groupId = request->groupId;
            qCInfo(lcHcsStorage) << "aborting all downloads for groupId" << groupId;
            downloadRequests_.remove(groupId);
            downloadManager_->abortAll(groupId);
            delete request;
        }
    }
}

void StorageManager::updatePlatformDoc(const QString& classId)
{
    qCDebug(lcHcsStorage()) << classId << "not implemented yet";
}
