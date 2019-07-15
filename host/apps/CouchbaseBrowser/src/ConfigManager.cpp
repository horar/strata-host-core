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
    if(isJsonMsgSuccess(config_DB_->openDB(config_DB_abs_path.absolutePath()))) {
        qCInfo(cb_browser) << "Opened existing config DB with path " << config_DB_abs_path.absolutePath();
    }
    // Config DB does not already exist in current path
    else if(isJsonMsgSuccess(config_DB_->createNewDB(QDir::currentPath(), "configDB"))) {
        cout << "\nThe current path is " << QDir::currentPath().toStdString() << endl;
        qCInfo(cb_browser) << "Created new config DB with path " << QDir::currentPath();
    }
    // Failed to open or create a config DB
    else {
        qCCritical(cb_browser) << "Failed to open or create a config DB at path " << QDir::currentPath();
        return;
    }
}
