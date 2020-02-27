#include "FileModel.h"
#include "logging/LoggingQtCategories.h"

#include <QFileInfo>

FileModel::FileModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

FileModel::~FileModel()
{
    clear();
}

void FileModel::append(const QString &path)
{
    beginInsertRows(QModelIndex(),data_.length(),data_.length());

    FileItem item;
    item.filepath = path;
    data_.append(item);

    endInsertRows();
    emit countChanged();
}

QVariant FileModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();

    if (row < 0 || row >= data_.count()) {
        return QVariant();
    }
    FileItem item = data_.at(row);

    switch (role) {
    case FileNameRole:
        return QFileInfo(item.filepath).fileName();
    case FilePathRole:
        return item.filepath;
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

QStringList FileModel::getFilePaths() const
{
    QStringList filePaths;
    for (int i = 0; i < data_.length(); i++) {
        filePaths.append(data_[i].filepath);
    }
    return filePaths;
}

QString FileModel::getFilePathAt(const int &pos) const
{
    return data_[pos].filepath;
}

bool FileModel::containsFilePath(const QString &path)
{
    for (int i = 0; i < data_.length(); i++) {
        if (data_[i].filepath.contains(path)) {
            return true;
        }
    } return false;
}

void FileModel::clear(bool emitSignals)
{
    if (emitSignals) {
        beginResetModel();
    }
    data_.clear();

    if (emitSignals) {
        endResetModel();
    }
}

QHash<int, QByteArray> FileModel::roleNames() const
{
    QHash<int, QByteArray> names;
    names[FileNameRole] = "filename";
    names[FilePathRole] = "filepath";
    return names;
}
