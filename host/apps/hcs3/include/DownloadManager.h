
#ifndef HOST_HCS_DOWNLOADER_H__
#define HOST_HCS_DOWNLOADER_H__

#include <QObject>
#include <QString>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QVector>
#include <QList>
#include <QMap>
#include <QMutex>
#include <QScopedPointer>

class DownloadManager : public QObject
{
    Q_OBJECT

private:
    enum class EDownloadState {
        eUnknown = 0,
        eIdle,
        ePending,
        eDone,
        eCanceled,
    };

    struct DownloadItem {
        QString url;        //parital URL
        QString filename;
        EDownloadState state;
    };

public:
    DownloadManager(QObject* parent = nullptr);
    ~DownloadManager() override;

    /**
     * Sets the base part of the URL to download files
     * @param baseUrl base part of URL
     */
    void setBaseUrl(const QString& baseUrl);

    /**
     * Sets number of concurrent downloads, the default value is 4
     * @param count number
     */
    void setMaxDownloadCount(uint count);

    /**
     * Adds file to download.
     * @param url parital url to download
     * @param filename filename to store content
     */
    void download(const QString& url, const QString& filename);

    /**
     * @return returns number of downloads in progress
     */
    uint downloadCount() const { return currentDownloads_.size(); }

    /**
     * Stops download given by filename.
     * @param filename
     * @return returns true when succeeded otherwise false
     */
    bool stopDownloadByFilename(const QString& filename);

    /**
     * Stops all downloads
     */
    void stopAllDownloads();

signals:
    void downloadFinished(QString filename);
    void downloadFinishedError(QString filename, QString error);

    void downloadAbort(QNetworkReply* reply);

    void downloadProgress(QString filename, qint64 bytesReceived, qint64 bytesTotal);

private slots:
    void readyRead();
    void onDownloadFinished(QNetworkReply *reply);

    void slotError(QNetworkReply::NetworkError err);
    void sslErrors(const QList<QSslError>& errors);

    void onDownloadAbort(QNetworkReply* reply);
    void onDownloadProgress(qint64 bytesReceived, qint64 bytesTotal);

private:
    bool isHttpRedirect(QNetworkReply *reply);

    void beginDownload(DownloadItem& item);
    QNetworkReply* downloadFile(const QString& url);

    bool writeToFile(QNetworkReply* reply, const QByteArray& buffer);

    QList<DownloadItem>::iterator findNextDownload();
    QList<DownloadItem>::iterator findItemByFilename(const QString& filename);

    QNetworkReply* findReplyByFilename(const QString& filename);
    QString findFilenameForReply(QNetworkReply* reply);

private:
    QScopedPointer<QNetworkAccessManager> manager_;
    QVector<QNetworkReply*>  currentDownloads_;

    QMutex mapReplyFileMutex_;
    QMap<QNetworkReply*, QString> mapReplyToFile_;

    uint numberOfDownloads_;

    QString baseUrl_;

    QMutex downloadListMutex_;
    QList<DownloadItem> downloadList_;
};

#endif //HOST_HCS_DOWNLOADER_H__
