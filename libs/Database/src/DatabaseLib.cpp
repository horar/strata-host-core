/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "logging/LoggingQtCategories.h"
#include "Database/DatabaseLib.h"
#include "CouchbaseDatabase.h"

using namespace strata::Database;

DatabaseLib::DatabaseLib(const QString &db_name, const QString &db_path, QObject *parent) {
    database_ = std::make_unique<CouchbaseDatabase>(db_name.toStdString(), db_path.toStdString(), parent);
}

bool DatabaseLib::open() {
    return database_->open();
}

bool DatabaseLib::close() {
    return database_->close();
}

bool DatabaseLib::save(CouchbaseDocument *doc) {
    return database_->save(doc);
}

bool DatabaseLib::deleteDoc(const QString &id) {
    return database_->deleteDoc(id.toStdString());
}

QString DatabaseLib::getDocumentAsStr(const QString &id) {
    return QString::fromStdString(database_->getDocumentAsStr(id.toStdString()));
}

QJsonObject DatabaseLib::getDocumentAsJsonObj(const QString &id) {
    return database_->getDocumentAsJsonObj(id.toStdString());
}

QJsonObject DatabaseLib::getDatabaseAsJsonObj() {
    return database_->getDatabaseAsJsonObj();
}

QString DatabaseLib::getDatabaseName() {
    return QString::fromStdString(database_->getDatabaseName());
}

QString DatabaseLib::getDatabasePath() {
    return QString::fromStdString(database_->getDatabasePath());
}

QStringList DatabaseLib::getAllDocumentKeys() {
    auto key_vector = database_->getAllDocumentKeys();
    QStringList list;
    for (const auto &key : key_vector) {
        list << QString::fromStdString(key);
    }
    return list;
}

bool DatabaseLib::startBasicReplicator(const QString &url, const QString &username, const QString &password, const QStringList &channels, const QString &replicatorType,
    std::function<void(DatabaseAccess::ActivityLevel activity, int errorCode, DatabaseAccess::ErrorCodeDomain domain)> changeListener,
    std::function<void(cbl::Replicator rep, bool isPush, const std::vector<DatabaseAccess::ReplicatedDocument, std::allocator<DatabaseAccess::ReplicatedDocument>> documents)> documentListener,
    bool continuous) {

    auto _url = url.toStdString();
    auto _username = username.toStdString();
    auto _password = password.toStdString();

    std::vector<std::string> _channels;
    for (const auto &channel : channels) {
        _channels.push_back(channel.toStdString());
    }

    CouchbaseDatabase::ReplicatorType _replicator_type;
    if (replicatorType.isEmpty() || replicatorType == "pull") {
        _replicator_type = CouchbaseDatabase::ReplicatorType::kPull;
    } else if (replicatorType == "push") {
        _replicator_type = CouchbaseDatabase::ReplicatorType::kPush;
    } else if (replicatorType == "pushandpull") {
        _replicator_type = CouchbaseDatabase::ReplicatorType::kPushAndPull;
    } else {
        qCCritical(lcCouchbaseDatabase) << "Error: Failed to start replicator, invalid replicator type provided.";
    }

    if (changeListener) {
        change_listener_callback_ = changeListener;
    }

    if (documentListener) {
        document_listener_callback_ = documentListener;
    }

    auto change_listener_callback = [this] (CouchbaseDatabase::SGActivityLevel activity, int errorCode, CouchbaseDatabase::DbErrorDomain domain) -> void {
        DatabaseAccess::ActivityLevel activityLevel;
        DatabaseAccess::ErrorCodeDomain errorCodeDomain;

        switch (activity) {
            case CouchbaseDatabase::SGActivityLevel::CBLReplicatorStopped:
                activityLevel = DatabaseAccess::ActivityLevel::ReplicatorStopped;
                break;
            case CouchbaseDatabase::SGActivityLevel::CBLReplicatorOffline:
                activityLevel = DatabaseAccess::ActivityLevel::ReplicatorOffline;
                break;
            case CouchbaseDatabase::SGActivityLevel::CBLReplicatorConnecting:
                activityLevel = DatabaseAccess::ActivityLevel::ReplicatorConnecting;
                break;
            case CouchbaseDatabase::SGActivityLevel::CBLReplicatorIdle:
                activityLevel = DatabaseAccess::ActivityLevel::ReplicatorIdle;
                break;
            case CouchbaseDatabase::SGActivityLevel::CBLReplicatorBusy:
                activityLevel = DatabaseAccess::ActivityLevel::ReplicatorBusy;
                break;
        }

        switch (domain) {
            case CouchbaseDatabase::DbErrorDomain::CBLDomain:
                errorCodeDomain = DatabaseAccess::ErrorCodeDomain::CouchbaseLiteDomain;
                break;
            case CouchbaseDatabase::DbErrorDomain::CBLPosixDomain:
                errorCodeDomain = DatabaseAccess::ErrorCodeDomain::PosixDomain;
                break;
            case CouchbaseDatabase::DbErrorDomain::CBLSQLiteDomain:
                errorCodeDomain = DatabaseAccess::ErrorCodeDomain::SQLiteDomain;
                break;
            case CouchbaseDatabase::DbErrorDomain::CBLFleeceDomain:
                errorCodeDomain = DatabaseAccess::ErrorCodeDomain::FleeceDomain;
                break;
            case CouchbaseDatabase::DbErrorDomain::CBLNetworkDomain:
                errorCodeDomain = DatabaseAccess::ErrorCodeDomain::NetworkDomain;
                break;
            case CouchbaseDatabase::DbErrorDomain::CBLWebSocketDomain:
                errorCodeDomain = DatabaseAccess::ErrorCodeDomain::WebSocketDomain;
                break;
        }

        if (change_listener_callback_) {
            change_listener_callback_(activityLevel, errorCode, errorCodeDomain);
        } else {
            qCInfo(lcCouchbaseDatabase) << "--- PROGRESS: status =" << DatabaseAccess::activityLevelToString(activityLevel);
        }
    };

    auto document_listener_callback = [this] (cbl::Replicator rep, bool isPush, const std::vector<CouchbaseDatabase::SGReplicatedDocument, std::allocator<CouchbaseDatabase::SGReplicatedDocument>> documents) {
        if (document_listener_callback_) {
            std::vector<DatabaseAccess::ReplicatedDocument, std::allocator<DatabaseAccess::ReplicatedDocument>> SGDocuments;
            for (const auto &doc : documents) {
                DatabaseAccess::ReplicatedDocument SGDocument;
                SGDocument.id = QString::fromStdString(doc.id);
                SGDocument.error = doc.error;
                SGDocuments.push_back(SGDocument);
            }

            document_listener_callback_(rep, isPush, SGDocuments);
        } else {
            qCInfo(lcCouchbaseDatabase) << "--- " << documents.size() << " docs " << (isPush ? "pushed." : "pulled.");
        }
    };

    if (database_->startBasicReplicator(_url, _username, _password, _channels, _replicator_type, change_listener_callback, document_listener_callback, continuous)) {
        return true;
    }

    return false;
}

void DatabaseLib::stopReplicator() {
    database_->stopReplicator();
}

QString DatabaseLib::getReplicatorStatus() {
    return QString::fromStdString(database_->getReplicatorStatusString());
}

int DatabaseLib::getReplicatorError() {
    return database_->getReplicatorError();
}
