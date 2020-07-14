#pragma once

#include "CouchbaseDatabase.h"

#include <QObject>

class CouchbaseDocument;
class CouchbaseDatabase;

class Database : public QObject
{
    Q_OBJECT

    friend class CouchbaseDocument;

public:
    /**
     * Constructor: declares the DB object, does not open or create a DB
     * @param db_name DB name
     * @param db_path DB absolute path (default is empty: path is set to QDir::currentPath)
     * @param parent
     */
    Database(const QString &db_name, const QString &db_path = "", QObject *parent = nullptr);

    /********************************************
     * MAIN CRUD OPERATIONS *
     *******************************************/

    /**
     * Opens an existing DB or creates a new DB
     * @return true when succeeded, otherwise false
     */
    bool open();

    bool save(CouchbaseDocument *doc);

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
     * @param channels replication channels (optional)
     * @param type push/pull/push and pull (optional)
     * @param conflict_resolution_policy default behavior or always resolve to remote revision (optional)
     * @param reconnection_policy default behavior or automatically try to reconnect (optional)
     * @return true when succeeded, otherwise false
     */
    bool startReplicator(const QString &url,
                         const QString &username = "",
                         const QString &password = "",
                         const QStringList &channels = QStringList(),
                         const QString &replicator_type = "",
                         std::function<void(cbl::Replicator rep, const CBLReplicatorStatus &status)> changeListener = nullptr,
                         std::function<void(cbl::Replicator rep, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents)> documentListener = nullptr
                         );

    void stopReplicator();

    QString getReplicatorStatus();
    int getReplicatorError();

private:
    std::unique_ptr<CouchbaseDatabase> database_;

    std::function<void(cbl::Replicator rep, const CBLReplicatorStatus &status)> change_listener_callback = nullptr;

    std::function<void(cbl::Replicator, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents)> document_listener_callback = nullptr;

    void default_changeListener(cbl::Replicator, const CBLReplicatorStatus &status);

    void default_documentListener(cbl::Replicator, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents);
};