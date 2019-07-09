
#ifndef HOST_HCS_DATABASE_H__
#define HOST_HCS_DATABASE_H__

#include <string>
#include <set>

namespace Spyglass {
    class SGDatabase;
    class SGURLEndpoint;
    class SGReplicatorConfiguration;
    class SGReplicator;
    class SGBasicAuthenticator;

    class SGMutableDocument;
};

class HCS_Dispatcher;
class LoggingAdapter;

class Database final
{
public:
    Database();
    ~Database();

    void setDispatcher(HCS_Dispatcher* dispatcher);
    void setLogAdapter(LoggingAdapter* adapter);

    /**
     * Opens the database
     * @param db_name
     * @return returns true when succeeded, otherwise false
     * NOTE: add a path to the DB.
     */
    bool open(const std::string& db_name);

    /**
     * Initializes and starts the DB replicator
     * @param replUrl replicator URL to connect to
     * @return returns true when succeeded otherwise false
     */
    bool initReplicator(const std::string& replUrl);

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
    bool getDocument(const std::string& doc_id, const std::string& root_element_name, std::string& result);

private:
    void onDocumentEnd(bool pushing, std::string doc_id, std::string error_message, bool is_error, bool error_is_transient);

    void updateChannels();

private:
    Spyglass::SGDatabase *sg_database_{nullptr};

    Spyglass::SGURLEndpoint *url_endpoint_{nullptr};
    Spyglass::SGReplicatorConfiguration *sg_replicator_configuration_{nullptr};
    Spyglass::SGReplicator *sg_replicator_{nullptr};
    bool isRunning_{false};

    Spyglass::SGBasicAuthenticator *basic_authenticator_{nullptr};

    HCS_Dispatcher* dispatcher_{nullptr};
    LoggingAdapter* logAdapter_{nullptr};

    std::set<std::string> channels_;
};

#endif //HOST_HCS_DATABASE_H__
