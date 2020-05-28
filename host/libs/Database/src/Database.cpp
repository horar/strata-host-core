 #include <iostream>
#include "logging/LoggingQtCategories.h"
#include "Database.h"

Database::Database(const QString &db_name, const QString &db_path, QObject *parent) {
    database_ = std::make_unique<CouchbaseDatabase>(db_name.toStdString(), db_path.toStdString(), parent);
}

bool Database::open()
{
    return database_->open();
}

bool Database::save(CouchbaseDocument *doc) {
    return database_->save(doc);
}

QString Database::getDocumentAsStr(const QString &id) {
    return QString::fromStdString(database_->getDocumentAsStr(id.toStdString()));
}

QJsonObject Database::getDocumentAsJsonObj(const QString &id) {
    return database_->getDocumentAsJsonObj(id.toStdString());
}

QJsonObject Database::getDatabaseAsJsonObj() {
    return database_->getDatabaseAsJsonObj();
}

QString Database::getDatabaseName() {
    return QString::fromStdString(database_->getDatabaseName());
}

QString Database::getDatabasePath() {
    return QString::fromStdString(database_->getDatabasePath());
}

QStringList Database::getAllDocumentKeys() {
    std::vector<std::string> key_vector = database_->getAllDocumentKeys();
    QStringList list;
    for (const auto key : key_vector) {
        list << QString::fromStdString(key);
    }
    return list;
}

// bool Database::startReplicator(const QString &url, const QString &username, const QString &password, const QStringList &channels,
//                                const QString &replicator_type, const QString &conflict_resolution_policy, const QString &reconnection_policy) {
    
//     std::string _url = url.toStdString();

//     std::string _username = username.toStdString();

//     std::string _password = password.toStdString();
    
//     std::vector<std::string> _channels;
//     for (const auto channel : channels) {
//         _channels.push_back(channel.toStdString());
//     }

//     CouchbaseDatabase::ReplicatorType _replicator_type;
//     if (replicator_type.isEmpty() || replicator_type == "pull") {
//         _replicator_type = CouchbaseDatabase::ReplicatorType::kPull;
//     } else if (replicator_type == "push") {
//         _replicator_type = CouchbaseDatabase::ReplicatorType::kPush;
//     } else if (replicator_type == "pushandpull") {
//         _replicator_type = CouchbaseDatabase::ReplicatorType::kPushAndPull;
//     } else {
//         qCCritical(logCategoryCouchbaseDatabase) << "Error: Failed to start replicator, invalid replicator type provided.";
//     }

//     CouchbaseDatabase::ConflictResolutionPolicy _conflict_resolution_policy;
//     if (conflict_resolution_policy.isEmpty() || conflict_resolution_policy == "defaultbehavior") {
//         _conflict_resolution_policy = CouchbaseDatabase::ConflictResolutionPolicy::kDefaultBehavior;
//     } else if (replicator_type == "resolvetoremoterevision") {
//         _conflict_resolution_policy = CouchbaseDatabase::ConflictResolutionPolicy::kResolveToRemoteRevision;
//     } else {
//         qCCritical(logCategoryCouchbaseDatabase) << "Error: Failed to start replicator, invalid conflict resolution policy provided.";
//     }

//     CouchbaseDatabase::ReconnectionPolicy _reconnection_policy;
//     if (reconnection_policy.isEmpty() || reconnection_policy == "defaultbehavior") {
//         _reconnection_policy = CouchbaseDatabase::ReconnectionPolicy::kDefaultBehavior;
//     } else if (reconnection_policy == "automaticallyreconnect") {
//         _reconnection_policy = CouchbaseDatabase::ReconnectionPolicy::kAutomaticallyReconnect;
//     } else {
//         qCCritical(logCategoryCouchbaseDatabase) << "Error: Failed to start replicator, invalid reconnection policy provided.";
//     }

//     database_->setReplicatorStatusChangeListener(signalReceiver, this);

//     // database_->setReplicatorStatusChangeListener(signalReceiver, cp);

//     // cp = this;

//     if (database_->startReplicator(_url, _username, _password, _channels, _replicator_type, _conflict_resolution_policy, _reconnection_policy)) {
//         emit replicationFinished(this,"victor");

//         // emit this->replicationFinished(this);

//         // Database* x = this;

//         // emit x->replicationFinished(this, "abc");
//         // emit cp->replicationFinished(cp, "shared db");
//         return true;
//     }

//     return false;
// }