#include <VersionedListModel.h>
#include <QJsonDocument>
#include <QJsonObject>
#include <QFileInfo>
#include <QDir>
#include <QVector>
#include <QDebug>
#include "logging/LoggingQtCategories.h"

VersionedListModel::VersionedListModel(QObject *parent)
    : QAbstractListModel(parent)
{

}

VersionedListModel::~VersionedListModel()
{
    clear();
}

QVariant VersionedListModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= data_.count()) {
        return QVariant();
    }

    VersionedItem *item = data_.at(row);

    if (item == nullptr) {
        return QVariant();
    }

    switch (role) {
    case UriRole:
        return item->uri;
    case NameRole:
        return item->name;
    case Md5Role:
        return item->md5;
    case TimestampRole:
        return item->timestamp;
    case VersionRole:
        return item->version;
    case InstalledRole:
        return item->installed;
    }

    return QVariant();
}

int VersionedListModel::count() const
{
    return data_.length();
}

int VersionedListModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)

    return data_.length();
}

void VersionedListModel::populateModel(const QList<VersionedItem *> &list)
{
    beginResetModel();
    clear(false);

    for (int i = 0; i < list.length(); ++i) {
        VersionedItem *item = list.at(i);
        data_.append(item);
    }

    endResetModel();

    emit countChanged();
}

void VersionedListModel::clear(bool emitSignals)
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

QString VersionedListModel::version(int index)
{
    return data(VersionedListModel::index(index, 0), VersionRole).toString();
}

void VersionedListModel::setInstalled(int index, bool installed)
{
    if (index < 0 || index >= data_.count()) {
        return;
    }

    VersionedItem *item = data_.at(index);
    if (item->installed == installed) {
        return;
    }

    item->installed = installed;
    emit dataChanged(
                createIndex(index, 0),
                createIndex(index, 0),
                QVector<int>() << InstalledRole);
}

QHash<int, QByteArray> VersionedListModel::roleNames() const
{
    QHash<int, QByteArray> names;
    names[UriRole] = "uri";
    names[VersionRole] = "version";
    names[NameRole] = "name";
    names[TimestampRole] = "timestamp";
    names[Md5Role] = "md5";
    names[InstalledRole] = "installed";

    return names;
}
