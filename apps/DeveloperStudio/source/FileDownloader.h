/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QObject>
#include <QString>
#include <QHash>

/* forward declarations */
class CoreInterface;

namespace strata::strataRPC
{
class StrataClient;
}

class FileDownloader: public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(FileDownloader)
public:
    FileDownloader(strata::strataRPC::StrataClient *strataClient,
                     CoreInterface *coreInterface, QObject *parent = nullptr);
    virtual ~FileDownloader();

    Q_INVOKABLE void downloadDatasheetFile(const QString &fileUrl, const QString &classId);

    struct DownloadData {
        DownloadData() :
              downloadStatus("Download pending"),
              bytesTotal(-1),
              bytesReceived(0)
        {
        }
        QString filePath;
        QString downloadStatus;
        qint64 bytesTotal;
        qint64 bytesReceived;
    };

signals:
    void downloadFinished(const QString &fileUrl, const QString &filePath, const QString& errorString);
    void downloadStatus(const QString &fileUrl, const QString &downloadStatus);

private slots:
    void downloadFileReplyHandler(const QString &fileUrl, const QJsonObject &payload);
    void downloadFileErrorReplyHandler(const QString &fileUrl, const QJsonObject &payload);
    void downloadFilePathChangedHandler(const QJsonObject &payload);
    void singleDownloadProgressHandler(const QJsonObject &payload);
    void singleDownloadFinishedHandler(const QJsonObject &payload);

private:
    strata::strataRPC::StrataClient *strataClient_;
    CoreInterface *coreInterface_;

    QHash<QString /*URL*/, DownloadData> downloadingData_;
};
