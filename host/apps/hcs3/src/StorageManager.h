
#ifndef HOST_HCS_STORAGEMANAGER_H__
#define HOST_HCS_STORAGEMANAGER_H__

#include <QObject>
#include <QStringList>
#include <QScopedPointer>
#include <QMap>
#include <QAtomicInteger>
#include <QMutex>

#include <mutex>
#include <map>

class HCS_Dispatcher;

class DownloadManager;
class PlatformDocument;
class Database;
class DownloadGroup;

class StorageManager : public QObject
{
    Q_OBJECT

public:
    StorageManager(HCS_Dispatcher* dispatcher, QObject* parent = nullptr);
    ~StorageManager() = default;

    /**
     * Sets the database pointer
     * @param db
     */
    void setDatabase(Database* db);

    /**
     * Sets the base URL for downloads
     * @param url base URL
     */
    void setBaseUrl(const QString& url);

    /**
     * Reads the platform document by given ID and check/download views
     * @param classId document ID
     * @param clientId client that have requested this
     * @return returns true when succeeded otherwise false
     */
    bool requestPlatformDoc(const std::string& classId, const std::string& clientId);

    /**
     * Resets current platform document. Should be called after client deselects platform
     */
    void cancelDownloadPlatformDoc(const std::string& clientId);

    /**
     * Notification about the update of the document (from Database)
     * @param classId document ID to update
     */
    void updatePlatformDoc(const std::string& classId);

    /**
     * Request to download files to specified path
     * @param files files list to download
     * @param save_path path to save the files
     */
    void requestDownloadFiles(const std::vector<std::string>& files, const std::string& save_path);

signals:
    void downloadContentFiles(QStringList files, QString prefix, uint64_t uiGroupId);
    void downloadUserFiles(QStringList files, QString save_path);
    void cancelDownloadContentFiles(uint64_t uiGroupId);

private slots:
    void onDownloadContentFiles(const QStringList& files, const QString& prefix, uint64_t uiGroupId);
    void onDownloadUserFiles(const QStringList& files, const QString& save_path);

    void onDownloadFinished(const QString& filename);
    void onDownloadFinishedError(const QString& filename, const QString& error);

    void onCancelDownloadContentFiles(uint64_t uiGroupId);

private:

    struct StorageItem {
        std::string classId;        //what document is requested
        std::string revisionId;     //not used yet
        PlatformDocument* platformDocument;
    };

    struct RequestItem {
        std::string clientId;       //from what client is request
        std::string classId;

        uint64_t uiDownloadGroupId; //download groupId or zero for invalid
        std::vector<std::pair<std::string, std::string> > filesList;   //downloaded files
    };

    /**
     * Initialize the DownloadManager, sets internal variables
     */
    void init();


    bool isInitialized() const;

    /**
     * Finds the platform document object by given class id
     * @param classId
     * @return returns platform document object or nullptr
     */
    PlatformDocument* findPlatformDoc(const std::string& classId);

    /**
     * Finds download group by filename
     * @param filename
     * @return
     */
    DownloadGroup* findDownloadGroup(const QString& filename);

    /**
     * Creates download list from given request data
     * @param storageItem
     * @param groupName
     * @param prefix
     * @param downloadList
     * @return
     */
    bool fillDownloadList(const StorageItem& storageItem, const std::string& groupName, const QString& prefix, QStringList& downloadList);

    /**
     * Fills file list in the request object from platform document object
     * @param platformDoc
     * @param groupName
     * @param prefix
     * @param request
     * @return
     */
    bool fillRequestFilesList(PlatformDocument* platformDoc, const std::string& groupName, const QString& prefix, RequestItem* request);

    /**
     * Callback when file is downloaded, with or without error
     * @param filename
     * @param withError
     */
    void fileDownloadFinished(const QString& filename, bool withError);

    /**
     * creates and sends a response from requested platform doc.
     * @param requestItem
     * @param platformDoc
     */
    void createAndSendResponse(RequestItem* requestItem, PlatformDocument* platformDoc);

    /**
     * creates full filename from item, prefix and storage location
     * @param item
     * @param prefix
     * @return returns full filename
     */
    QString createFilenameFromItem(const QString& item, const QString& prefix);

    /**
     * checks the file checksum (in MD5)
     * @param filename
     * @param checksum
     * @return returns true when the file mattches the checksum, otherwise false
     */
    static bool checkFileChecksum(const QString& filename, const QString& checksum);

private:
    QString baseUrl_;       //base part of the URL to download
    QString baseFolder_;    //base folder for store downloaded files

    QScopedPointer<DownloadManager> downloader_;

    Database* db_{nullptr};
    HCS_Dispatcher* dispatcher_{nullptr};

    QMutex requestMutex_;
    std::map<std::string, RequestItem*> clientsRequests_;

    QAtomicInteger<uint64_t> idGenerator_;
    std::mutex downloadGroupsMutex_;
    std::map<uint64_t, DownloadGroup*> downloadGroups_;

    std::mutex documentsMutex_;
    std::map<std::string, PlatformDocument*> documentsMap_;

};

#endif //HOST_HCS_STORAGEMANAGER_H__
