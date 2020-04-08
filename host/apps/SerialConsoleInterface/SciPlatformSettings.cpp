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

    settingsList_.at(index)->commandHistoryList = list;

    //sorted by last usage
    settingsList_.move(index, 0);

    bool saved = saveData();
    if (saved == false) {
        qCCritical(logCategorySci) << "platform data were not saved";
    }
}

void SciPlatformSettings::loadData()
{
    QFile file(boardStoragePath_);
    if (file.open(QFile::ReadOnly | QFile::Text) == false) {
        qCCritical(logCategorySci) << "cannot load data" << boardStoragePath_ << file.errorString();
        return;
    }

    QJsonParseError parseError;
    QJsonDocument doc =QJsonDocument::fromJson(file.readAll(), &parseError);

    if (parseError.error != QJsonParseError::NoError) {
        qCCritical(logCategorySci) << "cannot load data, json corrupted"
                   << "error=" << parseError.error
                   << parseError.errorString();
        return;
    }

    if (doc.isArray() == false) {
        qCCritical(logCategorySci) << "cannot load data, json is not an array";
        return;
    }

    for (const QJsonValue &board : doc.array()) {
        if (settingsList_.length() > maxCount_) {
            break;
        }

        QString id = board.toObject().value(SCI_SETTINGS_ID).toString();
        QStringList commandHistoryList = board.toObject().value(SCI_SETTINGS_CMD_HISTORY).toVariant().toStringList();

        if (id.isEmpty()) {
            qCCritical(logCategorySci) << "empty board identification";
            continue;
        }

        SciPlatformSettingsItem *item = new SciPlatformSettingsItem();
        item->id = id;
        item->commandHistoryList = commandHistoryList;

        settingsList_.append(item);
        settingsHash_.insert(id, item);
    }
}

bool SciPlatformSettings::saveData()
{
    QJsonDocument doc;
    QJsonArray boardList;

    for (const auto *item : settingsList_) {
        QJsonObject obj;
        obj.insert(SCI_SETTINGS_ID, item->id);
        obj.insert(SCI_SETTINGS_CMD_HISTORY, QJsonArray::fromStringList(item->commandHistoryList));

        boardList.append(obj);

        if (boardList.size() > maxCount_) {
            break;
        }
    }

    doc.setArray(boardList);

    QSaveFile file(boardStoragePath_);
    bool ret = file.open(QIODevice::WriteOnly | QIODevice::Text);
    if (ret == false) {
        qCCritical(logCategorySci) << "cannot open file" << boardStoragePath_ << file.errorString();
        return false;
    }

    QTextStream out(&file);

    out << doc.toJson(QJsonDocument::Compact);

    return file.commit();
}
