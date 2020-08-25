#include "VersionedListModel.h"
#include "logging/LoggingQtCategories.h"
#include "SGVersionUtils.h"

#include <QJsonDocument>
#include <QJsonObject>
#include <QFileInfo>
#include <QDir>
#include <QVector>
#include <QDebug>

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
    case FilepathRole:
        return item->filepath;
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

QString VersionedListModel::uri(int index)
{
    return data(VersionedListModel::index(index, 0), UriRole).toString();
}

QString VersionedListModel::md5(int index)
{
    return data(VersionedListModel::index(index, 0), Md5Role).toString();
}

QString VersionedListModel::name(int index)
{
    return data(VersionedListModel::index(index, 0), NameRole).toString();
}

QString VersionedListModel::timestamp(int index)
{
    return data(VersionedListModel::index(index, 0), TimestampRole).toString();
}

bool VersionedListModel::installed(int index)
{
    return data(VersionedListModel::index(index, 0), InstalledRole).toBool();
}

QString VersionedListModel::filepath(int index)
{
    return data(VersionedListModel::index(index, 0), FilepathRole).toString();
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

void VersionedListModel::setFilepath(int index, QString path)
{
    if (index < 0 || index >= data_.count()) {
        return;
    }

    VersionedItem *item = data_.at(index);
    if (item->filepath == path) {
        return;
    }

    item->filepath = path;
    emit dataChanged(
                createIndex(index, 0),
                createIndex(index, 0),
                QVector<int>() << FilepathRole);
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
    names[FilepathRole] = "filepath";

    return names;
}

int VersionedListModel::getLatestVersion() {
    QStringList versions;
    for (VersionedItem *versionItem : data_) {
        versions.append(versionItem->version);
    }

    int latestVersionIndex = SGVersionUtils::getGreatestVersion(versions);

    return latestVersionIndex;
}

int VersionedListModel::getInstalledVersion() {
    int oldestInstalledIndex = -1;

    for (int i = 0; i < data_.count(); i++) {
        if (data_[i]->installed && (oldestInstalledIndex == -1 || SGVersionUtils::greaterThan(data_[oldestInstalledIndex]->version, data_[i]->version))) {
            oldestInstalledIndex = i;
        }
    }
    return oldestInstalledIndex;
}

