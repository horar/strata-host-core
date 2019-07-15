
#ifndef HOST_DOWNLOADGROUP_H
#define HOST_DOWNLOADGROUP_H

#include <QObject>
#include <QVector>

class DownloadManager;

class DownloadGroup  : public QObject
{
    Q_OBJECT

public:
    DownloadGroup(uint64_t uiGroupId, DownloadManager* downloadMgr, QObject* parent = nullptr);
    ~DownloadGroup() = default;

    /**
     * returns GroupId
     */
    uint64_t getGroupId() const { return groupId_; }

    /**
     * sets base folder for downloading
     * @param baseFolder
     */
    void setBaseFolder(const QString& baseFolder);

    /**
     * Starts downloading files from given list with given prefix
     * @param files
     * @param prefix
     */
    void downloadFiles(const QStringList& files, const QString& prefix);

    /**
     * checks if given filename is present in this group
     * @param filename
     * @return returns true when file is present, otherwise false
     */
    bool isFilenameInList(const QString& filename) const;

    /**
     * Returns URL for given filename
     * @param filename
     * @param urlResult
     * @return
     */
    bool getUrlForFilename(const QString& filename, QString& urlResult);

    /**
     * Callback when file is downloaded, with or without error
     * @param filename
     * @param withError
     */
    void onDownloadFinished(const QString& filename, bool withError);

    /**
     * returns true when all in the group is downloaded, otherwise false
     */
    bool isAllDownloaded();

    /**
     * Stops all downloads
     */
    void stopDownload();

private:
    enum class EItemState {
        eUnknown = 0,
        ePending,
        eDone,        //eg. downloaded
        eError,
        eStopped
    };

    struct ItemState {
        QString url;
        QString filename;
        EItemState state;
    };

    /**
     * Creates folder when needed for given relative filename
     * @param relativeFilename
     * @return returns true when succeeded otherwise false
     */
    bool createFolderWhenNeeded(const QString& relativeFilename);

    /**
     * Creating full filename for given item with given prefix
     * @param item
     * @param prefix
     * @return returns full filename
     */
    QString createFilenameFromItem(const QString& item, const QString& prefix);

    /**
     * Finds the item for given filename
     * @param filename
     * @return returns pointer to the item or nullptr when not found
     */
    ItemState* findItemByFilename(const QString& filename);

private:
    uint64_t groupId_{0};
    DownloadManager* downloadManager_;
    QVector<ItemState> downloadList_;

    QString baseFolder_;
};


#endif //HOST_DOWNLOADGROUP_H
