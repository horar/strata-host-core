#pragma once

#include "../src/CouchbaseDatabase.h"

#include <vector>

class DatabaseAccess
{
    friend class DatabaseManager;

public:
    DatabaseAccess();

    ~DatabaseAccess();

    DatabaseAccess& operator=(const DatabaseAccess&) = delete;

    DatabaseAccess(const DatabaseAccess&) = delete;

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

    bool joinChannel(const QString &loginUsername, const QString &channel);

    bool leaveChannel(const QString &loginUsername, const QString &channel);

    /********************************************
     * REPLICATOR API *
     *******************************************/

    enum class ReplicatorType {
        Pull,
        Push,
        PushAndPull
    };

    /**
     * Initializes and starts the DB replicator
     * @param url replicator / sync-gateway URL to connect to
     * @param token sync-gateway authentication token
     * @param cookieName sync-gateway authentication cookie name
     * @param channels replication channels (optional)
     * @param type push/pull/push and pull (optional)
     * @param conflict_resolution_policy default behavior or always resolve to remote revision (optional)
     * @param reconnection_policy default behavior or automatically try to reconnect (optional)
     * @return true when succeeded, otherwise false
     */
    bool startSessionReplicator(const QString &url,
                         const QString &token = "",
                         const QString &cookieName = "",
                         const ReplicatorType &replicatorType = ReplicatorType::Pull,
                         std::function<void(cbl::Replicator rep, const CBLReplicatorStatus &status)> changeListener = nullptr,
                         std::function<void(cbl::Replicator rep, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents)> documentListener = nullptr,
                         bool continuous = false);

    /**
     * Initializes and starts the DB replicator
     * @param url replicator / sync-gateway URL to connect to
     * @param username sync-gateway username (optional, default to empty)
     * @param password sync-gateway password (optional, default to empty)
     * @param replicatorType push/pull/push and pull (optional, default to pull only)
     * @param changeListener function handle (optional, default is used)
     * @param documentListener function handle (optional, default is used)
     * @param continuous replicator continuous (optional, default to one-shot)
     * @return true when succeeded, otherwise false
     */
    bool startBasicReplicator(const QString &url,
                         const QString &username = "",
                         const QString &password = "",
                         const ReplicatorType &replicatorType = ReplicatorType::Pull,
                         std::function<void(cbl::Replicator rep, const CBLReplicatorStatus &status)> changeListener = nullptr,
                         std::function<void(cbl::Replicator rep, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents)> documentListener = nullptr,
                         bool continuous = false);

    void stopReplicator();

    QString getReplicatorStatus(const QString &bucket = "");

    int getReplicatorError(const QString &bucket = "");

private:
    QString name_;

    QString user_directory_;

    QStringList channelAccess_;

    std::vector<std::unique_ptr<CouchbaseDatabase>> database_map_;

    std::function<void(cbl::Replicator rep, const CBLReplicatorStatus &status)> change_listener_callback_ = nullptr;

    std::function<void(cbl::Replicator, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents)> document_listener_callback_ = nullptr;

    CouchbaseDatabase* getBucket(const QString &bucketName);

    void default_changeListener(cbl::Replicator, const CBLReplicatorStatus &status);

    void default_documentListener(cbl::Replicator, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents);
};
