#ifndef DATABASEIMPL_H
#define DATABASEIMPL_H

#include <QObject>

#include "SGCouchBaseLite.h"
#include <QLoggingCategory>

#include "ConfigManager.h"

class ConfigManager;

class DatabaseImpl : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString dbName READ getDBName NOTIFY dbNameChanged)
    Q_PROPERTY(QString jsonDBContents READ getJsonDBContents NOTIFY jsonDBContentsChanged)
    Q_PROPERTY(QString jsonConfig READ getJsonConfig NOTIFY jsonConfigChanged)
    Q_PROPERTY(bool dbStatus READ getDBStatus NOTIFY dbStatusChanged)
    Q_PROPERTY(bool listenStatus READ getListenStatus NOTIFY listenStatusChanged)
    Q_PROPERTY(QStringList channels READ getChannels NOTIFY channelsChanged)
    Q_PROPERTY(QString message READ getMessage NOTIFY messageChanged)
    Q_PROPERTY(QString activityLevel READ getActivityLevel NOTIFY activityLevelChanged)

public:
    explicit DatabaseImpl(QObject *parent = nullptr, bool mgr = true);

    ~DatabaseImpl();

    QString getDBName();

    QString getJsonDBContents();

    QString getJsonConfig();

    bool getDBStatus();

    bool getListenStatus();

    QString getMessage();

    QStringList getChannels();

    QString getActivityLevel();

    Q_INVOKABLE void createNewDoc(QString id, QString body);

    Q_INVOKABLE void startListening(QString url, QString username = "", QString password = "",
        QString rep_type = "pull", std::vector<QString> channels = std::vector<QString> ());

    Q_INVOKABLE void stopListening();

    Q_INVOKABLE void openDB(QString file_path);

    Q_INVOKABLE void closeDB();

    Q_INVOKABLE void editDoc(QString oldId, QString newId = "", QString body = "");

    Q_INVOKABLE void deleteDoc(QString id);

    Q_INVOKABLE void saveAs(QString path, QString db_name);

    Q_INVOKABLE void setChannels(std::vector<QString> channels);

    Q_INVOKABLE void searchDocById(QString id);

    Q_INVOKABLE void createNewDB(QString folder_path, QString db_name);

    Q_INVOKABLE void deleteConfigEntry(QString id);

    Q_INVOKABLE void clearConfig();

    Q_INVOKABLE QStringList getChannelSuggestions();

private:
    QString file_path_, db_path_, db_name_, url_, username_, password_, rep_type_, message_, activity_level_, JSONResponse_ = "{}";

    bool DBstatus_ = false, Repstatus_ = false, manual_replicator_stop_ = false, replicator_first_connection_ = true;

    bool waiting_for_start = false, waiting_for_stop = false, waiting_for_connection = false;

    std::vector<std::string> document_keys_, channels_ = {};

    Spyglass::SGDatabase *sg_db_{nullptr};

    Spyglass::SGReplicatorConfiguration *sg_replicator_configuration_{nullptr};

    Spyglass::SGURLEndpoint *url_endpoint_{nullptr};

    Spyglass::SGReplicator *sg_replicator_{nullptr};

    Spyglass::SGBasicAuthenticator *sg_basic_authenticator_{nullptr};

    ConfigManager *config_mgr{nullptr};

    QLoggingCategory cb_browser;

    void emitUpdate();

    void setMessage(const bool &success, QString msg);

    void setDBPath(QString db_path);

    QString getDBPath();

    void setDBName(QString db_name);

    bool setDocumentKeys();

    void setJSONResponse(std::vector<std::string> &docs);

    void setDBstatus(bool status);

    void setRepstatus(bool status);

    void startRep();

    bool isJsonMsgSuccess(const QString &msg);

    void repStatusChanged(Spyglass::SGReplicator::ActivityLevel level);

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
