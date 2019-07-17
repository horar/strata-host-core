#include "ConfigManager.h"
#include "DatabaseImpl.h"

#include <iostream>
#include <QDir>

using namespace std;

ConfigManager::ConfigManager() : cb_browser("cb_browser")
{
    // Initialize couchbase DB
    config_DB_ = new DatabaseImpl(nullptr,false);

    // Verify if config DB already exists in current path
    QDir config_DB_abs_path;
    config_DB_abs_path.setPath(QDir::currentPath() + config_DB_abs_path.separator() + "db" + config_DB_abs_path.separator() + "configDB" + config_DB_abs_path.separator() + "db.sqlite3");
    qCInfo(cb_browser) << "Config manager is looking for DB file in " << config_DB_abs_path.absolutePath();

    // Config DB already exists in current path
    config_DB_->openDB(config_DB_abs_path.absolutePath());
    if(isJsonMsgSuccess(config_DB_->getMessage())) {
        qCInfo(cb_browser) << "Opened existing config DB with path " << config_DB_abs_path.absolutePath();
    }
    // Config DB does not already exist in current path
    else {
        config_DB_->createNewDB(QDir::currentPath(), "configDB");
        if(isJsonMsgSuccess(config_DB_->getMessage())) {
            qCInfo(cb_browser) << "Created new config DB with path " << QDir::currentPath();
        }
    // Failed to open or create a config DB
        else {
            qCCritical(cb_browser) << "Failed to open or create a config DB at path " << QDir::currentPath();
            return;
        }
    }

    // Read config DB
    QJsonObject obj = QJsonDocument::fromJson(config_DB_->getJsonDBContents().toUtf8()).object();

    if(!obj.isEmpty()) {
        setConfigJson(config_DB_->getJsonDBContents());
    } else {
        setConfigJson("");
    }
}

bool ConfigManager::checkForSavedDB(const QString &db_name)
{
    // Read config DB
    QJsonObject obj = QJsonDocument::fromJson(config_DB_->getJsonDBContents().toUtf8()).object();
    return obj.contains(db_name);
}

void ConfigManager::addDBToConfig(QString db_name, QString file_path)
{
    if(db_name.isEmpty() || file_path.isEmpty()) {
        qCInfo(cb_browser) << "Attempted to add DB to Config DB, but DB name and/or file path are empty.";
        return;
    }

    // Check if DB is already in config DB
    if(checkForSavedDB(db_name)) {
        qCInfo(cb_browser) << "Database with id '" << db_name << "' already in Config DB.";
        return;
    }

    QJsonObject temp_obj;
    temp_obj.insert("file_path", file_path);
    temp_obj.insert("url", "");
    temp_obj.insert("username", "");
    temp_obj.insert("rep_type","");
    QJsonDocument temp_doc(temp_obj);
    QString body = temp_doc.toJson(QJsonDocument::Compact);

    // If DB did not already exist, add to it
    config_DB_->createNewDoc(db_name,body);
    if(isJsonMsgSuccess(config_DB_->getMessage())) {
        qCInfo(cb_browser) << "Database with id '" << db_name << "' added to Config DB.";
        setConfigJson(config_DB_->getJsonDBContents());
        return;
    }

    qCCritical(cb_browser) << "Unable to add database with id '" << db_name << "' to Config DB.";
}

bool ConfigManager::deleteConfigEntry(const QString &db_name)
{
    config_DB_->deleteDoc(db_name);
    if(isJsonMsgSuccess(config_DB_->getMessage())) {
        setConfigJson(config_DB_->getJsonDBContents());
        qCInfo(cb_browser) << "Database '" << db_name << "' deleted from Config DB.";
        return true;
    }

    return false;
}

bool ConfigManager::clearConfig()
{
    // Read config DB
    QJsonObject obj = QJsonDocument::fromJson(config_DB_->getJsonDBContents().toUtf8()).object();
    QStringList list = obj.keys();

    for(QString it : list) {
        if(!deleteConfigEntry(it)) {
            return false;
        }
    }

    return true;
}

void ConfigManager::addRepToConfigDB(const QString &db_name, const QString &url, const QString &username, const QString &rep_type)
{
    // Read config DB
    QJsonObject obj = QJsonDocument::fromJson(config_DB_->getJsonDBContents().toUtf8()).object();

    // Ensure that config DB contains the key
    if(!obj.contains(db_name)) {
        qCCritical(cb_browser) << "Attempted to add replication information to Config DB with DB name '" << db_name << "', but key does not exist.";
        return;
    }

    // Separate the desired object and modify the contents of the keys
    QJsonObject obj2 = obj.value(db_name).toObject();
    obj2.insert("url",url);
    obj2.insert("username",username);
    obj2.insert("rep_type",rep_type);
    QJsonDocument temp_doc(obj2);
    config_DB_->editDoc(db_name, "", temp_doc.toJson(QJsonDocument::Compact));
    setConfigJson(config_DB_->getJsonDBContents());
    qCInfo(cb_browser) << "Added replicator information (" << url << "," << username << "," << rep_type << ") to DB '" << db_name << "' of Config DB.";
}

QString ConfigManager::getConfigJson()
{
    return config_DB_Json_.isEmpty() ? "{}" : config_DB_Json_;
}

void ConfigManager::setConfigJson(const QString &msg)
{
    config_DB_Json_ = msg;
}
