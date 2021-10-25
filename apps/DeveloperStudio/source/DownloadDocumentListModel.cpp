/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include <DownloadDocumentListModel.h>
#include <PlatformInterface/core/CoreInterface.h>
#include <StrataRPC/StrataClient.h>

#include "logging/LoggingQtCategories.h"

#include <QJsonDocument>
#include <QJsonObject>
#include <QFileInfo>
#include <QDir>
#include <QVector>
#include <QDebug>

DownloadDocumentListModel::DownloadDocumentListModel(strata::strataRPC::StrataClient *strataClient,
                                                     CoreInterface *coreInterface, QObject *parent)
    : QAbstractListModel(parent), strataClient_(strataClient), coreInterface_(coreInterface)
{
    connect(coreInterface_, &CoreInterface::downloadPlatformFilepathChanged, this, &DownloadDocumentListModel::downloadFilePathChangedHandler);
    connect(coreInterface_, &CoreInterface::downloadPlatformSingleFileProgress, this, &DownloadDocumentListModel::singleDownloadProgressHandler);
    connect(coreInterface_, &CoreInterface::downloadPlatformSingleFileFinished, this, &DownloadDocumentListModel::singleDownloadFinishedHandler);
    connect(coreInterface_, &CoreInterface::downloadPlatformFilesFinished, this, &DownloadDocumentListModel::groupDownloadFinishedHandler);
}

DownloadDocumentListModel::~DownloadDocumentListModel()
{
    clear();
}

QVariant DownloadDocumentListModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= data_.count()) {
        return QVariant();
    }

    DownloadDocumentItem *item = data_.at(row);

    if (item == nullptr) {
        return QVariant();
    }

    switch (role) {
    case UriRole:
        return item->uri;
    case PrettyNameRole:
        return item->prettyName;
    case DownloadFilenameRole:
        return item->downloadFilename;
    case DirnameRole:
        return item->dirname;
    case PreviousDirnameRole:
        return data(DownloadDocumentListModel::index(row - 1, 0), DirnameRole);
    case HistoryStateRole:
        return item->historyState;
    case ProgressRole:
        return item->progress;
    case StatusRole:
        return static_cast<int>(item->status);
    case ErrorStringRole:
        return item->errorString;
    case BytesReceivedRole:
        return item->bytesReceived;
    case BytesTotalRole:
        return item->bytesTotal;
    }

    return QVariant();
}

int DownloadDocumentListModel::count() const
{
    return data_.length();
}

int DownloadDocumentListModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)

    return data_.length();
}

bool DownloadDocumentListModel::downloadInProgress()
{
    return downloadingData_.isEmpty() == false;
}

void DownloadDocumentListModel::populateModel(const QList<DownloadDocumentItem *> &list)
{
    beginResetModel();
    clear(false);

    for (int i = 0; i < list.length(); ++i) {
        DownloadDocumentItem *item = list.at(i);
        item->downloadFilename = item->prettyName;
        item->index = i;
        data_.append(item);
    }

    endResetModel();

    emit countChanged();
}

void DownloadDocumentListModel::clear(bool emitSignals)
{
    if (emitSignals) {
        beginResetModel();
    }

    for (int i = 0; i < data_.length(); i++) {
        delete data_[i];
    }
    data_.clear();
    downloadingData_.clear();
    emit downloadInProgressChanged();

    if (emitSignals) {
        endResetModel();
        emit countChanged();
    }
}


void DownloadDocumentListModel::setSelected(int index, bool selected)
{
    if (index < 0 || index >= data_.count()) {
        return;
    }

    DownloadDocumentItem *item = data_.at(index);

    if (item == nullptr) {
        return;
    }

    if ((item->status == DownloadStatus::Selected) == selected) {
        return;
    }

    if (item->status == DownloadStatus::Selected) {
        item->status = DownloadStatus::NotSelected;
    } else {
        item->status = DownloadStatus::Selected;
    }

    emit dataChanged(
                createIndex(index, 0),
                createIndex(index, 0),
                QVector<int>() << StatusRole);
}

void DownloadDocumentListModel::downloadSelectedFiles(const QUrl &saveUrl)
{
    QJsonDocument doc;
    QJsonArray fileArray;
    QDir dir(saveUrl.path());

    for (int i = 0; i < data_.length(); ++i) {
        DownloadDocumentItem* item = data_.at(i);
        if (item == nullptr) {
            qCCritical(lcDocumentManager) << "item is empty" << i;
            continue;
        }

        if (item->status == DownloadStatus::Selected) {
            fileArray.append(item->uri);
            downloadingData_.insert(dir.filePath(item->prettyName), item);

            item->status = DownloadStatus::Waiting;

            qCDebug(lcDocumentManager)
                    << "uri" << item->uri;
        } else {
            item->status = DownloadStatus::NotSelected;
        }

        item->progress = 0.0f;
        item->bytesReceived = 0;
        item->downloadFilename = item->prettyName;

        emit dataChanged(
                    createIndex(i, 0),
                    createIndex(i, 0),
                    QVector<int>() << StatusRole << ProgressRole << BytesReceivedRole << BytesTotalRole << DownloadFilenameRole);
    }

    QJsonObject payload
    {
        {"files",  fileArray},
        {"destination_dir", saveUrl.path()}
    };

    strataClient_->sendRequest("download_files", payload);

    emit downloadInProgressChanged();
}

QHash<int, QByteArray> DownloadDocumentListModel::roleNames() const
{
    QHash<int, QByteArray> names;
    names[UriRole] = "uri";
    names[PrettyNameRole] = "prettyName";
    names[DownloadFilenameRole] = "downloadFilename";
    names[DirnameRole] = "dirname";
    names[PreviousDirnameRole] = "previousDirname";
    names[HistoryStateRole] = "historyState";
    names[ProgressRole] = "progress";
    names[StatusRole] = "status";
    names[ErrorStringRole] = "errorString";
    names[BytesReceivedRole] = "bytesReceived";
    names[BytesTotalRole] = "bytesTotal";

    return names;
}

void DownloadDocumentListModel::downloadFilePathChangedHandler(const QJsonObject &payload)
{
    QJsonDocument doc(payload);
    QString originalFilePath = payload["original_filepath"].toString();
    if (downloadingData_.contains(originalFilePath) == false) {
        //not our file
        return;
    }

    DownloadDocumentItem* item = downloadingData_.value(originalFilePath);
    if (item == nullptr) {
        return;
    }

    QString effectiveFilePath = payload["effective_filepath"].toString();

    QFileInfo info(effectiveFilePath);

    QVector<int> roles;
    item->downloadFilename = info.fileName();
    roles << DownloadFilenameRole;

    emit dataChanged(
                createIndex(item->index, 0),
                createIndex(item->index, 0),
                roles);
}

void DownloadDocumentListModel::singleDownloadProgressHandler(const QJsonObject &payload)
{
    QJsonDocument doc(payload);

    QString filePath = payload["filepath"].toString();
    if (downloadingData_.contains(filePath) == false) {
        //not our file
        return;
    }

    DownloadDocumentItem* item = downloadingData_.value(filePath);
    if (item == nullptr) {
        return;
    }

    QVector<int> roles;
    item->bytesReceived = payload["bytes_received"].toVariant().toLongLong();
    roles << BytesReceivedRole;

    qint64 bytesTotal = payload["bytes_total"].toVariant().toLongLong();
    if (bytesTotal > 0 && item->bytesTotal != bytesTotal) {
        item->bytesTotal = payload["bytes_total"].toVariant().toLongLong();
        roles << BytesTotalRole;
    }

    item->progress = (float)item->bytesReceived/item->bytesTotal;
    roles << ProgressRole;

    if (item->status == DownloadStatus::Waiting) {
        item->status = DownloadStatus::InProgress;
        roles << StatusRole;
    }

    emit dataChanged(
                createIndex(item->index, 0),
                createIndex(item->index, 0),
                roles);
}

void DownloadDocumentListModel::singleDownloadFinishedHandler(const QJsonObject &payload)
{
    QString filePath = payload["filepath"].toString();

    if (downloadingData_.contains(filePath) == false) {
        //not our file
        return;
    }

    QString errorString = payload["error_string"].toString();

    DownloadDocumentItem* item = downloadingData_.value(filePath);
    if (item == nullptr) {
        return;
    }

    QVector<int> roles;

    if (errorString.isEmpty()) {
        item->status = DownloadStatus::Finished;
        roles << StatusRole;

        qCDebug(lcDocumentManager) << "filePath" << filePath;
    } else {
        item->status = DownloadStatus::FinishedWithError;
        item->errorString = errorString ;
        roles << StatusRole << ErrorStringRole;

        qCDebug(lcDocumentManager) << "filePath" << filePath << "error:" << errorString;
    }

    emit dataChanged(
                createIndex(item->index, 0),
                createIndex(item->index, 0),
                roles);

    downloadingData_.remove(filePath);
}

void DownloadDocumentListModel::groupDownloadFinishedHandler(const QJsonObject &payload)
{
    QString errorString = payload["error_string"].toString();

    if (errorString.isEmpty() == false) {
        qCWarning(lcDocumentManager) << "downloading finished with error" << errorString;
        QHashIterator<QString, DownloadDocumentItem*>  iter(downloadingData_);
        while (iter.hasNext()) {
            DownloadDocumentItem *item = iter.next().value();

            QVector<int> roles;
            item->status = DownloadStatus::FinishedWithError;
            item->errorString = errorString ;
            roles << StatusRole << ErrorStringRole;

            emit dataChanged(
                        createIndex(item->index, 0),
                        createIndex(item->index, 0),
                        roles);
        }
    }

    downloadingData_.clear();

    emit downloadInProgressChanged();
}

QString DownloadDocumentListModel::getMD5()
{
    QJsonObject jsonObj;
    for (const auto &item : data_) {
        jsonObj.insert(item->dirname + "_" + item->prettyName, item->md5);
    }
    QJsonDocument doc(jsonObj);
    QString strJson(doc.toJson(QJsonDocument::Compact));
    return strJson;
}

void DownloadDocumentListModel::setHistoryState(const QString &doc, const QString &state)
{
    for (int i = 0; i < data_.length(); ++i) {
        DownloadDocumentItem* item = data_.at(i);
        if (item == nullptr) {
            qCCritical(lcDocumentManager) << "item is empty" << i;
            continue;
        }

        if (item->dirname + "_" + item->prettyName == doc) {
            item->historyState = state;
            emit dataChanged(createIndex(i, 0), createIndex(i, 0));
            return;
        }
    }
}

void DownloadDocumentListModel::setAllHistoryStateToSeen()
{
    for (const auto &item : data_) {
        item->historyState = "seen";
    }
}

bool DownloadDocumentListModel::anyItemsUnseen()
{
    for (const auto &item : data_) {
        if (item->historyState != "seen") {
            return true;
        }
    }
    return false;
}

QStringList DownloadDocumentListModel::getItemsUnseen()
{
    QStringList ls;
    for (const auto &item : data_) {
        if (item->historyState != "seen") {
            ls << item->prettyName;
        }
    }
    return ls;
}
