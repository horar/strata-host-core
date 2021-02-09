#ifndef STORAGE_MANAGER_H
#define STORAGE_MANAGER_H

#include <memory>

#include <QObject>
#include <QStringList>
#include <QMap>
#include <QJsonArray>
#include <QDebug>
#include <QUrl>
#include <QPointer>
#include <QPair>

namespace strata {
class DownloadManager;
}

class PlatformDocument;
class Database;

class StorageManager final : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(StorageManager)

public:
    StorageManager(strata::DownloadManager *downloadManager, QObject* parent = nullptr);
    ~StorageManager();

    /**
     * Sets the database pointer
     * @param db
     */
    void setDatabase(Database* db);

    /**
     * @brief setBaseFolder
     * @param base folder for database and documents
     */
    void setBaseFolder(const QString &baseFolder);

    /**
     * Sets the base URL for downloads
     * @param url base URL
     */
    void setBaseUrl(const QUrl &url);

    /**
     * Gets the base URL for downloads
     * @return base URL
     */
    QUrl getBaseUrl() const;

    /**
     * Gets string which represnets device controler class
     * @param device class id
     * @return device controler class (RSL10, ...) or null string
     */
    QString getControllerClassDevice(const QString &classId);

    /**
     * Gets URI of latest firmware
     * @param class ID of device
     * @param device controler class
     * @return firmware URI and firmware MD5 as pair
     */
    QPair<QUrl,QString> getLatestFirmware(const QString &classId, const QString &controllerClassDevice);

    /**
     * Gets MD5 of firmware
     * @param class ID of device
     * @param device controler class
     * @param version of firmware
     * @return firmware MD5
     */
    QString getFirmwareMD5(const QString &classId, const QString &controllerClassDevice, const QString &version);

public slots:
    void requestPlatformList(const QByteArray &clientId);

    void requestPlatformDocuments(
            const QByteArray &clientId,
            const QString &classId);

    void requestDownloadPlatformFiles(
            const QByteArray &clientId,
            const QStringList &partialUriList,
            const QString &destinationDir);

    void requestDownloadControlView(
            const QByteArray &clientId,
            const QString &partialUri,
            const QString &md5,
            const QString &class_id);

    void requestCancelAllDownloads(const QByteArray &clientId);

    /**
     * Notification about the update of the document (from Database)
     * @param classId document ID to update
     */
    void updatePlatformDoc(const QString &classId);

signals:
    void downloadPlatformFilePathChanged(QByteArray clientId, const QString& originalFilePath, const QString& effectiveFilePath);

    void downloadPlatformSingleFileProgress(QByteArray clientId, QString filePath, qint64 bytesReceived, qint64 bytesTotal);
    void downloadPlatformSingleFileFinished(QByteArray clientId, QString filePath, QString errorString);
    void downloadPlatformDocumentsProgress(QByteArray clientId, QString classId, int filesCompleted, int filesTotal);
    void downloadControlViewProgress(QByteArray clientId, QString partialUri, QString classId, qint64 bytesReceived, qint64 bytesTotal);
    void downloadPlatformFilesFinished(QByteArray clientId, QString errorString);
    void downloadControlViewFinished(QByteArray clientId, QString partialUri, QString filePath, QString errorString);

    void platformListResponseRequested(QByteArray clientId, QJsonArray documentList);
    void platformDocumentsResponseRequested(QByteArray clientId, QString classId, QJsonArray datasheetList, QJsonArray documentList,
                                            QString error);
    void platformMetaData(QByteArray clientId, QString classId, QJsonArray firmwareList, QJsonArray controlViewList, QString error);

private slots:
    void filePathChangedHandler(QString groupId,
            QString originalFilePath,
            QString effectiveFilePath);

    void singleDownloadProgressHandler(
            const QString &groupId,
            const QString &filePath,
            const qint64 &bytesReceived,
            const qint64 &bytesTotal);

    void singleDownloadFinishedHandler(
            const QString &groupId,
            const QString &filePath,
            const QString &error);

    void groupDownloadProgressHandler(
            const QString &groupId,
            int filesCompleted,
            int filesTotal);

    void groupDownloadFinishedHandler(
            const QString &groupId,
            const QString &errorString);

private:

    enum class RequestType {
        PlatformList,
        PlatformDocuments,
        FileDownload,
        ControlViewDownload
    };

    struct DownloadRequest {
        QByteArray clientId;
        QString groupId;
        QString classId;
        RequestType type;
    };

    /**
     * fetch and insert the platform document object by given class id to the map
     * @param classId
     * @return returns platform document object or nullptr
     */
    PlatformDocument* fetchPlatformDoc(const QString &classId);

    void handlePlatformListResponse(const QByteArray &clientId, const QJsonArray &platformList);
    void handlePlatformDocumentsResponse(DownloadRequest *requestItem, const QString &errorString);

    /**
     * creates full filePath from item, prefix and storage location
     * @param item
     * @param prefix
     * @return returns full filePath
     */
    QString createFilePathFromItem(const QString& item, const QString& prefix) const;

    QUrl baseUrl_;       //base part of the URL to download
    QString baseFolder_;    //base folder for store downloaded files
    QPointer<strata::DownloadManager> downloadManager_;
    Database* db_{nullptr};
    QHash<QString /*groupId*/, DownloadRequest* > downloadRequests_;
    QHash<QString /*groupId*/, QString /*partialUri*/ > downloadControlViewUris_;
    QMap<QString /*classId*/, PlatformDocument*> documents_;
};

#endif //STORAGE_MANAGER_H
