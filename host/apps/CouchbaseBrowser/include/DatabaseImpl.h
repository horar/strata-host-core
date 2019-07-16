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

public:
    explicit DatabaseImpl(QObject *parent = nullptr, bool mgr = true);

    ~DatabaseImpl();

    Q_INVOKABLE QString getDBName();

    Q_INVOKABLE QString getJSONResponse();

    Q_INVOKABLE QString createNewDoc(QString id, QString body);

    Q_INVOKABLE QString startListening(QString url, QString username = "", QString password = "",
        QString rep_type = "pull", std::vector<QString> channels = std::vector<QString> ());

    Q_INVOKABLE QString stopListening();

    Q_INVOKABLE QString openDB(QString file_path);

    Q_INVOKABLE QString closeDB();

    Q_INVOKABLE QString editDoc(QString oldId, QString newId = "", QString body = "");

    Q_INVOKABLE QString deleteDoc(QString id);

    Q_INVOKABLE QString saveAs(QString id, QString path);

    Q_INVOKABLE QString setChannels(std::vector<QString> channels);

    Q_INVOKABLE QString searchDocById(QString id);

    Q_INVOKABLE QString createNewDB(QString folder_path, QString db_name);

    Q_INVOKABLE bool getDBstatus();

    Q_INVOKABLE QString getConfigJson();

    Q_INVOKABLE QString deleteConfigEntry(QString id);

    Q_INVOKABLE QString clearConfig();

    Q_INVOKABLE bool getRepstatus();

private:
    QString file_path_, db_path_, db_name_, JSONResponse_, url_, username_, password_, rep_type_;

    bool DBstatus_ = false, Repstatus_ = false;

    std::vector<std::string> document_keys_, channels_ = {};

    Spyglass::SGDatabase *sg_db_{nullptr};

    Spyglass::SGReplicatorConfiguration *sg_replicator_configuration_{nullptr};

    Spyglass::SGURLEndpoint *url_endpoint_{nullptr};

    Spyglass::SGReplicator *sg_replicator_{nullptr};

    Spyglass::SGBasicAuthenticator *sg_basic_authenticator_{nullptr};

    ConfigManager *config_mgr{nullptr};

    QLoggingCategory cb_browser;

    void emitUpdate();

    void setDBPath(QString db_path);

    QString getDBPath();

    void setDBName(QString db_name);

    bool setDocumentKeys();

    void setJSONResponse(std::vector<std::string> &docs);

    void setDBstatus(bool status);

    void setRepstatus(bool status);

    QString startRep();

    QString saveAs_(const QString &id, const QString &path);

    QString makeJsonMsg(const bool &success, QString msg);

    bool isJsonMsgSuccess(const QString &msg);

signals:
    void newUpdate();

};

#endif // DATABASEIMPL_H
