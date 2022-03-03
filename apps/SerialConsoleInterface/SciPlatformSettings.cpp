/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "SciPlatformSettings.h"
#include "logging/LoggingQtCategories.h"

#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonValue>
#include <QDir>
#include <QStandardPaths>
#include <QSaveFile>


SciPlatformSettings::SciPlatformSettings(QObject *parent)
    : QObject(parent)
{
    QDir dir(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation));
    boardStoragePath_ = dir.filePath("platformSettings.data");

    loadData();
}

SciPlatformSettings::~SciPlatformSettings()
{
    qDeleteAll(settingsList_);
    settingsList_.clear();
    settingsHash_.clear();
}

SciPlatformSettingsItem *SciPlatformSettings::getBoardData(const QString &id) const
{
    return settingsHash_.value(id, nullptr);
}

void SciPlatformSettings::setCommandHistory(const QString &id, const QStringList &list)
{
    int index = findBoardIndex(id);
    settingsList_.at(index)->commandHistoryList = list;
    rearrangeAndSave(index);
}

void SciPlatformSettings::setExportPath(const QString &id, const QString &exportPath)
{
    int index = findBoardIndex(id);
    if (settingsList_.at(index)->exportPath == exportPath) {
        return;
    }

    settingsList_.at(index)->exportPath = exportPath;
    rearrangeAndSave(index);
}

void SciPlatformSettings::setAutoExportPath(const QString &id, const QString &autoExportPath)
{
    int index = findBoardIndex(id);
    if (settingsList_.at(index)->autoExportPath == autoExportPath) {
        return;
    }

    settingsList_.at(index)->autoExportPath = autoExportPath;
    rearrangeAndSave(index);
}

int SciPlatformSettings::findBoardIndex(const QString &id)
{
    int index = -1;
    for (int i = 0; i < settingsList_.length(); ++i) {
        if (settingsList_.at(i)->id == id) {
            index = i;
            break;
        }
    }

    if (index < 0) {
        SciPlatformSettingsItem *item = new SciPlatformSettingsItem();
        item->id = id;

        settingsList_.prepend(item);
        settingsHash_.insert(id, item);
        index = 0;
    }

    return index;
}

void SciPlatformSettings::rearrangeAndSave(int index)
{
    //sorted by last usage
    settingsList_.move(index, 0);
    saveData();
}

void SciPlatformSettings::loadData()
{
    if (QFile::exists(boardStoragePath_) == false) {
        return;
    }

    QFile file(boardStoragePath_);
    if (file.open(QFile::ReadOnly | QFile::Text) == false) {
        qCCritical(lcSci) << "cannot load data" << boardStoragePath_ << file.errorString();
        return;
    }

    QJsonParseError parseError;
    QJsonDocument doc =QJsonDocument::fromJson(file.readAll(), &parseError);

    if (parseError.error != QJsonParseError::NoError) {
        qCCritical(lcSci) << "cannot load data, json corrupted"
                   << "error=" << parseError.error
                   << parseError.errorString();
        return;
    }

    if (doc.isArray() == false) {
        qCCritical(lcSci) << "cannot load data, json is not an array";
        return;
    }

    for (const QJsonValueRef board : doc.array()) {
        if (settingsList_.length() > maxCount_) {
            break;
        }

        QString id = board.toObject().value(SCI_SETTINGS_ID).toString();

        if (id.isEmpty()) {
            qCCritical(lcSci) << "empty board identification";
            continue;
        }

        SciPlatformSettingsItem *item = new SciPlatformSettingsItem();
        item->id = id;
        item->commandHistoryList = board.toObject().value(SCI_SETTINGS_CMD_HISTORY).toVariant().toStringList();
        item->exportPath = board.toObject().value(SCI_EXPORT_PATH).toString();
        item->autoExportPath = board.toObject().value(SCI_AUTOEXPORT_PATH).toString();

        settingsList_.append(item);
        settingsHash_.insert(id, item);
    }
}

void SciPlatformSettings::saveData()
{
    QJsonDocument doc;
    QJsonArray boardList;

    for (const auto *item : settingsList_) {
        QJsonObject obj;
        obj.insert(SCI_SETTINGS_ID, item->id);
        obj.insert(SCI_SETTINGS_CMD_HISTORY, QJsonArray::fromStringList(item->commandHistoryList));
        obj.insert(SCI_EXPORT_PATH, item->exportPath);
        obj.insert(SCI_AUTOEXPORT_PATH, item->autoExportPath);

        boardList.append(obj);

        if (boardList.size() > maxCount_) {
            break;
        }
    }

    doc.setArray(boardList);

    QSaveFile file(boardStoragePath_);
    bool ret = file.open(QIODevice::WriteOnly | QIODevice::Text);
    if (ret == false) {
        qCCritical(lcSci) << "cannot open file" << boardStoragePath_ << file.errorString();
        return;
    }

    QTextStream out(&file);

    out << doc.toJson(QJsonDocument::Compact);

    bool comitted = file.commit();
    if (comitted == false) {
         qCCritical(lcSci) << "platform data were not saved";
    }
}
