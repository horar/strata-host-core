#ifndef DOWNLOAD_MANAGER_H
#define DOWNLOAD_MANAGER_H

#include <QObject>
#include <QString>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QList>
#include <QMap>

#include <QBasicTimer>
#include <QTimerEvent>
#include <QCryptographicHash>

class DownloadManager : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(DownloadManager)

public:
    DownloadManager(QObject* parent = nullptr);
    ~DownloadManager() override;

    struct DownloadRequestItem {
        QString partialUrl;
        QString filePath;
        QString md5;
    };

    struct DownloadResponseItem {
        QString originalFilePath;
        QString effectiveFilePath;
        QString errorString;
    };

    struct Settings {
        Settings()
            : notifySingleDownloadProgress(false),
              notifySingleDownloadFinished(false),
              notifyGroupDownloadProgress(false),
              keepOriginalName(false),
              oneFailsAllFail(true)
        {
        };

        QString id;

        bool notifySingleDownloadProgress;
        bool notifySingleDownloadFinished;
        bool notifyGroupDownloadProgress;

        /* When true and filePath alredy exists, file is saved
         * under different name. */
        bool keepOriginalName;

        /* When true and one of downloaded items fails,
         * all remaining are aborted. */
        bool oneFailsAllFail;
    };

    //we still need a string error, so this is mostly useless
    enum class CustomError {
        NoError,
        OpenFileError,
        WriteToFileError,
    };

    void setBaseUrl(const QString &baseUrl);
    void setMaxDownloadCount(int maxDownloadCount);

    QString download(const QList<DownloadRequestItem> &items,
                     const Settings &settings=Settings());

    bool verifyFileChecksum(
            const QString &filePath,
            const QString &checksum,
            const QCryptographicHash::Algorithm &method=QCryptographicHash::Md5);

    QString resolveUniqueFilePath(const QString &filePath);

    QList<DownloadResponseItem> getResponseList(const QString &groupId);

    void abortAll(const QString &groupId);

signals:
    void filePathChanged(QString groupId, QString originalFilePath, QString effectiveFilePath);
    void singleDownloadProgress(QString groupId, QString filePath, qint64 bytesReceived, qint64 bytesTotal);
    void singleDownloadFinished(QString groupId, QString filePath, QString error);
    void groupDownloadProgress(QString groupId, int filesCompleted, int filesTotal);
    void groupDownloadFinished(QString groupId, QString errorString);

private slots:
    void readyReadHandler();
    void downloadProgressHandler(qint64 bytesReceived, qint64 bytesTotal);
    void finishedHandler();

private:
    enum class DownloadState {
        Pending,
        Running,
        Finished,
        FinishedWithError,
    };

    struct DownloadGroup {
        QString id;
        Settings settings;
        QString errorString;
    };

    struct DownloadItem {
        QString url;
        QString originalFilePath;
        QString effectiveFilePath;
        QString md5;
        DownloadState state;
        QString groupId;
        QString errorString;
    };

    QNetworkAccessManager *accessManager_;
    QList<QNetworkReply*> currentDownloads_;

    QString baseUrl_;
    int maxDownloadCount_ = 4;

    QList<DownloadItem> itemList_;
    QHash<QString /*url*/, DownloadItem*> itemHash_;

    QHash<QString /*groupId*/, DownloadGroup*> groupHash_;

    void startNextDownload();
    DownloadItem* findNextDownload();
    void createFolderForFile(const QString &filePath);
    QNetworkReply* postRequest(const QString &url);
    bool isHttpRedirect(QNetworkReply *reply);
    QString writeToFile(const QString &filePath, const QByteArray &buffer);

    void prepareResponse(DownloadItem *downloadItem, const QString &errorString=QString());

    void resolveGroupProgress(
            const QString &groupId,
            int &filesFailed,
            int &filesCompleted,
            int &filesTotal);


    void clearData(const QString groupId);
};

/**
 * Timed timeout trigger since QNetworkReply does not inherently timeout
 */
class ReplyTimeout : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(ReplyTimeout)

public:
    ReplyTimeout(QNetworkReply* reply, const int timeout) : QObject(reply) {
        Q_ASSERT(reply);
        milliseconds_ = timeout;
        if (reply && reply->isRunning())
             mSec_timer_.start(timeout, this);
    }
    static void set(QNetworkReply* reply, const int timeout) {
        new ReplyTimeout(reply, timeout);
    }

private:
    int milliseconds_;
    QBasicTimer mSec_timer_;

    void timerEvent(QTimerEvent * ev);
};

#endif //DOWNLOAD_MANAGER_H
