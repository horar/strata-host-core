#pragma once

#include "CouchbaseDatabase.h"

#include <vector>

class DatabaseAccess;

class DatabaseManager
{
public:
    DatabaseAccess* open(const QString &name, const QString &channel_access = "");

    DatabaseAccess* open(const QString &name, const QStringList &channel_access);

    QString getDbDirName();

private:
    const QString dbDirName_ = "databases";

    DatabaseAccess *dbAccess_ = nullptr;

    QString manageUserDir(const QString &name, const QStringList &channel_access);
};

class DatabaseAccess
{
    friend class DatabaseManager;

public:
    bool close();

    bool write(CouchbaseDocument *doc, const QString &bucket = "");

    bool write(CouchbaseDocument *doc, const QStringList &buckets);

    bool deleteDoc(const QString &id, const QString &bucket = "");

    QString getDocumentAsStr(const QString &id, const QString &bucket = "");

    QJsonObject getDocumentAsJsonObj(const QString &id, const QString &bucket = "");

    QJsonObject getDatabaseAsJsonObj(const QString &bucket = "");

    QString getDatabaseName();

    QString getDatabasePath();

    QStringList getAllDocumentKeys(const QString &bucket);

    void clearUserDir(const QString &userName, const QString &dbDirName);

    /********************************************
     * REPLICATOR API *
     *******************************************/

    /**
     * Initializes and starts the DB replicator
     * @param url replicator / sync-gateway URL to connect to
     * @param username sync-gateway username (optional, default to empty)
     * @param password sync-gateway password (optional, default to empty)
     * @param replicator_type push/pull/push and pull (optional, default to pull only)
     * @param changeListener function handle (optional, default is used)
     * @param documentListener function handle (optional, default is used)
     * @param continuous replicator continuous (optional, default to one-shot)
     * @return true when succeeded, otherwise false
     */
    bool startReplicator(const QString &url,
                         const QString &username = "",
                         const QString &password = "",
                         const QString &replicator_type = "",
                         std::function<void(cbl::Replicator rep, const CBLReplicatorStatus &status)> changeListener = nullptr,
                         std::function<void(cbl::Replicator rep, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents)> documentListener = nullptr,
                         bool continuous = false);

    void stopReplicator();

    QString getReplicatorStatus(const QString &bucket = "");

    int getReplicatorError(const QString &bucket = "");

private:
    QString name_, user_directory_;

    QStringList channel_access_;

    std::vector<std::unique_ptr<CouchbaseDatabase>> database_map_;

    CouchbaseDatabase* getBucket(const QString &bucketName);

    std::function<void(cbl::Replicator rep, const CBLReplicatorStatus &status)> change_listener_callback = nullptr;

    std::function<void(cbl::Replicator, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents)> document_listener_callback = nullptr;

    void default_changeListener(cbl::Replicator, const CBLReplicatorStatus &status);

    void default_documentListener(cbl::Replicator, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents);
};
