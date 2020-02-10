#include "DocumentListModel.h"

DocumentListModel::DocumentListModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

DocumentListModel::~DocumentListModel()
{
    clear();
}

QVariant DocumentListModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= data_.count()) {
        return QVariant();
    }

    DocumentItem *item = data_.at(row);

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
        return data(DocumentListModel::index(row - 1, 0), DirnameRole);
    }

    return QVariant();
}

int DocumentListModel::count() const
{
    return data_.length();
}

int DocumentListModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)

    return data_.length();
}

void DocumentListModel::populateModel(const QList<DocumentItem *> &list)
{
    beginResetModel();

    clear(false);
    data_.append(list);

    endResetModel();

    emit countChanged();
}

void DocumentListModel::clear(bool emitSignals)
{
    if (emitSignals) {
        beginResetModel();
    }

    for (int i = 0; i < data_.length(); i++) {
        delete data_[i];
    }
    data_.clear();

    if (emitSignals) {
        endResetModel();
        emit countChanged();
    }
}

QString DocumentListModel::getFirstUri()
{
    if (data_.length() == 0) {
        return QString();
    }

    return data_.at(0)->uri;
}

QHash<int, QByteArray> DocumentListModel::roleNames() const
{
    QHash<int, QByteArray> names;
    names[UriRole] = "uri";
    names[FilenameRole] = "filename";
    names[DirnameRole] = "dirname";
    names[PreviousDirnameRole] = "previousDirname";

    return names;
}
