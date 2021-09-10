#ifndef DOWNLOAD_DOCUMENT_LIST_MODEL_H
#define DOWNLOAD_DOCUMENT_LIST_MODEL_H

#include <QAbstractListModel>
#include <QJsonArray>
#include <QList>
#include <QUrl>

/* forward declarations */
class CoreInterface;
struct DownloadDocumentItem;
namespace strata::strataRPC
{
class StrataClient;
}

class DownloadDocumentListModel: public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(DownloadDocumentListModel)

    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(bool downloadInProgress READ downloadInProgress NOTIFY downloadInProgressChanged)

public:
    DownloadDocumentListModel(strata::strataRPC::StrataClient *strataClient,
                              CoreInterface *coreInterface, QObject *parent = nullptr);
    virtual ~DownloadDocumentListModel() override;

    enum {
        UriRole = Qt::UserRole,
        PrettyNameRole,
        DownloadFilenameRole,
        DirnameRole,
        PreviousDirnameRole,
        HistoryStateRole,
        ProgressRole,
        StatusRole,
        ErrorStringRole,
        BytesReceivedRole,
        BytesTotalRole
    };

    enum class DownloadStatus {
        Selected,
        NotSelected,
        Waiting,
        InProgress,
        Finished,
        FinishedWithError
    };

    Q_ENUM(DownloadStatus)

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int count() const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    bool downloadInProgress();
    void populateModel(const QList<DownloadDocumentItem*> &list);
    void clear(bool emitSignals=true);

    Q_INVOKABLE void setSelected(int index, bool selected);
    Q_INVOKABLE void downloadSelectedFiles(const QUrl &saveUrl);
    Q_INVOKABLE QString getMD5();
    Q_INVOKABLE void setHistoryState(const QString &doc, const QString &state);
    Q_INVOKABLE void setAllHistoryStateToSeen();
    Q_INVOKABLE bool anyItemsUnseen();
    Q_INVOKABLE QStringList getItemsUnseen();

signals:
    void countChanged();
    void downloadInProgressChanged();

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

private slots:
    void downloadFilePathChangedHandler(const QJsonObject &payload);
    void singleDownloadProgressHandler(const QJsonObject &payload);
    void singleDownloadFinishedHandler(const QJsonObject &payload);
    void groupDownloadFinishedHandler(const QJsonObject &payload);

private:
    strata::strataRPC::StrataClient *strataClient_;
    CoreInterface *coreInterface_;

    QList<DownloadDocumentItem*>data_;
    QHash<QString, DownloadDocumentItem* > downloadingData_;
};

struct DownloadDocumentItem {

    DownloadDocumentItem(
            const QString &uri,
            const QString &prettyName,
            const QString &dirname,
            const QString &md5,
            const qint64 &filesize)
        : status(DownloadDocumentListModel::DownloadStatus::NotSelected)
    {
        this->uri = uri;
        this->prettyName = prettyName;
        this->dirname = dirname;
        this->md5 = md5;
        this->historyState = "seen";
        this->bytesTotal = filesize;
    }

    QString uri;
    QString prettyName;
    QString downloadFilename;
    QString dirname;
    QString md5;
    QString historyState;
    QString errorString;
    float progress;
    qint64 bytesTotal;
    qint64 bytesReceived;
    DownloadDocumentListModel::DownloadStatus status;
    int index;
};

Q_DECLARE_METATYPE(DownloadDocumentListModel::DownloadStatus)

#endif //DOWNLOAD_DOCUMENT_LIST_MODEL_H
