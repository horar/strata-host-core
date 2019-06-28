#ifndef DATABASEINTERFACE_H
#define DATABASEINTERFACE_H

#include <QObject>
#include <QCoreApplication>
#include <QTextStream>
#include <QFileDialog>
#include <QTextEdit>
#include <QDir>
#include <QQmlProperty>
#include <QDebug>

#include <iostream>

#include "SGFleece.h"
#include "SGCouchBaseLite.h"

class DatabaseInterface : public QObject
{
    Q_OBJECT

public:
    explicit DatabaseInterface(QObject *parent = nullptr);

    DatabaseInterface(const QString &file_path, const int &id);

    ~DatabaseInterface();

    QString getDBName();

    QString getJSONResponse();

    bool createNewDoc(const QString &id, const QString &body);

private:
    QString file_path_, db_path_, db_name_, JSONResponse_;

    int id_;

    bool DBstatus_, Repstatus_;

    std::vector<std::string> document_keys_;

    Spyglass::SGDatabase *sg_db_{nullptr};

    Spyglass::SGReplicatorConfiguration *sg_replicator_configuration_{nullptr};

    Spyglass::SGURLEndpoint *url_endpoint_{nullptr};

    Spyglass::SGReplicator *sg_replicator_{nullptr};

    void emitUpdate();

    static void testReceive(bool pushing, std::string doc_id, std::string error_message, bool is_error, bool error_is_transient);

    void setFilePath(QString file_path);

    QString getFilePath();

    void setDBPath(QString db_path);

    QString getDBPath();

    void setDBName(QString db_name);

    bool parseFilePath();

    bool db_init();

    int setDocumentKeys();

    void setJSONResponse();

    void rep_init();

    bool getDBstatus();

    bool getRepstatus();

    void setDBstatus(bool status);

    void setRepstatus(bool status);

    bool createNewDoc_(const QString &id, const QString &body);

signals:
    void newUpdate(int i);

};

#endif // DATABASEINTERFACE_H
