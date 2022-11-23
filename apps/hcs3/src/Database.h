/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QString>
#include <set>
#include <QObject>

#include <Database/DatabaseAccess.h>

class HCS_Dispatcher;

class Database final: public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(Database)

public:
    Database(QObject *parent = nullptr);
    ~Database();

    enum class ReplicatorActivity {
        Stopped,    // The replicator is unstarted, finished, or hit a fatal error.
        Offline,    // The replicator is offline, as the remote host is unreachable.
        Connecting, // The replicator is connecting to the remote host.
        Idle,       // The replicator is inactive, waiting for changes to sync.
        Busy        // The replicator is actively transferring data.
    };
    Q_ENUM(ReplicatorActivity)

    enum class ErrorDomain {
        NoDomain = 0,      // value for a case if there is no error - there is no error domain either
        CouchbaseLite = 1, // code is a Couchbase Lite error code; see CBLErrorCode
        Posix,             // code is a POSIX `errno`; see "errno.h"
        SQLite,            // code is a SQLite error; see "sqlite3.h"
        Fleece,            // code is a Fleece error; see "FleeceException.h"
        Network,           // code is a network error; see CBLNetworkErrorCode
        WebSocket          // code is a WebSocket close code (1000...1015) or HTTP error (300..599)
    };
    Q_ENUM(ErrorDomain)

    /**
     * Opens the database
     * @param db_path
     * @param db_name
     * @return returns true when succeeded, otherwise false
     * NOTE: add a path to the DB.
     */
    bool open(const QString& db_path, const QString& db_name);

    /**
     * Initializes and starts the DB replicator
     * @param replUrl replicator URL to connect to
     * @return returns true when succeeded otherwise false
     */
    bool initReplicator(const QString& replUrl, const QString& username, const QString& password);

    /**
     * Adds a channel to the replication
     * @param channel channel name
     * @return returns true when succeeded, otherwise false
     */
    bool addReplChannel(const QString& channel);

    /**
     * Removes a channel from the replication
     * @param channel channel name
     * @return returns true when succeeded, otherwise false
     */
    bool remReplChannel(const QString& channel);

    /**
     * Returns a document by given ID and root element name
     * @param doc_id document ID
     * @param root_element_name root element name
     * @param result resulting Json document
     * @return returns true when succeeded, otherwise false
     * NOTE: we need also a revision
     */
    bool getDocument(const QString& doc_id, QString& result);

    /**
     * Stop the replication operations and close the database
     */
    void stop();

signals:
    void documentUpdated(QString documentId);
    void replicatorStatusChanged(ReplicatorActivity activity, int errorCode, ErrorDomain errorDomain);

private:
    struct Replication {
        QString url;
        QString username;
        QString password;
    };

    Replication replication_;

    QString databaseName_;

    QString databasePath_;

    QStringList databaseChannels_;

    std::unique_ptr<strata::Database::DatabaseAccess> DB_ = nullptr;

    bool isRunning_ = false;

    void documentListener(bool isPush, const std::vector<strata::Database::DatabaseAccess::ReplicatedDocument, std::allocator<strata::Database::DatabaseAccess::ReplicatedDocument>>& documents);

    void changeListener(strata::Database::DatabaseAccess::ActivityLevel activityLevel, int errorCode, strata::Database::DatabaseAccess::ErrorCodeDomain domain);

    void updateChannels();
};
