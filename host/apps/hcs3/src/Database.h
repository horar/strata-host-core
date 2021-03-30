#pragma once

#include <string>
#include <set>
#include <QObject>

#include <Database/DatabaseManager.h>
#include <Database/DatabaseAccess.h>

class HCS_Dispatcher;

class Database final: public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(Database)

public:
    Database(QObject *parent = nullptr);
    ~Database();

    /**
     * Opens the database
     * @param db_path
     * @param db_name
     * @return returns true when succeeded, otherwise false
     * NOTE: add a path to the DB.
     */
    bool open(std::string_view db_path, const std::string& db_name);

    /**
     * Initializes and starts the DB replicator
     * @param replUrl replicator URL to connect to
     * @return returns true when succeeded otherwise false
     */
    bool initReplicator(const std::string& replUrl, const std::string& username, const std::string& password);

    /**
     * Adds a channel to the replication
     * @param channel channel name
     * @return returns true when succeeded, otherwise false
     */
    bool addReplChannel(const std::string& channel);

    /**
     * Removes a channel from the replication
     * @param channel channel name
     * @return returns true when succeeded, otherwise false
     */
    bool remReplChannel(const std::string& channel);

    /**
     * Returns a document by given ID and root element name
     * @param doc_id document ID
     * @param root_element_name root element name
     * @param result resulting Json document
     * @return returns true when succeeded, otherwise false
     * NOTE: we need also a revision
     */
    bool getDocument(const std::string& doc_id, std::string& result);

    /**
     * Stop the replication operations and close the database
     */
    void stop();

signals:
    void documentUpdated(QString documentId);

private:
    void updateChannels();

private:
    std::string sgDatabasePath_;

    std::unique_ptr<strata::Database::DatabaseManager> databaseManager_ = nullptr;

    strata::Database::DatabaseAccess* DB_ = nullptr;

    void documentListener(bool isPush, const std::vector<strata::Database::DatabaseAccess::ReplicatedDocument, std::allocator<strata::Database::DatabaseAccess::ReplicatedDocument>> documents);

    std::set<std::string> channels_;
};
