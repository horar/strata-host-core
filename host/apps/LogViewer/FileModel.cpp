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

void FileModel::append(const QString &path)
{
    beginInsertRows(QModelIndex(),data_.length(),data_.length());

    data_.append(path);

    endInsertRows();
    emit countChanged();
}

QVariant FileModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();

    if (row < 0 || row >= data_.count()) {
        return QVariant();
    }
    QString filepath = data_.at(row);

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
    return data_.length();
}

int FileModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return data_.length();
}

QString FileModel::getFilePathAt(const int &pos) const
{
    return data_[pos];
}

bool FileModel::containsFilePath(const QString &path)
{
    return data_.contains(path);
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
