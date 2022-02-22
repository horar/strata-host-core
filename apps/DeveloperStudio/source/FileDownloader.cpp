/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include <PlatformInterface/core/CoreInterface.h>
#include <StrataRPC/StrataClient.h>

#include "SGUtilsCpp.h"
#include "FileDownloader.h"
#include "logging/LoggingQtCategories.h"

#include <QJsonObject>
#include <QDir>
#include <QUrl>

FileDownloader::FileDownloader(strata::strataRPC::StrataClient *strataClient,
                                   CoreInterface *coreInterface, QObject *parent)
    : QObject(parent), strataClient_(strataClient), coreInterface_(coreInterface)
{
    connect(coreInterface_, &CoreInterface::downloadPlatformFilepathChanged, this, &FileDownloader::downloadFilePathChangedHandler);
    connect(coreInterface_, &CoreInterface::downloadPlatformSingleFileProgress, this, &FileDownloader::singleDownloadProgressHandler);
    connect(coreInterface_, &CoreInterface::downloadPlatformSingleFileFinished, this, &FileDownloader::singleDownloadFinishedHandler);
}

FileDownloader::~FileDownloader()
{
    downloadingData_.clear();
}

void FileDownloader::downloadDatasheetFile(const QString &fileUrl, const QString &classId)
{
    if (fileUrl.isEmpty()) {
        qCWarning(lcFileDownloader) << "Empty URL provided";
        return;
    }

    auto iter = downloadingData_.find(fileUrl);
    if (iter != downloadingData_.end()) {
        qCDebug(lcFileDownloader) << "Download of" << fileUrl << "already in progress";
        emit downloadStatus(fileUrl, iter->downloadStatus); // update existing status
        return;
    }

    if (QUrl(fileUrl).fileName().isEmpty()) {
        QString errorString = "Error: Unable to parse filename from: " + fileUrl;
        qCWarning(lcFileDownloader) << errorString;
        emit downloadFinished(fileUrl, "", errorString);
        return;
    }

    QJsonObject payload
    {
        {"url",  fileUrl},
        {"class_id", classId}
    };

    strata::strataRPC::DeferredRequest *deferredRequest = strataClient_->sendRequest("download_datasheet_file", payload);

    if (deferredRequest == nullptr) {
        emit downloadFinished(fileUrl, "", "Error: unable to send download_datasheet_file request");
        return;
    }

    DownloadData downloadData;
    downloadingData_.insert(fileUrl, downloadData);

    qCDebug(lcFileDownloader) << "Preparing to download url" << fileUrl;
    emit downloadStatus(fileUrl, downloadData.downloadStatus);

    connect(
        deferredRequest, &strata::strataRPC::DeferredRequest::finishedSuccessfully, this,
        [this, fileUrl] ( const QJsonObject &payload ) { downloadFileReplyHandler( fileUrl, payload ); }
    );

    connect(
        deferredRequest, &strata::strataRPC::DeferredRequest::finishedWithError, this,
        [this, fileUrl] ( const QJsonObject &payload ) { downloadFileErrorReplyHandler( fileUrl, payload ); }
    );
}

void FileDownloader::downloadFileReplyHandler(const QString &fileUrl, const QJsonObject &payload)
{
    auto iter = downloadingData_.find(fileUrl);
    if (iter == downloadingData_.end()) {
        qCWarning(lcFileDownloader) << "Error: invalid fileUrl provided" << fileUrl;
        return;
    }

    const QJsonValue message = payload.value("message");
    if (message.isString()) {
        qCDebug(lcFileDownloader) << fileUrl << message.toString();
    } else {
        qCWarning(lcFileDownloader).nospace() << "Succesfully initiated file download for: " << fileUrl << ", but received malformated reply: " << payload;
    }

    if (iter->downloadStatus == "Download pending") {
        iter->downloadStatus = "Download starting";
        emit downloadStatus(fileUrl, iter->downloadStatus);
    }
}

void FileDownloader::downloadFileErrorReplyHandler(const QString &fileUrl, const QJsonObject &payload)
{
    auto iter = downloadingData_.find(fileUrl);
    if (iter == downloadingData_.end()) {
        qCWarning(lcFileDownloader) << "Error: invalid fileUrl provided" << fileUrl;
        return;
    }

    QString errorString("Error: Unable to initiate File Download");
    const QJsonValue message = payload.value("message");
    if (message.isString()) {
        errorString += ": " + message.toString();
    } else {
        qCWarning(lcFileDownloader).nospace() << "received malformated reply for: " << fileUrl << ", payload: " << payload;
    }

    emit downloadFinished(fileUrl, "", errorString);
    downloadingData_.erase(iter);
}

void FileDownloader::downloadFilePathChangedHandler(const QJsonObject &payload)
{
    if ((payload.contains("file_url") == false) ||
        (payload.contains("original_filepath") == false) ||
        (payload.contains("effective_filepath") == false)) {
        return;
    }

    QString fileUrl = payload["file_url"].toString();
    if (fileUrl.isEmpty()) {
        return;
    }
    QString effectiveFilePath = payload["effective_filepath"].toString();
    if (effectiveFilePath.isEmpty()) {
        return;
    }

    auto iter = downloadingData_.find(fileUrl);
    if (iter == downloadingData_.end()) {
        // not our file
        return;
    }

    // always overwrite
    iter->filePath = effectiveFilePath;
}

void FileDownloader::singleDownloadProgressHandler(const QJsonObject &payload)
{
    if ((payload.contains("file_url") == false) ||
        (payload.contains("filepath") == false) ||
        (payload.contains("bytes_received") == false) ||
        (payload.contains("bytes_total") == false)) {
        return;
    }

    QString fileUrl = payload["file_url"].toString();
    if (fileUrl.isEmpty()) {
        return;
    }
    QString filePath = payload["filepath"].toString();
    if (filePath.isEmpty()) {
        return;
    }

    auto iter = downloadingData_.find(fileUrl);
    if (iter == downloadingData_.end()) {
        // not our file
        return;
    }

    if (iter->filePath.isEmpty()) {
        iter->filePath = filePath;
    }
    iter->bytesReceived = payload["bytes_received"].toVariant().toLongLong();
    iter->bytesTotal = payload["bytes_total"].toVariant().toLongLong();

    if (iter->bytesTotal > 0) {
        if (iter->bytesReceived != iter->bytesTotal) {
            iter->downloadStatus = SGUtilsCpp::formattedDataSize(iter->bytesReceived, 2) + " / " + SGUtilsCpp::formattedDataSize(iter->bytesTotal, 2);
        } else {
            iter->downloadStatus = "Download finished";
        }
    } else {
        iter->downloadStatus = SGUtilsCpp::formattedDataSize(iter->bytesReceived, 2);
    }
    emit downloadStatus(fileUrl, iter->downloadStatus);
}

void FileDownloader::singleDownloadFinishedHandler(const QJsonObject &payload)
{
    if ((payload.contains("file_url") == false) ||
        (payload.contains("filepath") == false) ||
        (payload.contains("error_string") == false)) {
        return;
    }

    QString fileUrl = payload["file_url"].toString();
    if (fileUrl.isEmpty()) {
        return;
    }
    QString filePath = payload["filepath"].toString();
    if (filePath.isEmpty()) {
        return;
    }

    auto iter = downloadingData_.find(fileUrl);
    if (iter == downloadingData_.end()) {
        // not our file
        return;
    }

    if (iter->filePath.isEmpty()) {
        iter->filePath = filePath;
    }
    QString errorString = payload["error_string"].toString();

    if (errorString.isEmpty() == false) {
        qCDebug(lcFileDownloader) << "Download failed, URL:" << fileUrl << "error:" << errorString;
    } else {
        qCDebug(lcFileDownloader) << "Download succeeded, URL:" << fileUrl << "path:" << iter->filePath;
    }

    emit downloadFinished(fileUrl, iter->filePath, errorString);
    downloadingData_.erase(iter);
}
