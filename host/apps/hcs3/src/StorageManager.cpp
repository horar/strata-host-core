
#include "StorageManager.h"
#include "DownloadManager.h"
#include "PlatformDocument.h"
#include "Dispatcher.h"
#include "Database.h"

#include "logging/LoggingQtCategories.h"

#include <QStandardPaths>
#include <QFile>
#include <QCryptographicHash>

#include <rapidjson/stringbuffer.h>
#include <rapidjson/writer.h>

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
        qCDebug(logCategoryHcs) << "Base URL is empty.";
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

    {
        QMutexLocker locker(&requestMutex_);

        //Only one platform document for now
        if (plat_doc_ != nullptr) {
            qCDebug(logCategoryHcs) << "Platform Document already assigned.";
            return false;
        }
    }


    std::string document;
    if (db_->getDocument(classId, g_class_doc_root_item, document) == false) {
        qCDebug(logCategoryHcs) << "Platform document not found.";
        return false;
    }

    // get all documents from cloud
    db_->addReplChannel(classId);

    //TODO: add revision to code..

    QMutexLocker locker(&requestMutex_);

    PlatformDocument* doc = new PlatformDocument(classId, std::string());
    if (doc->parseDocument(document) == false) {
        qCWarning(logCategoryHcs) << "Parse platform document failed!";

        db_->remReplChannel(classId);

        delete doc;
        return false;
    }

    plat_doc_ = doc;
    clientId_ = clientId;

    if (checkAndDownload(g_document_views) == false) {

        db_->remReplChannel(classId);

        delete doc;
        plat_doc_ = nullptr;
        clientId_.clear();
        return false;
    }

    return true;
}

void StorageManager::updatePlatformDoc(const std::string& /*classId*/)
{
    //Updates are not supported yet
}

void StorageManager::resetPlatformDoc()
{
    QMutexLocker locker(&requestMutex_);

    if (plat_doc_ != nullptr) {

        std::string classId = plat_doc_->getClassId();
        db_->remReplChannel(classId);

        delete plat_doc_;
        plat_doc_ = nullptr;

        clientId_.clear();
    }
}

QString StorageManager::createFilenameFromItem(const QString& item, const QString& prefix)
{
    QString tmpName = QDir(prefix).filePath( item );
    return QDir(baseFolder_).filePath(tmpName);
}

bool StorageManager::checkAndDownload(const std::string& groupName)
{
    if (plat_doc_ == nullptr) {
        return false;
    }

    std::vector<std::string> urlList;
    if (plat_doc_->getDocumentFilesList(groupName, urlList) == false) {
        qCCritical(logCategoryHcs) << "Platform document:" << QString::fromStdString(plat_doc_->getClassId()) << "group:" << QString::fromStdString(groupName) << "not found!";
        return false;
    }

    QString prefix = "documents/" + QString::fromStdString(groupName);

    filesList_.clear();

    QStringList downloadList;
    downloadList.reserve( urlList.size() );
    for(const auto& item : urlList) {

        PlatformDocument::nameValueMap element = plat_doc_->findElementByFile(item, "views");
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
        else {
            std::string name = element["name"];
            filesList_.push_back(std::make_pair(filename.toStdString(), name));
        }
    }

    if (!downloadList.empty()) {
        emit downloadFiles(downloadList, prefix, 1);
    }
    else {
        createAndSendResponse();

        filesList_.clear();
    }

    return true;
}

void StorageManager::onDownloadFiles(const QStringList& files, const QString& prefix, uint64_t uiGroupId)
{
    Q_ASSERT(!downloader_.isNull());
    if (downloader_.isNull()) {
        return;
    }

    if (plat_doc_ == nullptr) {
        return;
    }

    for(const auto& item : files) {

        if (createFolderWhenNeeded( QDir(prefix).filePath(item) ) == false) {
            qCDebug(logCategoryHcs) << "createFolderWhenNeeded() failed!";
            return;
        }

        QString filename(createFilenameFromItem( item, prefix ));

        QString checksum;
        PlatformDocument::nameValueMap element = plat_doc_->findElementByFile(item.toStdString(), "views");
        if (!element.empty()) {
            checksum = QString::fromStdString( element["md5"] );
        }

        downloader_->download(item, filename);

        ItemState state;
        state.url = item;
        state.filename = filename;
        state.checksum = checksum;
        state.state = EItemState::ePending;

        downloadList_.insert(uiGroupId, state);
    }
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

        qCDebug(logCategoryHcs) << "Download:" << item << " To:" << filename;
        downloader_->download(item, filename);
    }
}

bool StorageManager::createFolderWhenNeeded(const QString& relativeFilename)
{
    QFileInfo fi(relativeFilename);

    QDir basePath(baseFolder_);
    return basePath.mkpath(fi.path());
}

void StorageManager::onDownloadFinished(const QString& url)
{
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

        qCDebug(logCategoryHcs) << "Checksum error! " << url << " " << findIt->checksum;
    }

    //check all done ??
    if (isAllDoneForGroupId(thisGroupId)) {

        QMutexLocker locker(&requestMutex_);
        createAndSendResponse();
    }
}

void StorageManager::onDownloadFinishedError(const QString& url, const QString& /*error*/)
{
    auto findIt = findItemByUrl(url);
    if (findIt == downloadList_.end()) {
        return;
    }

    findIt->state = EItemState::eError;
}

void StorageManager::createAndSendResponse()
{
    if (plat_doc_ == nullptr) {     //is PlatformDocument already released ?
        qCDebug(logCategoryHcs) << "Platform doc. empty.";
        return;
    }

    auto* response = new rapidjson::Document();

    response->SetObject();
    rapidjson::Document::AllocatorType& allocator = response->GetAllocator();

    rapidjson::Value views_array(rapidjson::kArrayType);
    for(const auto& item : filesList_) {
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

    PlatformDocument::stringVector downloadList;
    if (plat_doc_->getDocumentFilesList("downloads", downloadList)) {

        for(const auto& file_item : downloadList) {
            rapidjson::Value array_object;
            array_object.SetObject();
            array_object.AddMember("file", rapidjson::Value(file_item.c_str(),allocator), allocator);

            download_array.PushBack(array_object, allocator);
        }
        response->AddMember("donwloads", download_array, allocator);
    }

    response->AddMember("class_id", rapidjson::Value(plat_doc_->getClassId().c_str(), allocator), allocator);

    qCDebug(logCategoryHcs) << "ClassId:" << QString::fromStdString(plat_doc_->getClassId()) << " all downloaded. Send response.";

    PlatformMessage msg;
    msg.msg_type = PlatformMessage::eMsgStorageResponse;
    msg.from_client = clientId_;
    msg.message = std::string();
    msg.msg_document = response;
    dispatcher_->addMessage(msg);
}

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

bool StorageManager::isAllDoneForGroupId(uint64_t uiGroupId)
{
    int total_count = downloadList_.count(uiGroupId);

    int done_count = 0;
    for(auto it = downloadList_.begin(); it != downloadList_.end(); ++it) {
        if (it.key() != uiGroupId)
            continue;

        if (it->state == EItemState::eDone || it->state == EItemState::eError) {
            done_count++;
        }
    }

    return (done_count == total_count);
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

