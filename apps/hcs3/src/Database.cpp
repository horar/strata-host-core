/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "Database.h"

#include "logging/LoggingQtCategories.h"

#include <Database/DatabaseManager.h>
#include <string>

#include <QDir>

using namespace strata::Database;

Database::Database(QObject *parent)
    : QObject(parent)
{
    qRegisterMetaType<Database::ReplicatorActivity>("ReplicatorActivity");
    qRegisterMetaType<Database::ErrorDomain>("ErrorDomain");
}

Database::~Database()
{
    stop();
}

bool Database::open(const QString& db_path, const QString& db_name)
{
    if (DB_ != nullptr) {
        return false;
    }

    if (db_name.isEmpty()) {
        qCCritical(lcHcsDb) << "Missing valid DB name";
        return false;
    }

    if (db_path.isEmpty()) {
        qCCritical(lcHcsDb) << "Missing writable DB location path";
        return false;
    }

    databaseName_ = db_name;
    databasePath_ = db_path;
    qCDebug(lcHcsDb) << "DB location set to:" << databasePath_;

    // Check if directories/files already exist
    // If 'db' and 'strata_db' (db_name) directories exist but the main DB file does not, remove directory 'strata_db' (db_name) to avoid bug with opening DB
    // Directory will be re-created when DB is opened
    QDir db_directory{databasePath_};
    if (db_directory.cd(QString("%1.cblite2").arg(db_name)) && !db_directory.exists(QStringLiteral("db.sqlite3"))) {
        if (db_directory.removeRecursively()) {
            qCInfo(lcHcsDb)
                << "DB directories exist but DB file does not -- successfully deleted directory"
                << db_directory.absolutePath();
        } else {
            qCWarning(lcHcsDb)
                << "DB directories exist but DB file does not -- unable to delete directory"
                << db_directory.absolutePath();
        }
    }

    // Opening the db
    DB_ = std::make_unique<DatabaseAccess>();

    if (DB_->open(databaseName_, databasePath_, databaseChannels_) == false) {
        qCCritical(lcHcsDb) << "Failed to open database";
        return false;
    }

    return true;
}

void Database::documentListener(bool isPush, const std::vector<DatabaseAccess::ReplicatedDocument, std::allocator<DatabaseAccess::ReplicatedDocument>>& documents)
{
    qCInfo(lcHcsDb) << "---" << documents.size() << "docs" << (isPush ? "pushed" : "pulled");
    for (unsigned i = 0; i < documents.size(); ++i) {
        emit documentUpdated(documents[i].id);
    }
}

void Database::changeListener(strata::Database::DatabaseAccess::ActivityLevel activityLevel, int errorCode, strata::Database::DatabaseAccess::ErrorCodeDomain domain)
{
    qCInfo(lcHcsDb) << "--- PROGRESS: status =" << strata::Database::DatabaseAccess::activityLevelToString(activityLevel);
    if (errorCode != 0) {
        qCInfo(lcHcsDb) << "--- ERROR: code =" << errorCode << "domain =" << static_cast<int>(domain);
    }

    ReplicatorActivity activity;
    ErrorDomain errorDomain;

    switch (activityLevel) {
    case strata::Database::DatabaseAccess::ActivityLevel::ReplicatorStopped :
        activity = ReplicatorActivity::Stopped;
        break;
    case strata::Database::DatabaseAccess::ActivityLevel::ReplicatorOffline :
        activity = ReplicatorActivity::Offline;
        break;
    case strata::Database::DatabaseAccess::ActivityLevel::ReplicatorConnecting :
        activity = ReplicatorActivity::Connecting;
        break;
    case strata::Database::DatabaseAccess::ActivityLevel::ReplicatorIdle :
        activity = ReplicatorActivity::Idle;
        break;
    case strata::Database::DatabaseAccess::ActivityLevel::ReplicatorBusy :
        activity = ReplicatorActivity::Busy;
        break;
    }

    switch (domain) {
    case strata::Database::DatabaseAccess::ErrorCodeDomain::NoDomain :
        errorDomain = ErrorDomain::NoDomain;
        break;
    case strata::Database::DatabaseAccess::ErrorCodeDomain::CouchbaseLiteDomain :
        errorDomain = ErrorDomain::CouchbaseLite;
        break;
    case strata::Database::DatabaseAccess::ErrorCodeDomain::PosixDomain :
        errorDomain = ErrorDomain::Posix;
        break;
    case strata::Database::DatabaseAccess::ErrorCodeDomain::SQLiteDomain :
        errorDomain = ErrorDomain::SQLite;
        break;
    case strata::Database::DatabaseAccess::ErrorCodeDomain::FleeceDomain :
        errorDomain = ErrorDomain::Fleece;
        break;
    case strata::Database::DatabaseAccess::ErrorCodeDomain::NetworkDomain :
        errorDomain = ErrorDomain::Network;
        break;
    case strata::Database::DatabaseAccess::ErrorCodeDomain::WebSocketDomain :
        errorDomain = ErrorDomain::WebSocket;
        break;
    }

    emit replicatorStatusChanged(activity, errorCode, errorDomain);
}

bool Database::addReplChannel(const QString& channel)
{
    if (channel.isEmpty()) {
        return false;
    }

    if (databaseChannels_.contains(channel) == false) {
        databaseChannels_ << channel;
        updateChannels();
    }

    return true;
}

bool Database::remReplChannel(const QString& channel)
{
    if (channel.isEmpty()) {
        return false;
    }

    if (databaseChannels_.contains(channel)) {
        databaseChannels_.removeAll(channel);
        updateChannels();
    }

    return true;
}

void Database::updateChannels()
{
    if (DB_ == nullptr) {
        return;
    }

    DB_->close();

    if (DB_->open(databaseName_, databasePath_, databaseChannels_) == false) {
        qCCritical(lcHcsDb) << "Failed to open database";
        return;
    }

    if (isRunning_) {
        auto documentListenerCallback = std::bind(&Database::documentListener, this, std::placeholders::_1, std::placeholders::_2);
        isRunning_ = DB_->startBasicReplicator(replication_.url, replication_.username, replication_.password, DatabaseAccess::ReplicatorType::Pull, nullptr, documentListenerCallback, true);
    }
}

bool Database::getDocument(const QString& doc_id, QString& result)
{
    if (DB_ == nullptr) {
        return false;
    }

    result = DB_->getDocumentAsStr(doc_id, DB_->getDatabaseName());

    return true;
}

void Database::stop()
{
    if (DB_ == nullptr) {
        return;
    }

    DB_->close();

    DB_ = nullptr;
    isRunning_ = false;
}

bool Database::initReplicator(const QString& replUrl, const QString& username, const QString& password)
{
    replication_.url = replUrl;
    replication_.username = username;
    replication_.password = password;

    auto changeListenerCallback = std::bind(&Database::changeListener, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3);
    auto documentListenerCallback = std::bind(&Database::documentListener, this, std::placeholders::_1, std::placeholders::_2);
    isRunning_ = DB_->startBasicReplicator(replication_.url, replication_.username, replication_.password, DatabaseAccess::ReplicatorType::Pull, changeListenerCallback, documentListenerCallback, true);

    return isRunning_;
}
