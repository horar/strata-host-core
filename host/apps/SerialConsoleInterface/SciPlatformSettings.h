#ifndef SCI_PLATFORM_SETTINGS_H
#define SCI_PLATFORM_SETTINGS_H

#include <QObject>
#include <QHash>

const QString SCI_SETTINGS_ID("id");
const QString SCI_SETTINGS_CMD_HISTORY("commandHistory");

struct SciPlatformSettingsItem {
    QString id;
    QStringList commandHistoryList;
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

private:
    QString boardStoragePath_;
    QList<SciPlatformSettingsItem*> settingsList_;
    QHash<QString /*board identificator*/, SciPlatformSettingsItem*> settingsHash_;
    const int maxCount_ = 30;

    void loadData();
    bool saveData();
};

#endif //SCI_PLATFORM_SETTINGS_H
