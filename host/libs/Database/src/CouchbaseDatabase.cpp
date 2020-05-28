#include "CouchbaseDatabase.h"
#include "logging/LoggingQtCategories.h"

#include <string>
#include <thread>
#include <iostream>

#include <QDir>
#include <QString>
#include <QDebug>

CouchbaseDatabase::CouchbaseDatabase(const std::string &db_name, const std::string &db_path, QObject *parent) : QObject(parent), database_name_(db_name), database_path_(db_path)
{
}

CouchbaseDatabase::~CouchbaseDatabase() {
    // if (sg_replicator_) {
    //     sg_replicator_->stop();
    // }
}

bool CouchbaseDatabase::open() {
    if (database_) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: Failed to open database (database may already be open).";
        return false;
    }

    if (database_path_.empty()) {
        database_path_ = QDir::currentPath().toStdString();
    }

    QDir dir(QString::fromStdString(database_path_));
    if (!dir.isAbsolute()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: Failed to open database, an absolute path must be provided.";
        return false;
    }

    if (!dir.isReadable()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: Failed to open database, invalid path provided.";
        return false;
    }

    CBLDatabaseConfiguration db_config = {database_path_.c_str(), kCBLDatabase_Create};

    // Official CBL API: Database CTOR can throw so this is wrapped in try/catch
    try {
        database_ = std::make_unique<cbl::Database>(database_name_.c_str(), db_config);
    } catch (CBLError) {
        qCCritical(logCategoryCouchbaseDatabase) << "Problem with initialization of database.";
        return false;
    }

    if (!database_ || !database_->valid()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Problem with initialization of database.";
        return false;
    }
    return true;
}

bool CouchbaseDatabase::save(CouchbaseDocument *doc) {
    // Official CBL API: Save operation can throw so this is wrapped in try/catch
    try {
        database_->saveDocument(*doc->mutable_doc_.get());
    } catch (CBLError) {
        qCCritical(logCategoryCouchbaseDatabase) << "Problem saving database.";
        return false;
    }
    return true;
}

std::string CouchbaseDatabase::getDocumentAsStr(const std::string &id)
{
    return database_->getDocument(id).propertiesAsJSON();
}

QJsonObject CouchbaseDatabase::getDocumentAsJsonObj(const std::string &id)
{
    cbl::Document d = database_->getMutableDocument(id);
    fleece::Dict read_dict = d.properties();
    return QJsonDocument::fromJson(QString::fromStdString(read_dict.toJSONString()).toUtf8()).object();
}

QJsonObject CouchbaseDatabase::getDatabaseAsJsonObj() {
    QJsonObject total_db_object;
    auto keys = getAllDocumentKeys();
    for (const auto key : keys) {
        total_db_object.insert(QString::fromStdString(key), getDocumentAsJsonObj(key));
    }
    return total_db_object;
}

std::vector<std::string> CouchbaseDatabase::getAllDocumentKeys() {
    std::vector<std::string> keys;
    cbl::Query query_1(*database_.get(), kCBLN1QLLanguage, "SELECT _id");
    cbl::ResultSet results = query_1.execute();
    for(cbl::ResultSetIterator it = results.begin(); it != results.end(); ++it) {
        cbl::Result r = *it;
        fleece::slice value_sl = r.valueAtIndex(0).asString();
        keys.push_back(std::string(value_sl));
    }
    return keys;
}

// bool CouchbaseDatabase::startReplicator(const std::string &url, const std::string &username, const std::string &password,
//                                 const std::vector<std::string> &channels, const ReplicatorType &replicator_type,
//                                 const ConflictResolutionPolicy &conflict_resolution_policy, const ReconnectionPolicy &reconnection_policy) {

//     if (url.empty()) {
//         qCCritical(logCategoryCouchbaseDatabase) << "Error: Failed to start replicator, URL endpoint may not be empty.";
//         return false;
//     }

//     if (username.empty() && !password.empty()) {
//         qCCritical(logCategoryCouchbaseDatabase) << "Error: username may not be empty if a password is provided.";
//         return false;
//     }

//     url_endpoint_ = std::make_unique<SGURLEndpoint>(url);

//     if (!url_endpoint_->init()) {
//         qCCritical(logCategoryCouchbaseDatabase) << "Invalid replicator endpoint URL.";
//         return false;
//     }

//     sg_replicator_configuration_ = std::make_unique<SGReplicatorConfiguration>(database_.get(), url_endpoint_.get());

//     if (!username.empty()) {
//         basic_authenticator_ = std::make_unique<Strata::SGBasicAuthenticator>(username, password);
//         sg_replicator_configuration_->setAuthenticator(basic_authenticator_.get());
//     }

//     switch (replicator_type) {
//         case ReplicatorType::kPull:
//             sg_replicator_configuration_->setReplicatorType(SGReplicatorConfiguration::ReplicatorType::kPull);
//         case ReplicatorType::kPush:
//             sg_replicator_configuration_->setReplicatorType(SGReplicatorConfiguration::ReplicatorType::kPush);
//         default:
//             sg_replicator_configuration_->setReplicatorType(SGReplicatorConfiguration::ReplicatorType::kPushAndPull);
//     }

//     switch (conflict_resolution_policy) {
//         case ConflictResolutionPolicy::kResolveToRemoteRevision:
//             sg_replicator_configuration_->setConflictResolutionPolicy(SGReplicatorConfiguration::ConflictResolutionPolicy::kResolveToRemoteRevision);
//         default:
//             sg_replicator_configuration_->setConflictResolutionPolicy(SGReplicatorConfiguration::ConflictResolutionPolicy::kDefaultBehavior);
//     }

//     switch (reconnection_policy) {
//         case ReconnectionPolicy::kAutomaticallyReconnect:
//             sg_replicator_configuration_->setReconnectionPolicy(SGReplicatorConfiguration::ReconnectionPolicy::kAutomaticallyReconnect);
//         default:
//             sg_replicator_configuration_->setReconnectionPolicy(SGReplicatorConfiguration::ReconnectionPolicy::kDefaultBehavior);
//     }

//     if (!channels.empty()) {
//         sg_replicator_configuration_->setChannels(channels);
//     }

//     sg_replicator_ = std::make_unique<SGReplicator>(sg_replicator_configuration_.get());

//     sg_replicator_->addChangeListener(std::bind(&CouchbaseDatabase::replicatorStatusChanged, this, std::placeholders::_1));

//     sg_replicator_->addDocumentEndedListener(std::bind(&CouchbaseDatabase::documentStatusChanged, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3, std::placeholders::_4, std::placeholders::_5));

//     if (sg_replicator_->start() != SGReplicatorReturnStatus::kNoError) {
//         qCWarning(logCategoryCouchbaseDatabase) << "Replicator start failed.";
//         return false;
//     }

//     return true;
// }

// void CouchbaseDatabase::replicatorStatusChanged(const Strata::SGReplicator::ActivityLevel &level) {
//     activity_level_ = level;
//     if (on_replicator_status_changed_callback_) {
//         // on_replicator_status_changed_callback_(level);
//         on_replicator_status_changed_callback_(level, shared_db_);
//     } else {
//         std::cout << "\n{VICTOR} No callback to call.\n\n";
//     }
// }

// void CouchbaseDatabase::documentStatusChanged(const bool &pushing, const std::string &doc_id, const std::string &error_message, const bool &is_error, const bool &error_is_transient) {
//     if (on_document_status_changed_callback_) {
//         on_document_status_changed_callback_(pushing, doc_id, error_message, is_error, error_is_transient);
//     }
// }

std::string CouchbaseDatabase::getDatabaseName() {
    return database_name_;
}

std::string CouchbaseDatabase::getDatabasePath() {
    return database_path_;
}

// // void CouchbaseDatabase::setReplicatorStatusChangeListener(std::function<void(Strata::SGReplicator::ActivityLevel)> on_replicator_status_changed_callback) {
// //     on_replicator_status_changed_callback_ = on_replicator_status_changed_callback;
// // }

// void CouchbaseDatabase::setReplicatorStatusChangeListener(std::function<void(Strata::SGReplicator::ActivityLevel, Database* db)> on_replicator_status_changed_callback, Database* db) {
//     on_replicator_status_changed_callback_ = on_replicator_status_changed_callback;
//     shared_db_ = db;
// }

// void CouchbaseDatabase::setDocumentStatusChangeListener(std::function<void(bool, std::string, std::string, bool, bool)> on_document_status_changed_callback) {
//     on_document_status_changed_callback_ = on_document_status_changed_callback;
// }

// Strata::SGReplicator::ActivityLevel CouchbaseDatabase::getReplicatorActivityLevel() {
//     return activity_level_;
// }