#include "SGFileSystemModel.h"

SGFileSystemModel::SGFileSystemModel(QObject *parent) : QFileSystemModel(parent)
{
    setReadOnly(true);
    setFilter(QDir::NoDotAndDotDot | QDir::Files | QDir::Dirs);

}

SGFileSystemModel::~SGFileSystemModel()
{
}

QVariant SGFileSystemModel::data(const QModelIndex &index, int role) const
{
    if (index.isValid()) {
        if (role == FileSizeRole) {
            return QVariant(QFileSystemModel::fileInfo(index).size());
        } else if (role == FileInfoRole) {
            QFileInfo fi = QFileSystemModel::fileInfo(index);
            return QVariant::fromValue(fi);
        } else if (role == FileTypeRole) {
            return QVariant(QFileSystemModel::fileInfo(index).suffix());
        } else if (role == IsDirRole) {
            return QVariant(QFileSystemModel::fileInfo(index).isDir());
        } else {
            return QFileSystemModel::data(index, role);
        }
    }
    return QVariant();
}


QModelIndex SGFileSystemModel::rootIndex() const
{
    return rootIndex_;
}

QHash<int, QByteArray> SGFileSystemModel::roleNames() const
{
     QHash<int, QByteArray> result = QFileSystemModel::roleNames();
     result.insert(FileSizeRole, QByteArrayLiteral("size"));
     result.insert(FileInfoRole, QByteArrayLiteral("fileInfo"));
     result.insert(FileTypeRole, QByteArrayLiteral("fileType"));
     result.insert(IsDirRole, QByteArrayLiteral("isDir"));
     return result;
}


QString SGFileSystemModel::rootDirectory() const
{
    return rootDirectory_;
}

void SGFileSystemModel::setRootDirectory(QString root) {
    if (rootDirectory_ != root) {
        rootDirectory_ = root;
        rootIndex_ = setRootPath(rootDirectory_);
        emit rootIndexChanged();
        emit rootDirectoryChanged();
    }
}



