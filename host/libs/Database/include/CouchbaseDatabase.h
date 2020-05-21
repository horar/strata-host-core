#pragma once

#include <vector>
#include <string>

#include <QObject>
#include <QJsonObject>
#include <QJsonDocument>

#include <couchbaselitecpp/SGReplicator.h>
#include <couchbaselitecpp/SGMutableDocument.h>

#include "CouchbaseDocument.h"

#include "Database.h"

namespace Strata {
    class SGDatabase;
    class SGURLEndpoint;
    class SGReplicatorConfiguration;
    class SGReplicator;
    class SGBasicAuthenticator;
    class SGMutableDocument;
};

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

    bool save(CouchbaseDocument *doc);

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

    bool isOpen();

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

    // void setReplicatorStatusChangeListener(std::function<void(Strata::SGReplicator::ActivityLevel)> on_replicator_status_changed_callback);

    // void setReplicatorStatusChangeListener(std::function<void(Strata::SGReplicator::ActivityLevel)> on_replicator_status_changed_callback, Database* db);

    void setReplicatorStatusChangeListener(std::function<void(Strata::SGReplicator::ActivityLevel, Database* db)> on_replicator_status_changed_callback, Database* db);

    void setDocumentStatusChangeListener(std::function<void(bool, std::string, std::string, bool, bool)> on_document_status_changed_callback);

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
                         const ConflictResolutionPolicy &conflict_resolution_policy = ConflictResolutionPolicy::kDefaultBehavior,
                         const ReconnectionPolicy &reconnection_policy = ReconnectionPolicy::kDefaultBehavior
                         );

    bool stopReplicator();

    Strata::SGReplicator::ActivityLevel getReplicatorActivityLevel();

private:
    void replicatorStatusChanged(const Strata::SGReplicator::ActivityLevel &level);

    void documentStatusChanged(const bool &pushing, const std::string &doc_id, const std::string &error_message, const bool &is_error, const bool &error_is_transient);

    std::string database_name_;
    std::string database_path_;

    std::unique_ptr<Strata::SGDatabase> database_;
    std::unique_ptr<Strata::SGURLEndpoint> url_endpoint_;
    std::unique_ptr<Strata::SGReplicatorConfiguration> sg_replicator_configuration_;
    std::unique_ptr<Strata::SGReplicator> sg_replicator_;
    std::unique_ptr<Strata::SGBasicAuthenticator> basic_authenticator_;

    std::vector<std::string> channels_;

    // std::function<void(Strata::SGReplicator::ActivityLevel)> on_replicator_status_changed_callback_;
    std::function<void(Strata::SGReplicator::ActivityLevel, Database* db)> on_replicator_status_changed_callback_;

    std::function<void(bool, std::string, std::string, bool, bool)> on_document_status_changed_callback_;

    Strata::SGReplicator::ActivityLevel activity_level_;

    Database* shared_db_;
};