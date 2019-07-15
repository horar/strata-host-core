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

private:
    DatabaseImpl *config_DB_{nullptr};

    QLoggingCategory cb_browser;

    bool isJsonMsgSuccess(const QString &msg)
    {
        QJsonObject obj = QJsonDocument::fromJson(msg.toUtf8()).object();
        return obj.value("status").toString() == "success";
    }

};

#endif // CONFIGMANAGER_H
