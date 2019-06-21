
#ifndef HOST_HCS_DOWNLOADER_H__
#define HOST_HCS_DOWNLOADER_H__

#include <QObject>
#include <QString>
#include <QtNetwork>
#include <QVector>
#include <QList>

class DownloadManager : public QObject
{
    Q_OBJECT

    struct DownloadItem {
        QString url;        //parital URL
        QString filename;
        QString state;
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
     * Stops all downloads
     */
    void stopAllDownloads();

signals:
    void downloadFinished(QString url);
    void downloadFinishedError(QString url, QString error);

    //TODO: void progress()

private slots:
    void readyRead();
    void onDownloadFinished(QNetworkReply *reply);

    void slotError();  //QNetworkReply::NetworkError err
    void sslErrors(const QList<QSslError> &errors);

private:
    bool isHttpRedirect(QNetworkReply *reply);

    void beginDownload(DownloadItem& item);
    QNetworkReply* downloadFile(const QString& url);

    void writeToFile(QNetworkReply* reply, const QByteArray& buffer);

    QList<DownloadItem>::iterator findNextDownload();
    QList<DownloadItem>::iterator findItemByFilename(const QString& filename);

private:
    QScopedPointer<QNetworkAccessManager> manager_;
    QVector<QNetworkReply*>  currentDownloads_;
    QMap<QNetworkReply*, QString> mapReplyToFile_;

    uint numberOfDownloads_;

    QString baseUrl_;

    QList<DownloadItem> downloadList_;
};

#endif //HOST_HCS_DOWNLOADER_H__
