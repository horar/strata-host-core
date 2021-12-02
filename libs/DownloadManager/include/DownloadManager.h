/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QObject>
#include <QString>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QList>
#include <QMap>
#include <QPointer>
#include <QCryptographicHash>
#include <QFile>

namespace strata {

class InternalDownloadRequest;

class DownloadManager : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(DownloadManager)

public:
    DownloadManager(QNetworkAccessManager *manager, QObject* parent = nullptr);
    ~DownloadManager() override;

    struct DownloadRequestItem {
        QUrl url;
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
              oneFailsAllFail(true),
              removeCorruptedFile(true)
        {
        }

        QString id;

        bool notifySingleDownloadProgress;
        bool notifySingleDownloadFinished;
        bool notifyGroupDownloadProgress;

        /*! When true and filePath alredy exists, download is either skipped or
         * old file is removed before new download starts.
         * When false and filePath alrady exists file is downloaded
         * and saved under different name. */
        bool keepOriginalName;

        /*! When true and one of downloaded items fails,
         * all remaining are aborted. */
        bool oneFailsAllFail;

        /*! When true, wrongly downloaded file is removed.
         *
         * When saved file is managed outside of DownloadManager, it is useful
         * to have it false along with keepOriginalName=true,
         * for example when saved file is created in advance with QTemporaryFile.
         */
        bool removeCorruptedFile;
    };

    void setMaxDownloadCount(int maxDownloadCount);

    QString download(const QList<DownloadRequestItem> &items,
                     const Settings &settings=Settings());

    bool verifyFileHash(
            const QString &filePath,
            const QString &checksum,
            const QCryptographicHash::Algorithm method = QCryptographicHash::Md5);

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
    void networkReplyReadyReadHandler();
    void networkReplyProgressHandler(qint64 bytesReceived, qint64 bytesTotal);
    void networkReplyFinishedHandler();
    void networkReplyRedirectedHandler();

private:
    struct DownloadGroup {
        QString id;
        Settings settings;
        QString errorString;
        bool aborted = false;
    };

    QPointer<QNetworkAccessManager> networkManager_;
    QList<QNetworkReply*> currentDownloads_;

    /* As of Qt 5.12 QNetworkAccessManager can handle up to 6 http requests in parallel.
      This number should be lower so other clients are not blocked for a long time. */
    int maxDownloadCount_ = 4;

    QList<InternalDownloadRequest*> internalRequestList_;
    QHash<QString /*groupId*/, DownloadGroup*> groupHash_;

    void startNextDownload();
    bool postNextDownloadRequest(InternalDownloadRequest *internalRequest);

    void processRequest(InternalDownloadRequest *internalRequest, const DownloadRequestItem &request);
    InternalDownloadRequest* findNextPendingDownload();
    void createFolderForFile(const QString &filePath);
    QNetworkReply* postNetworkRequest(const QUrl &url, QObject *originatingObject);
    QString writeToFile(QFile &file, const QByteArray &data);
    void prepareResponse(InternalDownloadRequest *internalRequest, const QString &errorString=QString());
    void resolveGroupProgress(
            const QString &groupId,
            int &filesFailed,
            int &filesCompleted,
            int &filesTotal);

    void clearData(const QString groupId);
    void abortReply(QNetworkReply *reply);
};

}
