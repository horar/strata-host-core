
#include "StorageManager.h"
#include "DownloadManager.h"
#include "DownloadGroup.h"
#include "PlatformDocument.h"
#include "Dispatcher.h"
#include "Database.h"

#include "logging/LoggingQtCategories.h"

#include <QStandardPaths>
#include <QFile>
#include <QDir>
#include <QCryptographicHash>

#include <rapidjson/stringbuffer.h>
#include <rapidjson/writer.h>

static const std::string g_document_views("views");
static const std::string g_platform_selector("platform_selector");


StorageManager::StorageManager(HCS_Dispatcher* dispatcher, QObject* parent) : QObject(parent), dispatcher_(dispatcher)
{
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
    if (downloader_) {
        return;
    }

    baseFolder_ = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    Q_ASSERT(baseFolder_.isEmpty() == false);

    if (baseUrl_.isEmpty()) {
        qCDebug(logCategoryHcsStorage) << "Base URL is empty.";
        return;
    }

    downloader_.reset( new DownloadManager );
    downloader_->setBaseUrl(baseUrl_);

    QObject::connect(this, &StorageManager::downloadContentFiles, this, &StorageManager::onDownloadContentFiles, Qt::QueuedConnection);
    QObject::connect(this, &StorageManager::downloadUserFiles, this, &StorageManager::onDownloadUserFiles, Qt::QueuedConnection);
    QObject::connect(downloader_.get(), &DownloadManager::downloadFinished, this, &StorageManager::onDownloadFinished);
    QObject::connect(downloader_.get(), &DownloadManager::downloadFinishedError, this, &StorageManager::onDownloadFinishedError);

    QObject::connect(this, &StorageManager::cancelDownloadContentFiles, this, &StorageManager::onCancelDownloadContentFiles, Qt::QueuedConnection);
}

bool StorageManager::isInitialized() const
{
    Q_ASSERT(!downloader_.isNull());
    return (downloader_.isNull() == false);
}

bool StorageManager::requestPlatformDoc(const std::string& classId, const std::string& clientId, const StorageManager::RequestGroupType& group_type)
{
    if (isInitialized() == false) {
        return false;
    }

    QScopedPointer<RequestItem> newRequest(new RequestItem);
    newRequest->clientId = clientId;
    newRequest->classId  = classId;
    newRequest->uiDownloadGroupId = 0;
    newRequest->filesList.clear();

    StorageItem newItem;
    newItem.classId = classId;
    newItem.revisionId = std::string(); //not used yet..
    newItem.platformDocument = nullptr;

    PlatformDocument* platDoc = fetchPlatformDoc(classId);

    if(platDoc == nullptr){
        qCInfo(logCategoryHcsStorage) << "Failed to fetch a document with id:" << classId.c_str();
        return false;
    }

    newItem.platformDocument = platDoc;

    QString prefix("documents/");

    // Logic to download documents views only
    if(group_type == StorageManager::RequestGroupType::eContentViews){
        prefix += QString::fromStdString(g_document_views);

        QStringList downloadList;

        if (!fillDownloadList(newItem, g_document_views, prefix, downloadList)) {
            return false;
        }

        if (!downloadList.empty()) {

            idGenerator_++;
            uint64_t groupId = idGenerator_.loadAcquire();

            emit downloadContentFiles(downloadList, prefix, groupId);

            newRequest->uiDownloadGroupId = groupId;
            clientsRequests_.insert({clientId, newRequest.take() });

            QString qtClientId = QByteArray::fromRawData(clientId.data(), clientId.size() ).toHex();
            qCInfo(logCategoryHcsStorage) << "Download groupId:" << groupId << "for or client:" << qtClientId;
        }
        else {

            fillRequestFilesList(newItem.platformDocument, g_document_views, prefix, newRequest.get());

            createAndSendResponse(newRequest.get(), newItem.platformDocument);
        }

    }
    else if(group_type == StorageManager::RequestGroupType::ePlatformSelectorImage){
        prefix += QString::fromStdString(g_platform_selector);

        QStringList downloadList;

        if (!fillDownloadList(newItem, g_platform_selector, prefix, downloadList)) {
            return false;
        }

        if (!downloadList.empty()) {
            idGenerator_++;
            uint64_t groupId = idGenerator_.loadAcquire();

            emit downloadContentFiles(downloadList, prefix, groupId);

            newRequest->uiDownloadGroupId = groupId;
            clientsRequests_.insert({clientId, newRequest.take() });

            QString qtClientId = QByteArray::fromRawData(clientId.data(), clientId.size() ).toHex();
            qCInfo(logCategoryHcsStorage) << "Download groupId:" << groupId << "for or client:" << qtClientId;
        }
    }

    return true;
}

bool StorageManager::requestPlatformList(const std::string& classId, const std::string& clientId)
{
    if (isInitialized() == false) {
        return false;
    }
    QScopedPointer<RequestItem> newRequest(new RequestItem);
    newRequest->clientId = clientId;
    newRequest->classId  = classId;
    newRequest->uiDownloadGroupId = 0;
    newRequest->filesList.clear();

    StorageItem newItem;
    newItem.classId = classId;
    newItem.revisionId = std::string(); //not used yet..
    newItem.platformDocument = nullptr;
    qCInfo(logCategoryHcsStorage) << "requestPlatformList";

    std::string platform_list_body;
    if (db_->getDocument(classId, platform_list_body) == false) {
        qCInfo(logCategoryHcsStorage) << "[Platform list document not found.]";
        return false;
    }

    QString str = QString::fromUtf8(platform_list_body.c_str());
    auto* response = new rapidjson::Document();
    response->SetObject();
    rapidjson::Document::AllocatorType& allocator = response->GetAllocator();
    rapidjson::Document class_doc;

    if (class_doc.Parse(platform_list_body.c_str()).HasParseError()) {
        return false;
    }
    assert(class_doc.IsObject());
    if(class_doc.HasMember("platform_list") == false){
        return false;
    }
    rapidjson::Value list_json_value;
    list_json_value.SetObject();

    rapidjson::Value list_array = class_doc["platform_list"].GetArray();

    for (auto& platform : list_array.GetArray()){
        qCInfo(logCategoryHcsStorage) << "class id:" << platform["class_id"].GetString();
        std::string class_id = platform["class_id"].GetString();
        if(false == requestPlatformDoc(class_id, clientId, StorageManager::RequestGroupType::ePlatformSelectorImage)){
            qCWarning(logCategoryHcsStorage) << "Failed to request platform document with class id:" << class_id.c_str();
        }
    }

    std::lock_guard<std::mutex> lock(documentsMutex_);
    std::string path_prefix = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation).toStdString();
    path_prefix.append("/documents/platform_selector/");

    for(auto &item: list_array.GetArray()){

        if(item.HasMember("class_id") ){
            std::string class_id = item["class_id"].GetString();
            std::vector<std::string> image_list;
            std::string img_full_path;
            auto it = documentsMap_.find(class_id);
            if(it != documentsMap_.end()){
                PlatformDocument *platform_document = it->second;
                if(nullptr == platform_document){
                    continue;
                }

                platform_document->getDocumentFilesList(g_platform_selector, image_list);
                if(image_list.size()){
                    img_full_path = path_prefix + image_list.front();
                }
            }
            rapidjson::Value full_path_value(img_full_path.c_str(),allocator);
            item.AddMember("image", full_path_value, class_doc.GetAllocator());
            item.AddMember("connection", "view", class_doc.GetAllocator());
        }
    }

    list_json_value.AddMember("list",list_array , allocator);
    list_json_value.AddMember("type","all_platforms",allocator);
    response->AddMember("hcs::notification",list_json_value, allocator);
    rapidjson::StringBuffer strbuf;
    rapidjson::Writer<rapidjson::StringBuffer> writer(strbuf);
    response->Accept(writer);

    PlatformMessage msg;
    msg.msg_type = PlatformMessage::eMsgDynamicPlatformListResponse;
    msg.from_client = clientId;
    msg.message = strbuf.GetString();
    msg.msg_document = response;
    dispatcher_->addMessage(msg);

    return true;
}

void StorageManager::updatePlatformDoc(const std::string& /*classId*/)
{
    //Updates are not supported yet
}

void StorageManager::cancelDownloadPlatformDoc(const std::string& clientId)
{
    QString qtClientId = QByteArray::fromRawData(clientId.data(), clientId.size() ).toHex();
    qCInfo(logCategoryHcsStorage) << "cancelDownloadPlatformDoc for client:" << qtClientId;

    //find request by clientId
    // and cancel it

    RequestItem* request = nullptr;
    {
        QMutexLocker locker(&requestMutex_);
        auto findIt = clientsRequests_.find(clientId);
        if (findIt == clientsRequests_.end()) {
            //request already processed...
            return;
        }
        request = findIt->second;
    }

    if (request == nullptr) {
        qCWarning(logCategoryHcsStorage) << "cancelDownloadPlatformDoc request not found!";
        return;
    }

    if (request->uiDownloadGroupId != 0) {
        emit cancelDownloadContentFiles(request->uiDownloadGroupId);
    }

    qCDebug(logCategoryHcsStorage) << "Erase request";

    {
        QMutexLocker locker(&requestMutex_);
        clientsRequests_.erase(clientId);
    }

    delete request;
}

QString StorageManager::createFilenameFromItem(const QString& item, const QString& prefix)
{
    QString tmpName = QDir(prefix).filePath( item );
    return QDir(baseFolder_).filePath(tmpName);
}

bool StorageManager::fillDownloadList(const StorageItem& storageItem, const std::string& groupName, const QString& prefix, QStringList& downloadList)
{
    std::vector<std::string> urlList;
    if (storageItem.platformDocument->getDocumentFilesList(groupName, urlList) == false) {
        qCDebug(logCategoryHcsStorage) << "Platform document:" << QString::fromStdString(storageItem.classId) << "group:" << QString::fromStdString(groupName) << "not found!";
        return false;
    }

    downloadList.reserve( urlList.size() );
    for(const auto& item : urlList) {

        PlatformDocument::nameValueMap element = storageItem.platformDocument->findElementByFile(item, groupName);
        Q_ASSERT(!element.empty());

        QString filename = createFilenameFromItem( QString::fromStdString( item ), prefix );

        bool doDownload = false;

        if (!QFile::exists(filename)) {
            doDownload = true;
        }
        else {

            QString checksum = QString::fromStdString( element["md5"] );
            if (checkFileChecksum(filename, checksum) == false) {
                doDownload = true;
            }
        }

        if (doDownload) {

            qCInfo(logCategoryHcsStorage) << "Download:" << QString::fromStdString(item);

            downloadList.push_back(QString::fromStdString(item));
        }
    }
    return true;
}

bool StorageManager::fillRequestFilesList(PlatformDocument* platformDoc, const std::string& groupName, const QString& prefix, RequestItem* request)
{
    std::vector<std::string> urlList;
    if (platformDoc->getDocumentFilesList(groupName, urlList) == false) {
        qCDebug(logCategoryHcsStorage) << "Platform document:" << QString::fromStdString(platformDoc->getClassId()) << "group:" << QString::fromStdString(groupName) << "not found!";
        return false;
    }

    for(const auto& item : urlList) {

        PlatformDocument::nameValueMap element = platformDoc->findElementByFile(item, groupName);
        Q_ASSERT(!element.empty());

        QString filename = createFilenameFromItem(QString::fromStdString(item), prefix);

        std::string name = element["name"];

        request->filesList.push_back(std::make_pair(filename.toStdString(), name));
    }

    return false;
}

void StorageManager::onDownloadContentFiles(const QStringList& files, const QString& prefix, uint64_t uiGroupId)
{
    Q_ASSERT(!downloader_.isNull());
    if (downloader_.isNull()) {
        return;
    }

    //  create Download group...
    DownloadGroup* newGroup = new DownloadGroup(uiGroupId, downloader_.get());
    newGroup->setBaseFolder(baseFolder_);
    newGroup->downloadFiles(files, prefix);

    std::lock_guard<std::mutex> lock(downloadGroupsMutex_);
    downloadGroups_.insert( { uiGroupId, newGroup} );
}

void StorageManager::onDownloadUserFiles(const QStringList& files, const QString& save_path)
{
    Q_ASSERT(!downloader_.isNull());
    if (downloader_.isNull()) {
        return;
    }

    for(const auto& item : files) {

        //strip path from provided URL
        QFileInfo fi(item);
        QString filename = QDir(save_path).filePath(fi.fileName());

        qCDebug(logCategoryHcsStorage) << "Download:" << item << " To:" << filename;
        downloader_->download(item, filename);
    }
}

void StorageManager::onDownloadFinished(const QString& filename)
{
    fileDownloadFinished(filename, false);
}

void StorageManager::onDownloadFinishedError(const QString& filename, const QString& )
{
    fileDownloadFinished(filename, true);
}

void StorageManager::fileDownloadFinished(const QString& filename, bool withError)
{
    DownloadGroup* group = findDownloadGroup(filename);
    if (group == nullptr) {
        qCInfo(logCategoryHcsStorage) << "downloadFinished, group not found! " << filename;

        if (withError) {
            QFile::remove(filename);
        }
        return;
    }
    group->onDownloadFinished(filename, withError);

    //Find request by group id
    uint64_t groupId = group->getGroupId();
    RequestItem* request = nullptr;
    {
        QMutexLocker lock(&requestMutex_);

        for(const auto& item : clientsRequests_) {
            if (item.second->uiDownloadGroupId == groupId) {
                request = item.second;
                break;
            }
        }
    }
    if (request == nullptr) {
        qCInfo(logCategoryHcsStorage) << "File download finished on:" << filename << "but request not found.";

        if (withError) {
            QFile::remove(filename);
        }
        return;
    }

    PlatformDocument* platDoc = findPlatformDoc(request->classId);
    Q_ASSERT(platDoc);

    QString fileURL;
    group->getUrlForFilename(filename, fileURL);
    PlatformDocument::nameValueMap element;

    element = platDoc->findElementByFile(fileURL.toStdString(), g_document_views);
    if(element.empty()){
        element = platDoc->findElementByFile(fileURL.toStdString(), g_platform_selector);
    }
    Q_ASSERT( !element.empty() );

    qCDebug(logCategoryHcsStorage) << "file" << QString::fromStdString( element["file"] );

    if (withError == false) {

        bool checksumOK = true;
        auto findIt = element.find("md5");
        if (findIt != element.end()) {
            checksumOK = checkFileChecksum(filename, QString::fromStdString(findIt->second) );
        }

        if (!checksumOK) {
            qCInfo(logCategoryHcsStorage) << "Checksum error on file:" << filename;
        }

        //TODO: Determine what to do when checksum is wrong..

    } else {
        // qCWarning(logCategoryHcsStorage) << "File download error detected";
    }

    if (group->isAllDownloaded()) {
        qCDebug(logCategoryHcsStorage) << "Group download completed";

        std::string category;
        if(request->classId == "platform_list") {
            category = g_platform_selector;
        }
        else {
            category = g_document_views;
        }

        if (group->downloadFailed()) {
            // send error response if any downloads failed
            auto* response = new rapidjson::Document();
            response->SetObject();
            rapidjson::Document::AllocatorType& allocator = response->GetAllocator();

            response->AddMember("error", "Downloads failed - timeout or unable to connect", allocator);
            response->AddMember("class_id", rapidjson::Value(request->classId.c_str(), allocator), allocator);

            qCWarning(logCategoryHcsStorage) << "ClassId:" << QString::fromStdString(request->classId) << " downloads failed. Send response.";

            PlatformMessage msg;
            msg.msg_type = PlatformMessage::eMsgStorageResponse;
            msg.from_client = request->clientId;
            msg.message = std::string();
            msg.msg_document = response;
            dispatcher_->addMessage(msg);
        } else {
            QString prefix("documents/");
            prefix += QString::fromStdString(g_document_views);

            fillRequestFilesList(platDoc, category, prefix, request);

            createAndSendResponse(request, platDoc);
        }
    }
}

void StorageManager::onCancelDownloadContentFiles(uint64_t uiGroupId)
{
    DownloadGroup* group = nullptr;
    {
        std::lock_guard<std::mutex> lock(downloadGroupsMutex_);
        auto findIt = downloadGroups_.find(uiGroupId);
        if (findIt != downloadGroups_.end()) {
            group = findIt->second;
        }
    }

    if (group == nullptr) {
        qCDebug(logCategoryHcsStorage) << "Cancel download group:" << uiGroupId << "not found!";
        return;
    }

    qCInfo(logCategoryHcsStorage) << "Stop download group:" << uiGroupId;

    group->stopDownload();

    qCInfo(logCategoryHcsStorage) << "Erase download group:" << uiGroupId;
    {
        std::lock_guard<std::mutex> lock(downloadGroupsMutex_);
        downloadGroups_.erase(uiGroupId);

        delete group;
    }
}

void StorageManager::createAndSendResponse(RequestItem* requestItem, PlatformDocument* platformDoc)
{
    Q_ASSERT(requestItem);

    auto* response = new rapidjson::Document();

    response->SetObject();
    rapidjson::Document::AllocatorType& allocator = response->GetAllocator();

    rapidjson::Value views_array(rapidjson::kArrayType);
    for(const auto& item : requestItem->filesList) {
        const std::string& filename = item.first;
        const std::string& name     = item.second;

        rapidjson::Value array_object;
        array_object.SetObject();
        array_object.AddMember("uri", rapidjson::Value(filename.c_str(),allocator), allocator);
        array_object.AddMember("name", rapidjson::Value(name.c_str(),allocator), allocator);

        views_array.PushBack(array_object, allocator);
    }
    response->AddMember("list", views_array, allocator);

    rapidjson::Value download_array(rapidjson::kArrayType);

    Q_ASSERT(platformDoc);

    PlatformDocument::stringVector downloadList;
    if (platformDoc->getDocumentFilesList("downloads", downloadList)) {

        for(const auto& file_item : downloadList) {
            rapidjson::Value array_object;
            array_object.SetObject();
            array_object.AddMember("file", rapidjson::Value(file_item.c_str(),allocator), allocator);

            download_array.PushBack(array_object, allocator);
        }
    }
    response->AddMember("donwloads", download_array, allocator);

    response->AddMember("class_id", rapidjson::Value(requestItem->classId.c_str(), allocator), allocator);

    qCInfo(logCategoryHcsStorage) << "ClassId:" << QString::fromStdString(requestItem->classId) << " all downloaded. Send response.";

    PlatformMessage msg;
    msg.msg_type = PlatformMessage::eMsgStorageResponse;
    msg.from_client = requestItem->clientId;
    msg.message = std::string();
    msg.msg_document = response;
    dispatcher_->addMessage(msg);
}

PlatformDocument* StorageManager::findPlatformDoc(const std::string& classId)
{
    std::lock_guard<std::mutex> lock(documentsMutex_);
    auto findIt = documentsMap_.find(classId);
    if (findIt != documentsMap_.end()) {
        return findIt->second;
    }
    return nullptr;
}

PlatformDocument* StorageManager::fetchPlatformDoc(const std::string& classId)
{

    PlatformDocument* platDoc = findPlatformDoc(classId);
    if (platDoc == nullptr) {

        std::string document;
        if (db_->getDocument(classId, document) == false) {
            qCInfo(logCategoryHcsStorage) << "Platform document not found.";
            return nullptr;
        }

        platDoc = new PlatformDocument(classId, std::string());

        if (platDoc->parseDocument(document) == false) {

            qCInfo(logCategoryHcsStorage) << "Parse platform document failed!";

            delete platDoc;
            return nullptr;
        }

        //TODO: add revision to code..
        {
            std::lock_guard<std::mutex> lock(documentsMutex_);
            documentsMap_.insert( {classId, platDoc} );
        }

    }

    return platDoc;
}

bool StorageManager::checkFileChecksum(const QString& filename, const QString& checksum)
{
    QFile file(filename);
    if (!file.open(QIODevice::ReadOnly)) {
        qCWarning(logCategoryHcsStorage) << "Unable to open file:" << filename;
        return false;
    }

    QCryptographicHash hash(QCryptographicHash::Md5);
    hash.addData( &file );

    QByteArray result = hash.result();
    return (checksum == result.toHex());
}

void StorageManager::requestDownloadFiles(const std::vector<std::string>& files, const std::string& save_path)
{
    qCDebug(logCategoryHcsStorage) << "Download files to:" << QString::fromUtf8(save_path.c_str(), save_path.size() );

    QStringList qtFiles;
    for(const auto& item : files) {
        qtFiles.push_back(QString::fromStdString(item));
    }

    QString path = QString::fromUtf8(save_path.c_str(), save_path.size() );

    emit downloadUserFiles(qtFiles, path);
}

DownloadGroup* StorageManager::findDownloadGroup(const QString& filename)
{
    std::map<uint64_t, DownloadGroup*>::iterator it;
    for(it = downloadGroups_.begin(); it != downloadGroups_.end(); ++it) {
        if (it->second->isFilenameInList(filename)) {
            return it->second;
        }
    }
    return nullptr;
}
