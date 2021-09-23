/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <vector>
#include <string>

#include <QObject>
#include <QJsonObject>

#include <couchbase-lite-C/CouchbaseLite.hh>

namespace strata::Database
{

class CouchbaseDocument;

class CouchbaseDatabase : public QObject
{
    Q_OBJECT

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

    void joinChannel(const QString &strataLoginUsername, const QString &channel);

    void leaveChannel(const QString &strataLoginUsername, const QString &channel);

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

    enum class SGActivityLevel {
        CBLReplicatorStopped,    ///< The replicator is unstarted, finished, or hit a fatal error.
        CBLReplicatorOffline,    ///< The replicator is offline, as the remote host is unreachable.
        CBLReplicatorConnecting, ///< The replicator is connecting to the remote host.
        CBLReplicatorIdle,       ///< The replicator is inactive, waiting for changes to sync.
        CBLReplicatorBusy        ///< The replicator is actively transferring data.
    };

    typedef struct {
        SGActivityLevel activityLevel;
        int error;
    } SGReplicatorStatus;

    typedef struct {
        std::string id;
        int error;
    } SGReplicatedDocument;

    /**
     * Initializes and starts the DB replicator
     * @param url replicator / sync-gateway URL to connect to
     * @param username sync-gateway username (optional)
     * @param password sync-gateway password (optional)
     * @param channels replication channels (optional)
     * @param replicatorType push/pull/push and pull (optional)
     * @param change_listener_callback
     * @param document_listener_callback
     * @param continuous
     * @return true when succeeded, otherwise false
     */
    bool startBasicReplicator(const std::string &url,
        const std::string &username = "",
        const std::string &password = "",
        const std::vector<std::string> &channels = std::vector<std::string>(),
        const ReplicatorType &replicatorType = ReplicatorType::kPull,
        std::function<void(cbl::Replicator rep, const SGActivityLevel &status)> change_listener_callback = nullptr,
        std::function<void(cbl::Replicator rep, bool isPush, const std::vector<SGReplicatedDocument, std::allocator<SGReplicatedDocument>> documents)> document_listener_callback = nullptr,
        bool continuous = false
        );

    /**
     * Initializes and starts the DB replicator
     * @param url replicator / sync-gateway URL to connect to
     * @param token sync-gateway authentication token
     * @param cookieName sync-gateway authentication cookie name
     * @param channels replication channels (optional)
     * @param type push/pull/push and pull (optional)
     * @param change_listener_callback
     * @param document_listener_callback
     * @param continuous
     * @return true when succeeded, otherwise false
     */
    bool startSessionReplicator(const std::string &url,
        const std::string &token = "",
        const std::string &cookieName = "",
        const std::vector<std::string> &channels = std::vector<std::string>(),
        const ReplicatorType &replicatorType = ReplicatorType::kPull,
        std::function<void(cbl::Replicator rep, const SGActivityLevel &status)> change_listener_callback = nullptr,
        std::function<void(cbl::Replicator rep, bool isPush, const std::vector<SGReplicatedDocument, std::allocator<SGReplicatedDocument>> documents)> document_listener_callback = nullptr,
        bool continuous = false
        );

    void stopReplicator();

    CouchbaseDatabase::SGActivityLevel getReplicatorStatus();

    std::string getReplicatorStatusString();

    int getReplicatorError();

    void setLogLevel(const QString &level);

    void setLogCallback(void (*callback)(CBLLogDomain domain, CBLLogLevel level, const char *message) = nullptr);

    static void logReceived(CBLLogDomain domain, CBLLogLevel level, const char *message);

private:
    bool documentExistInDB(const std::string &id);

    void replicatorStatusChanged(cbl::Replicator rep, const CBLReplicatorStatus &status);

    void documentStatusChanged(cbl::Replicator rep, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents);

    void freeReplicator();

    std::string database_name_;
    std::string database_path_;

    SGActivityLevel status_;

    int error_code_ = 0;

    std::unique_ptr<cbl::Database> database_;

    std::unique_ptr<cbl::ReplicatorConfiguration> replicator_configuration_;
    std::unique_ptr<cbl::Replicator> replicator_;

    std::unique_ptr<cbl::Replicator::ChangeListener> ctoken_ = nullptr;
    std::unique_ptr<cbl::Replicator::DocumentListener> dtoken_ = nullptr;

    std::function<void(cbl::Replicator rep, const SGActivityLevel &status)> change_listener_callback_;
    std::function<void(cbl::Replicator, bool isPush, const std::vector<SGReplicatedDocument, std::allocator<SGReplicatedDocument>> documents)> document_listener_callback_;

    bool repIsStopping_ = false;
};

} // namespace strata::Database
