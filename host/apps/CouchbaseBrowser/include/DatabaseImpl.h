#ifndef DATABASEIMPL_H
#define DATABASEIMPL_H

#include <QObject>
#include <QCoreApplication>
#include <QDir>
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

    QString startListening(const QString &url, const QString &username = "", const QString &password = "",
        const QString &rep_type = "pull", const std::vector<QString> &channels = std::vector<QString> ());

    void stopListening();

    QString openDB(QString &file_path);

    void closeDB();

    QString editDoc(QString &oldId, QString newId = "", const QString body = "");

    QString deleteDoc(const QString &id);

    QString saveAs(const QString &id, QString &path);

    QString setChannels(const std::vector<QString> &channels);

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

    QString rep_type_;

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

    QString startRep();

    QString deleteDoc_(Spyglass::SGDocument &doc);

    QString saveAs_(const QString &id, const QString &path);

signals:
    void newUpdate(int i);

};

#endif // DATABASEIMPL_H
