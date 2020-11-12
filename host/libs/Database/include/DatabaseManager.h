#pragma once

#include "CouchbaseDatabase.h"

class DatabaseAccess;

class DatabaseManager
{
    friend class CouchbaseDocument;

public:
    DatabaseAccess* open(const QString &channel_access, const QString &database_prefix = "");

private:
    DatabaseAccess *db_access_;
};


class DatabaseAccess
{
    friend class DatabaseManager;

public:
    bool close();

    QString getChannelAccess();

    bool write(CouchbaseDocument *doc);

    bool deleteDoc(const QString &id);

    /**
     * Returns a document by given ID
     * @param id document ID
     * @return returns document body as QString in JSON format, or empty QString if not found
     */
    QString getDocumentAsStr(const QString &id);

    /**
     * Returns a document by given ID
     * @param id document ID
     * @return returns document body as QJsonObject, or empty QJsonObject if not found
     */
    QJsonObject getDocumentAsJsonObj(const QString &id);

    QJsonObject getDatabaseAsJsonObj();

    QString getDatabaseName();

    QString getDatabasePath();

    QStringList getAllDocumentKeys();

    /********************************************
     * REPLICATOR API *
     *******************************************/

    /**
     * Initializes and starts the DB replicator
     * @param url replicator / sync-gateway URL to connect to
     * @param username sync-gateway username (optional)
     * @param password sync-gateway password (optional)
     * @param type push/pull/push and pull (optional)
     * @param conflict_resolution_policy default behavior or always resolve to remote revision (optional)
     * @param reconnection_policy default behavior or automatically try to reconnect (optional)
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

    QString getReplicatorStatus();
    int getReplicatorError();

private:
    QString channel_access_;

    std::unique_ptr<CouchbaseDatabase> database_;

    std::function<void(cbl::Replicator rep, const CBLReplicatorStatus &status)> change_listener_callback = nullptr;

    std::function<void(cbl::Replicator, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents)> document_listener_callback = nullptr;

    void default_changeListener(cbl::Replicator, const CBLReplicatorStatus &status);

    void default_documentListener(cbl::Replicator, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents);
};