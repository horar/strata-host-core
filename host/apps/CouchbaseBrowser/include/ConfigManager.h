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

    QString getConfigJson();

    void addDBToConfig(QString db_name, QString file_path);

    void addRepToConfigDB(const QString &url,const QString &username,const QString &rep_type);

    bool deleteConfigEntry(const QString &db_name);

    bool clearConfig();

private:
    DatabaseImpl *config_DB_{nullptr};

    QLoggingCategory cb_browser;

    QString config_DB_Json_;

    void setConfigJson(const QString &msg);

    bool checkForSavedDB(const QString &db_name);

    bool isJsonMsgSuccess(const QString &msg)
    {
        QJsonObject obj = QJsonDocument::fromJson(msg.toUtf8()).object();
        return obj.value("status").toString() == "success";
    }

};

#endif // CONFIGMANAGER_H
