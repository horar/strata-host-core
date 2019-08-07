#ifndef CONFIGMANAGER_H
#define CONFIGMANAGER_H

#include <QObject>
#include <QJsonDocument>
#include <QJsonObject>
#include <QLoggingCategory>

class DatabaseImpl;

class ConfigManager
{
public:
    ConfigManager();

    ~ConfigManager();

    QString getConfigJson();

    void addDBToConfig(const QString &db_name, const QString &file_path);

    void addRepToConfigDB(const QString &db_name, const QString &url = "",const QString &username = "",
        const QString &rep_type = "", const std::vector<std::string> &channels = std::vector<std::string> ());

    bool deleteConfigEntry(const QString &db_name);

    bool clearConfig();

private:
    std::unique_ptr<DatabaseImpl> config_DB_ = nullptr;

    QLoggingCategory cb_browser_;

    QString config_DB_Json_, config_DB_folder_path_, config_DB_file_path_;

    void configStart();

    void configRead();

    void setConfigJson(const QString &msg);

    void deleteStaleConfigEntries();

    bool checkForSavedDB(const QString &db_name);
};

#endif // CONFIGMANAGER_H
