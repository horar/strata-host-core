/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include "DatabaseAccess.h"

#include <QObject>

namespace strata::Database
{

class CouchbaseDocument;

class CouchbaseDatabase;

class DatabaseLib : public QObject
{
    Q_OBJECT

    friend class CouchbaseDocument;

public:
    /**
     * Constructor: declares the DB object, does not open or create a DB
     * @param db_name DB name
     * @param db_path DB absolute path (default is empty: path is set to QDir::currentPath)
     * @param parent
     */
    DatabaseLib(const QString &db_name, const QString &db_path = "", QObject *parent = nullptr);

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

    bool deleteDoc(const QString &id);

    /**
     * Returns a document by given ID
     * @param id document ID
     * @return returns document body as QString in JSON format, or empty QString if not found
     */
    QString getDocumentAsStr(const QString &id);

    /**
     * Returns a document by given ID
     * @param id document ID
     * @return returns document body as QJsonObject, or empty QJsonObject if not found
     */
    QJsonObject getDocumentAsJsonObj(const QString &id);

    QJsonObject getDatabaseAsJsonObj();

    QString getDatabaseName();

    QString getDatabasePath();

    QStringList getAllDocumentKeys();

    /********************************************
     * REPLICATOR API *
     *******************************************/

    /**
     * Initializes and starts the DB replicator
     * @param url replicator / sync-gateway URL to connect to
     * @param username sync-gateway username (optional)
     * @param password sync-gateway password (optional)
     * @param channels replication channels (optional)
     * @param replicatorType push/pull/push and pull (optional)
     * @param changeListener function handle (optional, default is used)
     * @param documentListener function handle (optional, default is used)
     * @param continuous replicator continuous (optional, default to one-shot)
     * @return true when succeeded, otherwise false
     */
    bool startBasicReplicator(const QString &url,
        const QString &username = "",
        const QString &password = "",
        const QStringList &channels = QStringList(),
        const QString &replicatorType = "",
        std::function<void(cbl::Replicator rep, const DatabaseAccess::ActivityLevel &status)> changeListener = nullptr,
        std::function<void(cbl::Replicator rep, bool isPush, const std::vector<DatabaseAccess::ReplicatedDocument, std::allocator<DatabaseAccess::ReplicatedDocument>> documents)> documentListener = nullptr,
        bool continuous = false);

    void stopReplicator();

    QString getReplicatorStatus();

    int getReplicatorError();

private:
    std::unique_ptr<CouchbaseDatabase> database_;

    std::function<void(cbl::Replicator rep, const DatabaseAccess::ActivityLevel &status)> change_listener_callback_ = nullptr;

    std::function<void(cbl::Replicator, bool isPush, const std::vector<DatabaseAccess::ReplicatedDocument, std::allocator<DatabaseAccess::ReplicatedDocument>> documents)> document_listener_callback_ = nullptr;
};

} // namespace strata::Database
