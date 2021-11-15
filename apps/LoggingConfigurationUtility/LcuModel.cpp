/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "LcuModel.h"
#include "logging/LoggingQtCategories.h"

#include <QCoreApplication>
#include <QSettings>
#include <QFileInfo>
#include <QDir>

LcuModel::LcuModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

void LcuModel::addItem(const QString fileName)
{
     beginInsertRows(QModelIndex(), rowCount(), rowCount());
     iniFiles_ << fileName;
     endInsertRows();
}

void LcuModel::reload()
{
    QSettings settings;
    QFileInfo fileInfo(settings.fileName());
    QDir directory(fileInfo.absolutePath());
    qCDebug(lcLcu) << "Reading files from: " + fileInfo.absolutePath();

    beginResetModel();
    iniFiles_ = directory.entryList({"*.ini"},QDir::Files);
    for(int i=0; i<iniFiles_.size(); i++) {
        iniFilesPath_ << fileInfo.absolutePath() + "/" + iniFiles_.at(i);
    }
    endResetModel();

    if (iniFiles_.empty()) {
        qCWarning(lcLcu) << "No ini files were found.";
    }
}

int LcuModel::rowCount(const QModelIndex & parent) const
{
    Q_UNUSED(parent)
    return iniFiles_.count();
}

QVariant LcuModel::data(const QModelIndex & index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= iniFiles_.count()) {
        return QVariant();
    }

    switch (role) {
    case textRole:
        return iniFiles_.at( index.row() );
    case FilePathRole:
        return iniFilesPath_.at( index.row() );
    }

    return QVariant();
}

int LcuModel::count() const
{
    return iniFiles_.count();
}

QHash<int, QByteArray> LcuModel::roleNames() const
{
    QHash<int, QByteArray> names;
    names[textRole] = "fileName";
    names[FilePathRole] = "filePath";
    return names;
}
