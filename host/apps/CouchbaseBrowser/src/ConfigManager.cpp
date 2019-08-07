#include "ConfigManager.h"
#include "DatabaseImpl.h"

#include <QDir>
#include <QJsonArray>
#include <QStandardPaths>

using namespace std;

ConfigManager::ConfigManager() : cb_browser_("cb_browser_")
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

    if(DatabaseImpl::isJsonMsgSuccess(config_DB_->getMessage())) {
        qCInfo(cb_browser_) << "Opened existing config DB with path " << config_DB_abs_path.absolutePath();
        configRead();
    }
    // Config DB does not already exist in current path
    else {
        config_DB_->createNewDB(config_DB_folder_path_, "configDB");
        // Successfully created a new config DB
        if(DatabaseImpl::isJsonMsgSuccess(config_DB_->getMessage())) {
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
    // Read config DB
    QJsonDocument json_doc = QJsonDocument::fromJson(config_DB_->getJsonDBContents().toUtf8());

    if(json_doc.isNull() || json_doc.isEmpty()) {
        qCCritical(cb_browser_) << "Received empty or invalid JSON message for the Config DB.";
        return;
    }

    QJsonObject json_obj = json_doc.object();

    if(!json_obj.isEmpty()) {
        setConfigJson(config_DB_->getJsonDBContents());
    } else {
        setConfigJson("");
    }
}

bool ConfigManager::checkForSavedDB(const QString &db_name)
{
    if(!config_DB_ || !config_DB_->isDBOpen()) {
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
    if(!config_DB_ || !config_DB_->isDBOpen()) {
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

    QJsonObject temp_obj;
    temp_obj.insert("file_path", file_path);
    temp_obj.insert("url", "");
    temp_obj.insert("username", "");
    temp_obj.insert("rep_type","");
    QJsonDocument temp_doc(temp_obj);
    QString body = temp_doc.toJson(QJsonDocument::Compact);

    // If DB did not already exist, add to it
    config_DB_->createNewDoc(db_name,body);
    if(DatabaseImpl::isJsonMsgSuccess(config_DB_->getMessage())) {
        qCInfo(cb_browser_) << "Database with id '" << db_name << "' added to Config DB.";
        setConfigJson(config_DB_->getJsonDBContents());
        return;
    }

    qCCritical(cb_browser_) << "Unable to add database with id '" << db_name << "' to Config DB.";
}

bool ConfigManager::deleteConfigEntry(const QString &db_name)
{
    if(!config_DB_ || !config_DB_->isDBOpen()) {
        qCCritical(cb_browser_) << "Attempted to run Config DB operation, but the Config DB was not opened correctly.";
        return false;
    }

    config_DB_->deleteDoc(db_name);
    if(DatabaseImpl::isJsonMsgSuccess(config_DB_->getMessage())) {
        setConfigJson(config_DB_->getJsonDBContents());
        qCInfo(cb_browser_) << "Database '" << db_name << "' deleted from Config DB.";
        return true;
    }

    return false;
}

bool ConfigManager::clearConfig()
{
    if(!config_DB_ || !config_DB_->isDBOpen()) {
        qCCritical(cb_browser_) << "Attempted to run Config DB operation, but the Config DB was not opened correctly.";
        return false;
    }

    // Read config DB
    QJsonDocument json_doc = QJsonDocument::fromJson(config_DB_->getJsonDBContents().toUtf8());

    if(json_doc.isNull() || json_doc.isEmpty()) {
        qCCritical(cb_browser_) << "Received empty or invalid JSON message for the Config DB.";
        return false;
    }

    QJsonObject obj = json_doc.object();
    QStringList list = obj.keys();

    for(const QString &it : list) {
        if(!deleteConfigEntry(it)) {
            return false;
        }
    }

    return true;
}

void ConfigManager::addRepToConfigDB(const QString &db_name, const QString &url, const QString &username, const QString &rep_type, const vector<string> &channels)
{
    if(!config_DB_ || !config_DB_->isDBOpen()) {
        qCCritical(cb_browser_) << "Attempted to run Config DB operation, but the Config DB was not opened correctly.";
        return;
    }

    if(db_name.isEmpty()) {
        qCCritical(cb_browser_) << "Attempted to add replication information to Config DB, but received empty DB name.";
        return;
    }

    // Read config DB
    QJsonObject obj = QJsonDocument::fromJson(config_DB_->getJsonDBContents().toUtf8()).object();

    // Ensure that config DB contains the key
    if(!obj.contains(db_name)) {
        qCCritical(cb_browser_) << "Attempted to add replication information to Config DB with DB name '" << db_name << "', but key does not exist.";
        return;
    }

    // Separate the desired object and modify the contents of the keys
    QJsonObject obj2 = obj.value(db_name).toObject();

    if(!url.isEmpty()) {
        obj2.insert("url",url);
    }

    if(!username.isEmpty()) {
        obj2.insert("username",username);
    }

    if(!rep_type.isEmpty()) {
        obj2.insert("rep_type",rep_type);
    }

    // Add channels (if any) as a Json array
    if(!channels.empty()) {
        QJsonArray temp;
        for(const string &channel : channels) {
            temp.push_back(QString::fromStdString(channel));
        }
        obj2.insert("channels",temp);
    }

    QJsonDocument temp_doc(obj2);
    config_DB_->editDoc(db_name, "", temp_doc.toJson(QJsonDocument::Compact));
    setConfigJson(config_DB_->getJsonDBContents());
    qCInfo(cb_browser_) << "Added replicator information ('" << url << "','" << username << "','" << rep_type << "') to DB '" << db_name << "' of Config DB.";
}

void ConfigManager::deleteStaleConfigEntries()
{
    if(!config_DB_ || !config_DB_->isDBOpen()) {
        qCCritical(cb_browser_) << "Attempted to run Config DB operation, but the Config DB was not opened correctly.";
        return;
    }

    // Read config DB
    QJsonObject obj = QJsonDocument::fromJson(config_DB_->getJsonDBContents().toUtf8()).object();
    QStringList list = obj.keys();

    if(list.isEmpty()) {
        return;
    }

    QJsonObject obj2;
    QString path;

    for(const QString &db : list) {
        obj2 = obj.value(db).toObject();
        path = obj2.value("file_path").toString();
        QFileInfo file(path);

        if(!file.exists()) {
            qCInfo(cb_browser_) << "Database '" << db << "' found to no longer exist in local directory, removing from Config DB.";
            deleteConfigEntry(db);
        }
    }
}

QString ConfigManager::getConfigJson()
{
    if(!config_DB_ || !config_DB_->isDBOpen()) {
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
