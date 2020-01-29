#include <DownloadDocumentListModel.h>
#include <QJsonDocument>
#include <QJsonObject>
#include <QFileInfo>
#include <QDir>
#include <QVector>
#include <QDebug>
#include "logging/LoggingQtCategories.h"

DownloadDocumentListModel::DownloadDocumentListModel(CoreInterface *coreInterface, QObject *parent)
    : QAbstractListModel(parent),
      coreInterface_(coreInterface)
{

    connect(coreInterface_, &CoreInterface::singleDownloadProgress, this, &DownloadDocumentListModel::downloadProgressHandler);
    connect(coreInterface_, &CoreInterface::singleDownloadFinished, this, &DownloadDocumentListModel::downloadFinishedHandler);
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
    case FilenameRole:
        return item->filename;
    case DirnameRole:
        return item->dirname;
    case PreviousDirnameRole:
        return data(DownloadDocumentListModel::index(row - 1, 0), DirnameRole);
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

    savePath_ = saveUrl.path();


    for (int i = 0; i < data_.length(); ++i) {
        DownloadDocumentItem* item = data_.at(i);
        if (item == nullptr) {
            qCWarning(logCategoryDocumentManager) << "item is empty" << i;
            continue;
        }

        if (item->status == DownloadStatus::Selected) {
            QJsonObject object;
            object.insert("file", item->uri);
            object.insert("path", savePath_);
            object.insert("name", item->filename);

            fileArray.append(object);

            item->status = DownloadStatus::Waiting;

            qCDebug(logCategoryDocumentManager) << "download file" << item->filename << "into" << savePath_;

            downloadingData_.insert(dir.filePath(item->filename), item);

        } else {
            item->status = DownloadStatus::NotSelected;
        }

        item->progress = 0.0f;
        item->bytesReceived = 0;
        item->bytesTotal = 0;

        emit dataChanged(
                    createIndex(i, 0),
                    createIndex(i, 0),
                    QVector<int>() << StatusRole << ProgressRole << BytesReceivedRole << BytesTotalRole);
    }

    QJsonObject message;
    message.insert("hcs::cmd", "download_files");
    message.insert("payload", fileArray);
    doc.setObject(message);

    coreInterface_->sendCommand(doc.toJson());

    emit downloadInProgressChanged();
}

QHash<int, QByteArray> DownloadDocumentListModel::roleNames() const
{
    QHash<int, QByteArray> names;
    names[UriRole] = "uri";
    names[FilenameRole] = "filename";
    names[DirnameRole] = "dirname";
    names[PreviousDirnameRole] = "previousDirname";
    names[ProgressRole] = "progress";
    names[StatusRole] = "status";
    names[ErrorStringRole] = "errorString";
    names[BytesReceivedRole] = "bytesReceived";
    names[BytesTotalRole] = "bytesTotal";

    return names;
}

void DownloadDocumentListModel::downloadProgressHandler(const QJsonObject &payload)
{
    QJsonDocument doc(payload);

    QString filename = payload["filename"].toString();
    if (downloadingData_.contains(filename) == false) {
        //not our file
        return;
    }

    DownloadDocumentItem* item = downloadingData_.value(filename);
    if (item == nullptr) {
        return;
    }

    QVector<int> roles;
    item->bytesReceived = payload["bytes_received"].toVariant().toLongLong();
    roles << BytesReceivedRole;

    qint64 bytesTotal = payload["bytes_total"].toVariant().toLongLong();
    if (item->bytesTotal != bytesTotal) {
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

void DownloadDocumentListModel::downloadFinishedHandler(const QJsonObject &payload)
{
    QString filename = payload["filename"].toString();

    if (downloadingData_.contains(filename) == false) {
        //not our file
        return;
    }

    QString errorString = payload["error_string"].toString();

    DownloadDocumentItem* item = downloadingData_.value(filename);
    if (item == nullptr) {
        return;
    }

    QVector<int> roles;

    if (errorString.isEmpty()) {
        item->status = DownloadStatus::Finished;
        roles << StatusRole;

        qCDebug(logCategoryDocumentManager) << "filename" << filename;
    } else {
        item->status = DownloadStatus::FinishedWithError;
        item->errorString = errorString ;
        roles << StatusRole << ErrorStringRole;

        qCDebug(logCategoryDocumentManager) << "filename" << filename << "error:" << errorString;
    }

    emit dataChanged(
                createIndex(item->index, 0),
                createIndex(item->index, 0),
                roles);

    downloadingData_.remove(filename);

    if(downloadingData_.isEmpty()) {
        emit downloadInProgressChanged();
    }
}
