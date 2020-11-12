#pragma once

#include <vector>
#include <string>

#include <QObject>
#include <QJsonObject>
#include <QJsonDocument>

#include <couchbase-lite-C/CouchbaseLite.hh>
#include "CouchbaseDocument.h"
#include "Database.h"

class Database;

class CouchbaseDocument;

class CouchbaseDatabase : public QObject
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
    CouchbaseDatabase(const std::string &db_name, const std::string &db_path = "", QObject *parent = nullptr);

    ~CouchbaseDatabase();

    /********************************************
     * MAIN CRUD OPERATIONS *
     *******************************************/

    /**
     * Opens an existing DB or creates a new DB
     * @return true when succeeded, otherwise false
     */
    bool open();

    bool close();

    bool save(CouchbaseDocument *doc);

    bool deleteDoc(const std::string &id);

    /**
     * Returns a document by given ID
     * @param id document ID
     * @return returns document body as QString in JSON format, or empty QString if not found
     */
    std::string getDocumentAsStr(const std::string &id);

    /**
     * Returns a document by given ID
     * @param id document ID
     * @return returns document body as QJsonObject, or empty QJsonObject if not found
     */
    QJsonObject getDocumentAsJsonObj(const std::string &id);

    QJsonObject getDatabaseAsJsonObj();

    std::string getDatabaseName();

    std::string getDatabasePath();

    std::vector<std::string> getAllDocumentKeys();

    /********************************************
     * REPLICATOR API *
     *******************************************/

    enum class ReplicatorType {
        kPull,
        kPush,
        kPushAndPull
    };

    enum class ConflictResolutionPolicy {
        kDefaultBehavior,
        kResolveToRemoteRevision
    };

    enum class ReconnectionPolicy {
        kDefaultBehavior,
        kAutomaticallyReconnect
    };

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
    bool startReplicator(const std::string &url,
                         const std::string &username = "",
                         const std::string &password = "",
                         const std::vector<std::string> &channels = std::vector<std::string>(),
                         const ReplicatorType &replicator_type = ReplicatorType::kPull,
                         std::function<void(cbl::Replicator rep, const CBLReplicatorStatus &status)> change_listener_callback = nullptr,
                         std::function<void(cbl::Replicator, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents)> document_listener_callback = nullptr,
                         bool continuous = false
                        );

    void stopReplicator();

    std::string getReplicatorStatus();

    int getReplicatorError();

private:
    struct LatestReplicationInformation {
        std::string url;
        std::string username;
        std::string password;
        std::vector<std::string> channels;
        ReplicatorType replicator_type;
        std::function<void(cbl::Replicator rep, const CBLReplicatorStatus &status)> change_listener_callback;
        std::function<void(cbl::Replicator, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents)> document_listener_callback;
        bool continuous;

        void reset () {
            url = "";
            username = "";
            password = "";
            channels.clear();
            replicator_type = ReplicatorType::kPull;
            change_listener_callback = nullptr;
            document_listener_callback = nullptr;
            continuous = false;
        }
    };

    bool documentExistInDB(const std::string &id);

    void replicatorStatusChanged(cbl::Replicator rep, const CBLReplicatorStatus &status);

    void documentStatusChanged(cbl::Replicator rep, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents);

    std::string database_name_;
    std::string database_path_;
    std::string status_;
    int error_code_ = 0;

    std::unique_ptr<cbl::Database> database_;

    std::unique_ptr<cbl::ReplicatorConfiguration> replicator_configuration_;
    std::unique_ptr<cbl::Replicator> replicator_;

    std::unique_ptr<cbl::Replicator::ChangeListener> ctoken_ = nullptr;
    std::unique_ptr<cbl::Replicator::DocumentListener> dtoken_ = nullptr;

    LatestReplicationInformation latest_replication_;
    bool is_retry_ = false;
};