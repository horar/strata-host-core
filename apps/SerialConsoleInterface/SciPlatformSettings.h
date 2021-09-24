/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QObject>
#include <QHash>

const QString SCI_SETTINGS_ID("id");
const QString SCI_SETTINGS_CMD_HISTORY("commandHistory");
const QString SCI_EXPORT_PATH("exportPath");
const QString SCI_AUTOEXPORT_PATH("autoExportPath");

struct SciPlatformSettingsItem {
    QString id;
    QStringList commandHistoryList;
    QString exportPath;
    QString autoExportPath;
};

class SciPlatformSettings: public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SciPlatformSettings)

public:
    explicit SciPlatformSettings(QObject *parent = nullptr);
    ~SciPlatformSettings() override;

    SciPlatformSettingsItem* getBoardData(const QString &id) const;
    void setCommandHistory(const QString &id, const QStringList &list);
    void setExportPath(const QString &id, const QString &exportPath);
    void setAutoExportPath(const QString &id, const QString &autoExportPath);

private:
    QString boardStoragePath_;
    QList<SciPlatformSettingsItem*> settingsList_;
    QHash<QString /*board identificator*/, SciPlatformSettingsItem*> settingsHash_;
    const int maxCount_ = 30;

    int findBoardIndex(const QString &id);
    void rearrangeAndSave(int index);
    void loadData();
    void saveData();
};
