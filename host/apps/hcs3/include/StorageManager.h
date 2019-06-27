
#ifndef HOST_HCS_STORAGEMANAGER_H__
#define HOST_HCS_STORAGEMANAGER_H__

#include <QObject>
#include <QStringList>
#include <QScopedPointer>
#include <QMap>
#include <QAtomicInteger>

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
    void resetPlatformDoc(const std::string& clientId);

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
    void downloadFiles(QStringList files, QString prefix, uint64_t uiGroupId);
    void downloadFiles2(QStringList files, QString save_path);

private slots:
    void onDownloadFiles(const QStringList& files, const QString& prefix, uint64_t uiGroupId);
    void onDownloadFiles2(const QStringList& files, const QString& save_path);

    void onDownloadFinished(const QString& filename);
    void onDownloadFinishedError(const QString& filename, const QString& error);

private:

/*    enum class EItemState {
        eUnknown = 0,
        ePending,
        eDone,        //eg. downloaded + checked
        eError
    }; */

/*
    struct ItemState {
        QString url;
        QString filename;
        QString checksum;
        EItemState state;
    };
*/

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



    void createAndSendResponse(RequestItem* requestItem, PlatformDocument* platformDoc);

//    QMultiMap<uint64_t, ItemState>::iterator findItemByUrl(const QString& url);

    static bool checkFileChecksum(const QString& filename, const QString& checksum);

    QString createFilenameFromItem(const QString& item, const QString& prefix);

    PlatformDocument* findPlatformDoc(const std::string& classId);

    DownloadGroup* findDownloadGroup(const QString& filename);

    bool fillDownloadList(const StorageItem& storageItem, const std::string& groupName, const QString& prefix, QStringList& downloadList);

    bool fillRequestFilesList(PlatformDocument* platformDoc, const std::string& groupName, const QString& prefix, RequestItem* request);

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


    //Only one PlatformDocument for now
//    PlatformDocument* plat_doc_{nullptr};
//    std::string clientId_;





};

#endif //HOST_HCS_STORAGEMANAGER_H__
