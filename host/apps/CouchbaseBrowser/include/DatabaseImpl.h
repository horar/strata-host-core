#ifndef DATABASEIMPL_H
#define DATABASEIMPL_H

#include <QObject>
#include <QCoreApplication>
#include <QDir>
#include <QQmlProperty>
#include <QDebug>

#include "SGCouchBaseLite.h"

class DatabaseImpl : public QObject
{
    Q_OBJECT

public:
    explicit DatabaseImpl(QObject *parent = nullptr);

    DatabaseImpl(const int &id);

    ~DatabaseImpl();

    QString getDBName();

    QString getJSONResponse();

    bool getDBstatus();

    bool getRepstatus();

    QString createNewDoc(const QString &id, const QString &body);

    QString rep_init(const QString &url, const QString &username = "", const QString &password = "",
        const Spyglass::SGReplicatorConfiguration::ReplicatorType &rep_type = Spyglass::SGReplicatorConfiguration::ReplicatorType::kPull,
        const std::vector<QString> &channels = std::vector<QString> ());

    void rep_stop();

    QString setFilePath(QString file_path);

    QString editDoc(const QString &oldId, const QString &newId = "", const QString &body = "");

    QString deleteDoc(const QString &id);

    QString saveAs(const QString &id, const QString &path);

private:
    QString file_path_, db_path_, db_name_, JSONResponse_, url_, username_, password_;

    int id_;

    bool DBstatus_ = false, Repstatus_ = false;

    std::vector<std::string> document_keys_, channels_ = {};

    Spyglass::SGDatabase *sg_db_{nullptr};

    Spyglass::SGReplicatorConfiguration *sg_replicator_configuration_{nullptr};

    Spyglass::SGURLEndpoint *url_endpoint_{nullptr};

    Spyglass::SGReplicator *sg_replicator_{nullptr};

    Spyglass::SGBasicAuthenticator *sg_basic_authenticator_{nullptr};

    Spyglass::SGReplicatorConfiguration::ReplicatorType rep_type_;

    void emitUpdate();

    QString getFilePath();

    void setDBPath(QString db_path);

    QString getDBPath();

    void setDBName(QString db_name);

    bool parseFilePath();

    bool db_init();

    bool setDocumentKeys();

    void setJSONResponse();

    void rep_init();

    void setDBstatus(bool status);

    void setRepstatus(bool status);

    bool parseExistingFile();

    bool parseNewFile();

    QString createNewDoc_(const QString &id, const QString &body);

    QString rep_init_();

    QString editDoc_(Spyglass::SGMutableDocument &doc, const QString &newId, const QString &body);

    QString deleteDoc_(Spyglass::SGDocument &doc);

    QString saveAs_(const QString &id, const QString &path);

signals:
    void newUpdate(int i);

};

#endif // DATABASEINTERFACE_H
