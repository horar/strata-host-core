#ifndef DATABASEIMPL_H
#define DATABASEIMPL_H

#include <QObject>

#include <couchbaselitecpp/SGCouchBaseLite.h>
#include <QLoggingCategory>

#include "ConfigManager.h"

class ConfigManager;

enum class MessageType
{
    Success,
    Warning,
    Error
};

class DatabaseImpl : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString dbName READ getDBName NOTIFY dbNameChanged)
    Q_PROPERTY(QString jsonDBContents READ getJsonDBContents NOTIFY jsonDBContentsChanged)
    Q_PROPERTY(QString jsonConfig READ getJsonConfig NOTIFY jsonConfigChanged)
    Q_PROPERTY(bool dbStatus READ getDBStatus NOTIFY dbStatusChanged)
    Q_PROPERTY(bool listenStatus READ getListenStatus NOTIFY listenStatusChanged)
    Q_PROPERTY(QString channels READ getAllChannels NOTIFY channelsChanged)
    Q_PROPERTY(QString activityLevel READ getActivityLevel NOTIFY activityLevelChanged)

public:
    DatabaseImpl(QObject *parent = nullptr, const bool &mgr = true);

    ~DatabaseImpl();

    QString getDBName() const;

    QString getJsonDBContents() const;

    QString getJsonConfig() const;

    bool isDBOpen() const;

    bool getDBStatus() const;

    bool getListenStatus() const;

    QString getActivityLevel() const;

    QString getAllChannels() const;

    MessageType getCurrentStatus() const;

    Q_INVOKABLE QString getMessage() const;

    Q_INVOKABLE void createNewDoc(const QString &id, const QString &body);

    Q_INVOKABLE bool startListening(QString url, QString username = "", QString password = "",
        QString rep_type = "pull", std::vector<QString> channels = std::vector<QString> ());

    Q_INVOKABLE bool stopListening();

    Q_INVOKABLE void openDB(const QString &file_path);

    Q_INVOKABLE void closeDB();

    Q_INVOKABLE void editDoc(QString oldId, QString newId = "", QString body = "");

    Q_INVOKABLE void deleteDoc(const QString &id);

    Q_INVOKABLE void saveAs(QString path, QString db_name);

    Q_INVOKABLE void searchDocByChannel(const std::vector<QString> &channels);

    Q_INVOKABLE void searchDocById(QString id);

    Q_INVOKABLE void createNewDB(QString folder_path, const QString &db_name);

    Q_INVOKABLE void deleteConfigEntry(const QString &db_name);

    Q_INVOKABLE void clearConfig();

    Q_INVOKABLE QStringList getChannelSuggestions();

private:
    QString file_path_;
    QString db_path_;
    QString db_name_;
    QString url_;
    QString username_;
    QString password_;
    QString rep_type_;
    QString message_;
    QString activity_level_;
    QString JsonDBContents_;
    QString JSONChannels_;

    bool db_is_running_ = false;
    bool rep_is_running_ = false;
    bool manual_replicator_stop_ = false;
    bool replicator_first_connection_ = true;

    // Set replicator reconnection timer to 15 seconds
    const unsigned int REPLICATOR_RECONNECTION_INTERVAL = 15;

    std::vector<std::string> document_keys_ = {};

    QStringList listened_channels_ = {}, suggested_channels_ = {};

    std::vector<QString> toggled_channels_ = {};

    std::unique_ptr<Strata::SGDatabase> sg_db_ = nullptr;

    std::unique_ptr<Strata::SGReplicatorConfiguration> sg_replicator_configuration_ = nullptr;

    std::unique_ptr<Strata::SGURLEndpoint> url_endpoint_ = nullptr;

    std::unique_ptr<Strata::SGReplicator> sg_replicator_ = nullptr;

    std::unique_ptr<Strata::SGBasicAuthenticator> sg_basic_authenticator_ = nullptr;

    std::unique_ptr<ConfigManager> config_mgr_ = nullptr;

    QLoggingCategory cb_browser_;

    MessageType current_status_;

    void emitUpdate();

    void setMessageAndStatus(const MessageType &status, QString msg);

    void setDBPath(const QString &db_path);

    void setDBName(const QString &db_name);

    bool setDocumentKeys();

    void setJSONResponse(std::vector<std::string> &docs);

    void setJSONResponse(const QString &response);

    void setDBstatus(const bool &status);

    void setRepstatus(const bool &status);

    void setAllChannels();

    void setAllChannelsStr();

    void repStatusChanged(const Strata::SGReplicator::ActivityLevel &level);

signals:
    void dbNameChanged();

    void jsonDBContentsChanged();

    void jsonConfigChanged();

    void dbStatusChanged();

    void listenStatusChanged();

    void channelsChanged();

    void messageChanged();

    void activityLevelChanged();
};

#endif // DATABASEIMPL_H
