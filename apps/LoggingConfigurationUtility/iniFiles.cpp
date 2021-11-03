/***************************************************************************
 *                                                                         *
 *   Copyright (C) 2021 by ONsemiconductor     *
 *                                                                         *
 *   http://onsemi.com                                          *
 *                                                                         *
 ***************************************************************************/
#include "IniFiles.h"
#include "logging/LoggingQtCategories.h"

#include <QStringList>
#include <QSettings>
#include <QFileInfo>
#include <QDir>

IniFiles::IniFiles(QObject *parent) : QObject(parent)
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

QStringList IniFiles::items()
{
    return iniFiles_;
}


bool IniFiles::setItemAt(int index, QString item)
{
    if(index < 0 || index >= iniFiles_.size())
    {
        return false;
    }
    QString oldItem = iniFiles_.at(index);
    if(item == oldItem)
    {
        return false;
    }
    iniFiles_[index] = item;
    return true;
}

void IniFiles::appendItem()
{
    emit preItemAppanded();

    QString item;
    iniFiles_.append(item);

    emit postItemAppended();
}
