#include "ConfigManager.h"
#include "DatabaseImpl.h"

#include <QDir>
#include <QJsonArray>
#include <QStandardPaths>

using namespace std;

ConfigManager::ConfigManager() : cb_browser_("cb_browser")
{
    // Initialize couchbase DB
    config_DB_ = make_unique<DatabaseImpl>(nullptr, false);
    config_DB_folder_path_ = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    config_DB_file_path_ = config_DB_folder_path_ + QDir::separator() + "db" + QDir::separator() + "configDB";

    configStart();
}

ConfigManager::~ConfigManager()
{
}

void ConfigManager::configStart()
{
    // Check if directory exists (or can be made), and if is readable and writable
    QDir config_DB_abs_path(config_DB_file_path_);
    config_DB_file_path_ += QDir::separator() + QString("db.sqlite3");
    config_DB_abs_path.setPath(config_DB_file_path_);
    qCInfo(cb_browser_) << "Config manager is looking for DB file in " << config_DB_abs_path.absolutePath();

    // Config DB already exists in current path
    config_DB_->openDB(config_DB_abs_path.absolutePath());

    if(config_DB_->getCurrentStatus() == MessageType::Success) {
        qCInfo(cb_browser_) << "Opened existing config DB with path " << config_DB_abs_path.absolutePath();
        configRead();
    }
    // Config DB does not already exist in current path
    else {
        config_DB_->createNewDB(config_DB_folder_path_, "configDB");
        // Successfully created a new config DB
        if(config_DB_->getCurrentStatus() == MessageType::Success) {
            qCInfo(cb_browser_) << "Created new config DB with path " << config_DB_abs_path.absolutePath();
        }
        // Failed to open or create a config DB
        else {
            qCCritical(cb_browser_) << "Failed to open or create a config DB at path " << config_DB_abs_path.absolutePath();
        }
    }
}

void ConfigManager::configRead()
{
    QString config_contents = config_DB_->getJsonDBContents();

    // Read config DB
    QJsonDocument json_doc = QJsonDocument::fromJson(config_contents.toUtf8());

    if(json_doc.isNull() || json_doc.isEmpty()) {
        qCCritical(cb_browser_) << "Received empty or invalid JSON message for the Config DB.";
        return;
    }

    QJsonObject json_obj = json_doc.object();

    if(!json_obj.isEmpty()) {
        setConfigJson(config_contents);
    } else {
        setConfigJson("");
    }
}

bool ConfigManager::checkForSavedDB(const QString &db_name)
{
    if(!configIsRunning()) {
        qCCritical(cb_browser_) << "Attempted to run Config DB operation, but the Config DB was not opened correctly.";
        return false;
    }

    // Read config DB
    QJsonDocument json_doc = QJsonDocument::fromJson(config_DB_->getJsonDBContents().toUtf8());

    if(json_doc.isNull() || json_doc.isEmpty()) {
        qCCritical(cb_browser_) << "Received empty or invalid JSON message for the Config DB.";
        return false;
    }

    QJsonObject json_obj = json_doc.object();
    return json_obj.contains(db_name);
}

void ConfigManager::addDBToConfig(const QString &db_name, const QString &file_path)
{
    if(!configIsRunning()) {
        qCCritical(cb_browser_) << "Attempted to run Config DB operation, but the Config DB was not opened correctly.";
        return;
    }

    if(db_name.isEmpty() || file_path.isEmpty()) {
        qCInfo(cb_browser_) << "Attempted to add DB to Config DB, but DB name and/or file path are empty.";
        return;
    }

    // Check if DB is already in config DB
    if(checkForSavedDB(db_name)) {
        qCInfo(cb_browser_) << "Database with id '" << db_name << "' already in Config DB.";
        return;
    }

    QJsonObject db_info;
    db_info.insert("file_path", file_path);
    db_info.insert("url", "");
    db_info.insert("username", "");
    db_info.insert("rep_type","");
    QJsonDocument db_contents_doc(db_info);
    QString db_contents = db_contents_doc.toJson();

    // If DB did not already exist, add to it
    config_DB_->createNewDoc(db_name, db_contents);
    if(config_DB_->getCurrentStatus() == MessageType::Success) {
        qCInfo(cb_browser_) << "Database with id '" << db_name << "' added to Config DB.";
        setConfigJson(config_DB_->getJsonDBContents());
        return;
    }

    qCCritical(cb_browser_) << "Unable to add database with id '" << db_name << "' to Config DB.";
}

bool ConfigManager::deleteConfigEntry(const QString &db_name)
{
    if(!configIsRunning()) {
        qCCritical(cb_browser_) << "Attempted to run Config DB operation, but the Config DB was not opened correctly.";
        return false;
    }

    config_DB_->deleteDoc(db_name);
    if(config_DB_->getCurrentStatus() == MessageType::Success) {
        setConfigJson(config_DB_->getJsonDBContents());
        qCInfo(cb_browser_) << "Database '" << db_name << "' deleted from Config DB.";
        return true;
    }

    return false;
}

bool ConfigManager::clearConfig()
{
    if(!configIsRunning()) {
        qCCritical(cb_browser_) << "Attempted to run Config DB operation, but the Config DB was not opened correctly.";
        return false;
    }

    // Read config DB
    QJsonDocument json_doc = QJsonDocument::fromJson(config_DB_->getJsonDBContents().toUtf8());

    if(json_doc.isNull() || json_doc.isEmpty()) {
        qCCritical(cb_browser_) << "Received empty or invalid JSON message for the Config DB.";
        return false;
    }

    QJsonObject json_obj = json_doc.object();

    for(const QString &key : json_obj.keys()) {
        if(!deleteConfigEntry(key)) {
            return false;
        }
    }

    return true;
}

void ConfigManager::addRepToConfigDB(const QString &db_name, const QString &url, const QString &username, const QString &rep_type, const vector<string> &channels)
{
    if(!configIsRunning()) {
        qCCritical(cb_browser_) << "Attempted to run Config DB operation, but the Config DB was not opened correctly.";
        return;
    }

    if(db_name.isEmpty()) {
        qCCritical(cb_browser_) << "Attempted to add replication information to Config DB, but received empty DB name.";
        return;
    }

    // Read config DB
    QJsonDocument json_doc = QJsonDocument::fromJson(config_DB_->getJsonDBContents().toUtf8());

    if(json_doc.isNull() || json_doc.isEmpty()) {
        qCCritical(cb_browser_) << "Received empty or invalid JSON message for the Config DB.";
        return;
    }

    QJsonObject json_obj = json_doc.object();

    // Ensure that config DB contains the key
    if(!json_obj.contains(db_name)) {
        qCCritical(cb_browser_) << "Attempted to add replication information to Config DB with DB name '" << db_name << "', but key does not exist.";
        return;
    }

    // Separate the desired object and modify the contents of the keys
    QJsonObject database_entry = json_obj.value(db_name).toObject();

    if(!url.isEmpty()) {
        database_entry.insert("url",url);
    }

    if(!username.isEmpty()) {
        database_entry.insert("username",username);
    }

    if(!rep_type.isEmpty()) {
        database_entry.insert("rep_type",rep_type);
    }

    // Add channels (if any) as a Json array
    if(!channels.empty()) {
        QJsonArray json_arr;
        for(const string &channel : channels) {
            json_arr.push_back(QString::fromStdString(channel));
        }
        database_entry.insert("channels", json_arr);
    }

    QJsonDocument database_doc(database_entry);
    config_DB_->editDoc(db_name, "", database_doc.toJson());
    setConfigJson(config_DB_->getJsonDBContents());
    qCInfo(cb_browser_) << "Added replicator information ('" << url << "','" << username << "','" << rep_type << "') to DB '" << db_name << "' of Config DB.";
}

void ConfigManager::deleteStaleConfigEntries()
{
    if(!configIsRunning()) {
        qCCritical(cb_browser_) << "Attempted to run Config DB operation, but the Config DB was not opened correctly.";
        return;
    }

    // Read config DB
    QJsonDocument json_doc = QJsonDocument::fromJson(config_DB_->getJsonDBContents().toUtf8());

    if(json_doc.isNull() || json_doc.isEmpty()) {
        qCCritical(cb_browser_) << "Received empty or invalid JSON message for the Config DB.";
        return;
    }

    QJsonObject json_obj = json_doc.object();
    QStringList db_entries = json_obj.keys();

    if(db_entries.isEmpty()) {
        return;
    }

    QString db_filepath;
    QJsonObject database_entry;

    for(const QString &db : db_entries) {
        database_entry = json_obj.value(db).toObject();
        db_filepath = database_entry.value("file_path").toString();
        QFileInfo file(db_filepath);

        if(!file.exists()) {
            qCInfo(cb_browser_) << "Database '" << db << "' found to no longer exist in local directory, removing from Config DB.";
            deleteConfigEntry(db);
        }
    }
}

QString ConfigManager::getConfigJson()
{
    if(!configIsRunning()) {
        qCCritical(cb_browser_) << "Attempted to run Config DB operation, but the Config DB was not opened correctly.";
        return "{}";
    }

    deleteStaleConfigEntries();
    return config_DB_Json_.isEmpty() ? "{}" : config_DB_Json_;
}

void ConfigManager::setConfigJson(const QString &msg)
{
    config_DB_Json_ = msg;
}

bool ConfigManager::configIsRunning()
{
    return config_DB_ && config_DB_->isDBOpen();
}
