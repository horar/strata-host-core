
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
    ~DownloadGroup();

    uint64_t getGroupId() const { return groupId_; }

    void setBaseFolder(const QString& baseFolder);

    void downloadFiles(const QStringList& files, const QString& prefix);

    bool isFilenameInList(const QString& filename) const;
    bool getUrlForFilename(const QString& filename, QString& urlResult);

    void onDownloadFinished(const QString& filename, bool withError);

    bool isAllDownloaded();

    void stopDownload();


private:
    enum class EItemState {
        eUnknown = 0,
        ePending,
        eDone,        //eg. downloaded + checked
        eError,
        eStopped
    };

    struct ItemState {
        QString url;
        QString filename;
        EItemState state;
    };

    bool createFolderWhenNeeded(const QString& relativeFilename);

    QString createFilenameFromItem(const QString& item, const QString& prefix);

    ItemState* findItemByFilename(const QString& filename);

private:
    uint64_t groupId_{0};
    DownloadManager* downloadManager_;
    QVector<ItemState> downloadList_;

    QString baseFolder_;
};


#endif //HOST_DOWNLOADGROUP_H
