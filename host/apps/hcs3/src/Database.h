
#ifndef HOST_HCS_DATABASE_H__
#define HOST_HCS_DATABASE_H__

#include <string>
#include <set>
#include <QObject>

namespace Strata {
    class SGDatabase;
    class SGURLEndpoint;
    class SGReplicatorConfiguration;
    class SGReplicator;
    class SGBasicAuthenticator;

    class SGMutableDocument;
};

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
    bool open(std::string_view db_path, const std::string &db_name);

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
    void onDocumentEnd(bool pushing, std::string doc_id, std::string error_message, bool is_error, bool error_is_transient);

    void updateChannels();

private:
    std::string sgDatabasePath_;
    Strata::SGDatabase *sg_database_{nullptr};

    Strata::SGURLEndpoint *url_endpoint_{nullptr};
    Strata::SGReplicatorConfiguration *sg_replicator_configuration_{nullptr};
    Strata::SGReplicator *sg_replicator_{nullptr};
    bool isRunning_{false};

    // Set replicator reconnection timer to 15 seconds
    const unsigned int REPLICATOR_RECONNECTION_INTERVAL = 15;

    Strata::SGBasicAuthenticator *basic_authenticator_{nullptr};

    std::set<std::string> channels_;
};

#endif //HOST_HCS_DATABASE_H__
