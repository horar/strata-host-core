
#ifndef HOST_HCS_STORAGEMANAGER_H__
#define HOST_HCS_STORAGEMANAGER_H__

#include <QObject>
#include <QStringList>
#include <QScopedPointer>
#include <QMap>
#include <QMutex>

class HCS_Dispatcher;

class DownloadManager;
class PlatformDocument;
class Database;

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
    void resetPlatformDoc();

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

    void onDownloadFinished(const QString& url);
    void onDownloadFinishedError(const QString& url, const QString& error);

private:

    enum class EItemState {
        eUnknown = 0,
        ePending,
        eDone,        //eg. downloaded + checked
        eError
    };

    struct ItemState {
        QString url;
        QString filename;
        QString checksum;
        EItemState state;
    };

    /**
     * Initialize the DownloadManager, sets internal variables
     */
    void init();

    bool isInitialized() const;

    /**
     * Starts downloading (when necessary) of documents for specified group
     * @param groupName
     * @return
     */
    bool checkAndDownload(const std::string &groupName);

    bool createFolderWhenNeeded(const QString& relativeFilename);

    bool isAllDoneForGroupId(uint64_t uiGroupId);

    void createAndSendResponse();

    QMultiMap<uint64_t, ItemState>::iterator findItemByUrl(const QString& url);

    static bool checkFileChecksum(const QString& filename, const QString& checksum);

    QString createFilenameFromItem(const QString& item, const QString& prefix);

private:
    QString baseUrl_;
    QString baseFolder_;

    QScopedPointer<DownloadManager> downloader_;

    QMultiMap<uint64_t, ItemState> downloadList_;

    Database* db_{nullptr};

    QMutex requestMutex_;

    //Only one PlatformDocument for now
    PlatformDocument* plat_doc_{nullptr};
    std::string clientId_;

    HCS_Dispatcher* dispatcher_{nullptr};

    std::vector<std::pair<std::string, std::string> > filesList_;
};

#endif //HOST_HCS_STORAGEMANAGER_H__
