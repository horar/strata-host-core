
#include "StorageManager.h"
#include "DownloadManager.h"
#include "PlatformDocument.h"
#include "Dispatcher.h"
#include "Database.h"

#include <QStandardPaths>
#include <QFile>
#include <QCryptographicHash>

#include <rapidjson/stringbuffer.h>
#include <rapidjson/writer.h>
#include <include/DownloadGroup.h>

static const std::string g_class_doc_root_item("documents");
static const std::string g_document_views("views");

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
        qDebug() << "Base URL is empty.";
        return;
    }

    downloader_.reset( new DownloadManager );
    downloader_->setBaseUrl(baseUrl_);

    QObject::connect(this, &StorageManager::downloadFiles, this, &StorageManager::onDownloadFiles, Qt::QueuedConnection);
    QObject::connect(this, &StorageManager::downloadFiles2, this, &StorageManager::onDownloadFiles2, Qt::QueuedConnection);
    QObject::connect(downloader_.get(), &DownloadManager::downloadFinished, this, &StorageManager::onDownloadFinished);
    QObject::connect(downloader_.get(), &DownloadManager::downloadFinishedError, this, &StorageManager::onDownloadFinishedError);
}

bool StorageManager::isInitialized() const
{
    Q_ASSERT(!downloader_.isNull());
    return (downloader_.isNull() == false);
}

bool StorageManager::requestPlatformDoc(const std::string& classId, const std::string& clientId)
{
    if (isInitialized() == false) {
        return false;
    }

    auto findIt = clientsRequests_.find(clientId);
    if (findIt != clientsRequests_.end()) {
        //only one request from client.. for now
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

    PlatformDocument* platDoc = findPlatformDoc(classId);
    if (platDoc == nullptr) {

        std::string document;
        if (db_->getDocument(classId, g_class_doc_root_item, document) == false) {
            qDebug() << "Platform document not found.";
            return false;
        }

        platDoc = new PlatformDocument(classId, std::string());
        if (platDoc->parseDocument(document) == false) {
            qDebug() << "Parse platform document failed!";

            delete platDoc;
            return false;
        }

        // get all documents from cloud
        db_->addReplChannel(classId);

        //TODO: add revision to code..

        {
            std::lock_guard<std::mutex> lock(documentsMutex_);
            documentsMap_.insert( {classId, platDoc} );
        }
    }

    newItem.platformDocument = platDoc;


    QString prefix = "documents/" + QString::fromStdString(g_document_views);

    QStringList downloadList;
    bool ret = fillDownloadList(newItem, g_document_views, prefix, downloadList);

    if (!downloadList.empty()) {

        idGenerator_++;
        uint64_t groupId = idGenerator_.loadAcquire();

        emit downloadFiles(downloadList, prefix, groupId);

        newRequest->uiDownloadGroupId = groupId;
        clientsRequests_.insert({clientId, newRequest.take() });
    }
    else {

        fillRequestFilesList(newItem.platformDocument, g_document_views, prefix, newRequest.get());

        createAndSendResponse(newRequest.get(), newItem.platformDocument);
    }

    return true;
}

void StorageManager::updatePlatformDoc(const std::string& /*classId*/)
{
    //Updates are not supported yet
}

void StorageManager::resetPlatformDoc(const std::string& clientId)
{
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

    Q_ASSERT(request);
    db_->remReplChannel(request->classId);

    if (request->uiDownloadGroupId != 0) {

        DownloadGroup* group = nullptr;
        {
            std::lock_guard<std::mutex> lock(downloadGroupsMutex_);
            auto findIt = downloadGroups_.find(request->uiDownloadGroupId);
            if (findIt != downloadGroups_.end()) {
                group = findIt->second;
            }
        }

        if (group != nullptr) {
            group->stopDownload();

            //TODO: destroy the group...
            // and erase from list..

            std::lock_guard<std::mutex> lock(downloadGroupsMutex_);
            downloadGroups_.erase(request->uiDownloadGroupId);
        }
    }

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


//        QString checksum;
//        PlatformDocument::nameValueMap element = plat_doc_->findElementByFile(item.toStdString(), "views");
//        if (!element.empty()) {
//            checksum = QString::fromStdString( element["md5"] );
//        }

bool StorageManager::fillDownloadList(const StorageItem& storageItem, const std::string& groupName, const QString& prefix, QStringList& downloadList)
{
    std::vector<std::string> urlList;
    if (storageItem.platformDocument->getDocumentFilesList(groupName, urlList) == false) {
        qDebug() << "Platform document:" << QString::fromStdString(storageItem.classId) << "group:" << QString::fromStdString(groupName) << "not found!";
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
            downloadList.push_back(QString::fromStdString(item));
        }
    }
    return true;
}

bool StorageManager::fillRequestFilesList(PlatformDocument* platformDoc, const std::string& groupName, const QString& prefix, RequestItem* request)
{
    std::vector<std::string> urlList;
    if (platformDoc->getDocumentFilesList(groupName, urlList) == false) {
        qDebug() << "Platform document:" << QString::fromStdString(platformDoc->getClassId()) << "group:" << QString::fromStdString(groupName) << "not found!";
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

void StorageManager::onDownloadFiles(const QStringList& files, const QString& prefix, uint64_t uiGroupId)
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

void StorageManager::onDownloadFiles2(const QStringList& files, const QString& save_path)
{
    Q_ASSERT(!downloader_.isNull());
    if (downloader_.isNull()) {
        return;
    }

    for(const auto& item : files) {

        //strip class_id
        QFileInfo fi(item);

        QString filename = QDir(save_path).filePath(fi.fileName());

        qDebug() << "Download:" << item << " To:" << filename;
        downloader_->download(item, filename);
    }
}

//bool StorageManager::createFolderWhenNeeded(const QString& relativeFilename)
//{
//    QFileInfo fi(relativeFilename);
//
//    QDir basePath(baseFolder_);
//    return basePath.mkpath(fi.path());
//}

void StorageManager::onDownloadFinished(const QString& filename)
{
    DownloadGroup* group = findDownloadGroup(filename);
    if (group == nullptr) {
        //Error...
        return;
    }

    group->onDownloadFinished(filename);

    QString fileURL;
    group->getUrlForFilename(filename, fileURL);

    //Find request by group or filename...

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

    PlatformDocument* platDoc = findPlatformDoc(request->classId);
    Q_ASSERT(platDoc);

    PlatformDocument::nameValueMap element = platDoc->findElementByFile(fileURL.toStdString(), "views");
    Q_ASSERT( !element.empty() );

    bool checksumOK = true;
    auto findIt = element.find("md5");
    if (findIt != element.end()) {


//TODO:        checksumOK = checkFileChecksum(findIt->filename, findIt->checksum);
    }

//
//    if (checksumOK) {
//
//
//        std::string name = element["name"];
//        std::string filename = findIt->filename.toStdString();
//
//        filesList_.push_back(std::make_pair(filename, name));
//    }
//


/*

    PlatformDocument* platDoc = findPlatformDoc( requestItem_->classId );
*/


//
//

    if (group->isAllDownloaded()) {

        QString prefix = "documents/" + QString::fromStdString(g_document_views);

        fillRequestFilesList(platDoc, g_document_views, prefix, request);

        createAndSendResponse(request, platDoc);
    }


#if 0
    auto findIt = findItemByUrl(url);
    if (findIt == downloadList_.end()) {
        return;
    }

    uint64_t thisGroupId = findIt.key();
    findIt->state = EItemState::eDone;

    bool checksumOK = true;
    if (!findIt->checksum.isEmpty()) {
        checksumOK = checkFileChecksum(findIt->filename, findIt->checksum);
    }

    if (checksumOK) {
        if (plat_doc_ == nullptr) {
            return;
        }

        PlatformDocument::nameValueMap element = plat_doc_->findElementByFile(url.toStdString(), "views");
        Q_ASSERT( !element.empty() );

        std::string name = element["name"];
        std::string filename = findIt->filename.toStdString();

        filesList_.push_back(std::make_pair(filename, name));
    }
    else {
        findIt->state = EItemState::eError;

        qDebug() << "Checksum error! " << url << " " << findIt->checksum;
    }

    //check all done ??
    if (isAllDoneForGroupId(thisGroupId)) {

        QMutexLocker locker(&requestMutex_);
        createAndSendResponse();
    }
#endif

}

void StorageManager::onDownloadFinishedError(const QString& filename, const QString& /*error*/)
{

#if 0
    auto findIt = findItemByUrl(url);
    if (findIt == downloadList_.end()) {
        return;
    }

    findIt->state = EItemState::eError;
#endif
}

void StorageManager::createAndSendResponse(RequestItem* requestItem, PlatformDocument* platformDoc)
{
    Q_ASSERT(requestItem);

    auto* response = new rapidjson::Document();

    response->SetObject();
    rapidjson::Document::AllocatorType& allocator = response->GetAllocator();

    rapidjson::Value views_array(rapidjson::kArrayType);
    for(const auto& item : requestItem->filesList) {
        std::string filename = item.first;
        std::string name     = item.second;

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
        response->AddMember("donwloads", download_array, allocator);
    }

    response->AddMember("class_id", rapidjson::Value(requestItem->classId.c_str(), allocator), allocator);

    qDebug() << "all downloaded. Send response.";

    PlatformMessage msg;
    msg.msg_type = PlatformMessage::eMsgStorageResponse;
    msg.from_client = requestItem->clientId;
    msg.message = std::string();
    msg.msg_document = response;
    dispatcher_->addMessage(msg);
}

#if 0
QMultiMap<uint64_t, StorageManager::ItemState>::iterator StorageManager::findItemByUrl(const QString& url)
{
    QMultiMap<uint64_t, StorageManager::ItemState>::iterator findIt;
    for(findIt = downloadList_.begin(); findIt != downloadList_.end(); ++findIt) {
        if (findIt->url == url) {
            break;
        }
    }

    return findIt;
}
#endif

PlatformDocument* StorageManager::findPlatformDoc(const std::string& classId)
{
    std::lock_guard<std::mutex> lock(documentsMutex_);
    auto findIt = documentsMap_.find(classId);
    if (findIt != documentsMap_.end()) {
        return findIt->second;
    }
    return nullptr;
}

bool StorageManager::checkFileChecksum(const QString& filename, const QString& checksum)
{
    QFile file(filename);
    if (!file.open(QIODevice::ReadOnly)) {
        return false;
    }

    QCryptographicHash hash(QCryptographicHash::Md5);
    hash.addData( &file );

    QByteArray result = hash.result();
    return (checksum == result.toHex());
}

void StorageManager::requestDownloadFiles(const std::vector<std::string>& files, const std::string& save_path)
{
    QStringList qtFiles;
    for(const auto& item : files) {
        qtFiles.push_back(QString::fromStdString(item));
    }

    QString path = QString::fromUtf8(save_path.c_str(), save_path.size() );

    emit downloadFiles2(qtFiles, path);
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

