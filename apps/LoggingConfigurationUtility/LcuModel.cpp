/***************************************************************************
 *                                                                         *
 *   Copyright (C) 2021 by ONsemiconductor     *
 *                                                                         *
 *   http://onsemi.com                                          *
 *                                                                         *
 ***************************************************************************/
#include "LcuModel.h"
#include "IniFiles.h"
#include "logging/LoggingQtCategories.h"

#include <QCoreApplication>
#include <QSettings>
#include <QFileInfo>
#include <QDir>

LcuModel::LcuModel(QObject *parent)
    : QAbstractItemModel(parent)
{
    QSettings settings;
    QFileInfo fileInfo(settings.fileName());
    QDir directory(fileInfo.absolutePath());
    iniFiles_ = directory.entryList({"*.ini"},QDir::Files);
    if (iniFiles_.empty())
    {
        qCWarning(lcLcu()) << "No ini files were found.";
    }
}

QModelIndex LcuModel::index(int row, int column, const QModelIndex &parent) const
{
    // FIXME: Implement me!
}

QModelIndex LcuModel::parent(const QModelIndex &index) const
{
    // FIXME: Implement me!
}

int LcuModel::rowCount(const QModelIndex & parent) const {

    //return list_->items().size();
    return iniFiles_.count();
 }

int LcuModel::columnCount(const QModelIndex &parent) const
{
    return 1;
}

QVariant LcuModel::data(const QModelIndex & index, int role) const
{
    if (index.isValid() || !list_)
        return QVariant();

    //QString item = list_->items().at(index.row());
    QString item = iniFiles_.at( index.row() );
    QVariant value;
        switch ( role )
        {
            case Qt::DisplayRole:
            {
                value = item;
            }
            break;
            case Qt::UserRole:
            {
                value = item;
            }
            break;
            default:
                break;
        }
        return value;
}

/*
bool LcuModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if(!list_)
        return false;
    QString item = list_->items().at(index.row());
    switch (role) {
    case DescriptionRole:
        item = value.toString();
    }

    if(list_->setItemAt(index.row(),item)){
        emit dataChanged(index,index,QVector<int>() << role);
        return true;
    }
    return false;
}*/

IniFiles *LcuModel::list() const
{
    return list_;
}

void LcuModel::setList(IniFiles *list)
{
    beginResetModel();
    if(list_)
    {
        list_->disconnect(this);
    }
    list_ = list;
    if(list_)
    {
        connect(list_, &IniFiles::preItemAppanded,this,[=]()
        {
            const int index = list->items().size();
            beginInsertRows(QModelIndex(),index,index);
        });
        connect(list_, &IniFiles::postItemAppended,this,[=]()
        {
            endInsertRows();
        });
    }
    endResetModel();
}
