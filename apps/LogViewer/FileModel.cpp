/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "FileModel.h"
#include "logging/LoggingQtCategories.h"

#include <QFileInfo>

FileModel::FileModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

FileModel::~FileModel()
{
}

int FileModel::append(const QString &path)
{
    if (getDataIndex(path) < 0) {
        beginInsertRows(QModelIndex(),data_.length(),data_.length());
        data_.append(FileData(path));
        endInsertRows();
        emit countChanged();
        return data_.size() - 1;
    } else {
        return -1;
    }
}

int FileModel::remove(const QString &path)
{
    const int index = getDataIndex(path);
    if (index >= 0) {
        beginRemoveRows(QModelIndex(), index, index);
        data_.removeAt(index);
        endRemoveRows();
        emit countChanged();
    }
    return index;
}

QVariant FileModel::data(const QModelIndex &index, int role) const
{
    const int row = index.row();

    if (row < 0 || row >= data_.size()) {
        return QVariant();
    }
    const QString filepath = data_.at(row).path;

    switch (role) {
    case FileNameRole:
        return QFileInfo(filepath).fileName();
    case FilePathRole:
        return filepath;
    }
    return QVariant();
}

int FileModel::count() const
{
    return data_.size();
}

int FileModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return data_.size();
}

QString FileModel::getFilePathAt(int index) const
{
    return ((index >= 0) && (index < data_.size()))
        ? data_.at(index).path
        : QString();
}

qint64 FileModel::getLastPositionAt(int index) const
{
    return ((index >= 0) && (index < data_.size()))
        ? data_.at(index).lastPosition
        : -1;
}

void FileModel::setLastPositionAt(int index, qint64 filePosition)
{
    if ((index >= 0) && (index < data_.size())) {
        data_[index].lastPosition = filePosition;
    }
}

bool FileModel::containsFilePath(const QString &path) const
{
    return (getDataIndex(path) >= 0);
}

int FileModel::getFileIndex(const QString &path) const
{
    return getDataIndex(path);
}

void FileModel::copyFileMetadata(int fromIndex, int toIndex)
{
    if ((fromIndex != toIndex)
        && (fromIndex >= 0) && (fromIndex < data_.size())
        && (toIndex >= 0) && (toIndex < data_.size()))
    {
        data_[toIndex].lastPosition = data_.at(fromIndex).lastPosition;
    }
}

void FileModel::clear()
{
    beginResetModel();
    data_.clear();
    endResetModel();
}

QHash<int, QByteArray> FileModel::roleNames() const
{
    QHash<int, QByteArray> names;
    names[FileNameRole] = "filename";
    names[FilePathRole] = "filepath";
    return names;
}

int FileModel::getDataIndex(const QString &path) const {
    int index = -1;
    for (int i = 0; i < data_.size(); ++i) {
        if (data_.at(i).path == path) {
            index = i;
            break;
        }
    }
    return index;
}
