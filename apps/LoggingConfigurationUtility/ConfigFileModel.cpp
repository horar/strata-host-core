/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "ConfigFileModel.h"
#include "logging/LoggingQtCategories.h"

#include <QCoreApplication>
#include <QSettings>
#include <QFileInfo>
#include <QDir>

ConfigFileModel::ConfigFileModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

void ConfigFileModel::addItem(const QFileInfo fileInfo)
{
    beginInsertRows(QModelIndex(), rowCount(), rowCount());
    iniFiles_ << fileInfo;
    endInsertRows();

    emit countChanged();
}

void ConfigFileModel::reload()
{
    QSettings settings;
    QFileInfo fileInfo(settings.fileName());
    QDir directory(fileInfo.absolutePath());
    qCDebug(lcLcu) << "Reading files from: " + fileInfo.absolutePath();

    beginResetModel();
    iniFiles_ = directory.entryInfoList({"*.ini"},QDir::Files);
    endResetModel();

    if (iniFiles_.empty()) {
        qCWarning(lcLcu) << "No ini files were found.";
    }

    //TODO in different ticket - when list of files is reloaded and its count changes, set current index on the file which was opened before reloading. If the file doesn't exist any more, set index to 0.
    emit countChanged();
}

QVariantMap ConfigFileModel::get(int index)
{
    if (index < 0 || index >= iniFiles_.count()) {
        return QVariantMap();
    }

    QFileInfo item = iniFiles_.at(index);
    QVariantMap map;
    map.insert("fileName", item.fileName());
    map.insert("filePath", item.absoluteFilePath());
    return map;
}

int ConfigFileModel::rowCount(const QModelIndex & parent) const
{
    Q_UNUSED(parent)
    return iniFiles_.count();
}

QVariant ConfigFileModel::data(const QModelIndex & index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= iniFiles_.count()) {
        qCCritical(lcLcu) << "Index out of range";
        return QVariant();
    }

    switch (role) {
    case FileNameRole:
        return iniFiles_.at( index.row() ).fileName();
    case FilePathRole:
        return iniFiles_.at( index.row() ).absoluteFilePath();
    }

    return QVariant();
}

int ConfigFileModel::count() const
{
    return iniFiles_.count();
}

QHash<int, QByteArray> ConfigFileModel::roleNames() const
{
    QHash<int, QByteArray> names;
    names[FileNameRole] = "fileName";
    names[FilePathRole] = "filePath";
    return names;
}
