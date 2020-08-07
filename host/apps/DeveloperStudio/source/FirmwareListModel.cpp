#include <FirmwareListModel.h>
#include <QJsonDocument>
#include <QJsonObject>
#include <QFileInfo>
#include <QDir>
#include <QVector>
#include <QDebug>
#include "logging/LoggingQtCategories.h"

FirmwareListModel::FirmwareListModel(QObject *parent)
    : QAbstractListModel(parent)
{

}

FirmwareListModel::~FirmwareListModel()
{
    clear();
}

QVariant FirmwareListModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= data_.count()) {
        return QVariant();
    }

    FirmwareItem *item = data_.at(row);

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

int FirmwareListModel::count() const
{
    return data_.length();
}

int FirmwareListModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)

    return data_.length();
}

void FirmwareListModel::populateModel(const QList<FirmwareItem *> &list)
{
    beginResetModel();
    clear(false);

    for (int i = 0; i < list.length(); ++i) {
        FirmwareItem *item = list.at(i);
        data_.append(item);
    }

    endResetModel();

    emit countChanged();
}

void FirmwareListModel::clear(bool emitSignals)
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

QString FirmwareListModel::version(int index)
{
    return data(FirmwareListModel::index(index, 0), VersionRole).toString();
}

void FirmwareListModel::setInstalled(int index, bool installed)
{
    if (index < 0 || index >= data_.count()) {
        return;
    }

    FirmwareItem *item = data_.at(index);
    if (item->installed == installed) {
        return;
    }

    item->installed = installed;
    emit dataChanged(
                createIndex(index, 0),
                createIndex(index, 0),
                QVector<int>() << InstalledRole);
}

QHash<int, QByteArray> FirmwareListModel::roleNames() const
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
