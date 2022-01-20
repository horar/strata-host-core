/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
    case ControllerClassIdRole:
        return item->controller_class_id;
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

QString VersionedListModel::controller_class_id(int index)
{
    return data(VersionedListModel::index(index, 0), ControllerClassIdRole).toString();
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

QVariantMap VersionedListModel::get(int index)
{
    if (index < 0 || index >= data_.count()) {
        return QVariantMap();
    }

    VersionedItem *item = data_.at(index);
    QVariantMap map;
    map.insert("uri", item->uri);
    map.insert("md5", item->md5);
    map.insert("name", item->name);
    map.insert("timestamp", item->timestamp);
    map.insert("version", item->version);
    map.insert("filepath", item->filepath);
    map.insert("installed", item->installed);
    return map;
}


QHash<int, QByteArray> VersionedListModel::roleNames() const
{
    QHash<int, QByteArray> names;
    names[UriRole] = "uri";
    names[VersionRole] = "version";
    names[NameRole] = "name";
    names[ControllerClassIdRole] = "controller_class_id";
    names[TimestampRole] = "timestamp";
    names[Md5Role] = "md5";
    names[InstalledRole] = "installed";
    names[FilepathRole] = "filepath";

    return names;
}

int VersionedListModel::getLatestVersionIndex() {
    QStringList versions;
    for (VersionedItem *versionItem : data_) {
        versions.append(versionItem->version);
    }

    int latestVersionIndex = SGVersionUtils::getGreatestVersion(versions);

    return latestVersionIndex;
}

int VersionedListModel::getLatestVersionIndex(QString controllerClassId) {
    if (data_.size() == 0) {
        return -1;
    }
    int latestVersionIndex = -1;
    bool error = false;
    for (int i = 0; i < data_.size(); i++) {
        VersionedItem *versionItem = data_[i];
        if (versionItem->controller_class_id != controllerClassId) {
            continue;
        }
        if (latestVersionIndex < 0 || SGVersionUtils::greaterThan(versionItem->version, data_[latestVersionIndex]->version, &error)) {
            latestVersionIndex = i;
        }
        if (error) {
            return -1;
        }
    }
    return latestVersionIndex;
}

int VersionedListModel::getInstalledVersionIndex() {
    int oldestInstalledIndex = -1;

    for (int i = 0; i < data_.count(); i++) {
        if (data_[i]->installed && (oldestInstalledIndex == -1 || SGVersionUtils::greaterThan(data_[oldestInstalledIndex]->version, data_[i]->version))) {
            oldestInstalledIndex = i;
        }
    }
    return oldestInstalledIndex;
}

