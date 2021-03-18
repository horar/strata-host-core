#include "logging/LoggingQtCategories.h"
#include "CouchbaseDatabase.h"

#include <string>
#include <thread>

#include <QDir>
#include <QJsonDocument>
#include <QJsonArray>

CouchbaseDatabase::CouchbaseDatabase(const std::string &db_name, const std::string &db_path, QObject *parent) : QObject(parent), database_name_(db_name), database_path_(db_path) {
}

CouchbaseDatabase::~CouchbaseDatabase() {
    stopReplicator();
}

bool CouchbaseDatabase::open() {
    if (database_) {
        qCCritical(logCategoryCouchbaseDatabase) << "Failed to open database (database may already be open).";
        return false;
    }

    if (database_name_.empty()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Database may not have empty name.";
        return false;
    }

    if (database_path_.empty()) {
        database_path_ = QDir::currentPath().toStdString();
    }

    QDir dir(QString::fromStdString(database_path_));
    if (dir.isAbsolute() == false) {
        qCCritical(logCategoryCouchbaseDatabase) << "Failed to open database, an absolute path must be provided.";
        return false;
    }

    if (dir.isReadable() == false) {
        qCCritical(logCategoryCouchbaseDatabase) << "Failed to open database, invalid path provided.";
        return false;
    }

    CBLDatabaseConfiguration db_config = {database_path_.c_str(), kCBLDatabase_Create, nullptr};

    // Official CBL API: Database CTOR can throw so this is wrapped in try/catch
    try {
        database_ = std::make_unique<cbl::Database>(database_name_.c_str(), db_config);
    } catch (CBLError err) {
        qCCritical(logCategoryCouchbaseDatabase) << "Problem with initialization of database. Error code:" << err.code << ", domain:" << err.domain << ", info:" << err.internal_info;
        return false;
    }

    if (database_ == nullptr || database_->valid() == false) {
        qCCritical(logCategoryCouchbaseDatabase) << "Problem with initialization of database.";
        return false;
    }
    return true;
}

bool CouchbaseDatabase::close() {
    if (database_ == nullptr) {
        qCCritical(logCategoryCouchbaseDatabase) << "Cannot close database (database not initialized).";
        return false;
    }
    try {
        database_->close();
    } catch (CBLError err) {
        qCCritical(logCategoryCouchbaseDatabase) << "Problem closing database. Error code:" << err.code << ", domain:" << err.domain << ", info:" << err.internal_info;
        return false;
    }
    return true;
}

bool CouchbaseDatabase::save(CouchbaseDocument *doc) {
    if (database_ == nullptr) {
        qCCritical(logCategoryCouchbaseDatabase) << "Problem saving database, verify database is valid and open.";
        return false;
    }

    // Official CBL API: Save operation can throw so this is wrapped in try/catch
    try {
        database_->saveDocument(*doc->mutable_doc_.get());
    } catch (CBLError err) {
        qCCritical(logCategoryCouchbaseDatabase) << "Problem saving database. Error code:" << err.code << ", domain:" << err.domain << ", info:" << err.internal_info;
        return false;
    }
    return true;
}

bool CouchbaseDatabase::documentExistInDB(const std::string &id) {
    std::string str = "SELECT _id WHERE _id = '" + id + "'";
    cbl::Query query(*database_.get(), kCBLN1QLLanguage, str.c_str());
    auto results = query.execute();
    return results.begin() != results.end();
}

bool CouchbaseDatabase::deleteDoc(const std::string &id) {
    if (documentExistInDB(id) == false) {
        qCCritical(logCategoryCouchbaseDatabase) << "Problem deleting document: not found in DB.";
        return false;
    }
    try {
        auto temp_doc = database_->getMutableDocument(id);
        temp_doc.deleteDoc();
        database_->saveDocument(temp_doc);
    } catch (CBLError err) {
        qCCritical(logCategoryCouchbaseDatabase) << "Problem deleting document. Error code:" << err.code << ", domain:" << err.domain << ", info:" << err.internal_info;
        return false;
    }
    return true;
}

std::string CouchbaseDatabase::getDocumentAsStr(const std::string &id) {
    if (database_ == nullptr) {
        qCCritical(logCategoryCouchbaseDatabase) << "Problem reading document, verify database is valid and open.";
        return "";
    }
    if (documentExistInDB(id) == false) {
        qCCritical(logCategoryCouchbaseDatabase) << "Problem reading document: not found in DB.";
        return "";
    }
    return database_->getDocument(id).propertiesAsJSON();
}

QJsonObject CouchbaseDatabase::getDocumentAsJsonObj(const std::string &id) {
    if (database_ == nullptr) {
        qCCritical(logCategoryCouchbaseDatabase) << "Problem reading document, verify database is valid and open.";
        return QJsonObject();
    }
    auto doc = database_->getMutableDocument(id);
    if (doc.valid() == false) {
        qCCritical(logCategoryCouchbaseDatabase) << "Problem reading document: not found in DB.";
        return QJsonObject();
    }
    auto doc_json = doc.properties();
    return QJsonDocument::fromJson(QString::fromStdString(doc_json.toJSONString()).toUtf8()).object();
}

QJsonObject CouchbaseDatabase::getDatabaseAsJsonObj() {
    if (database_ == nullptr) {
        qCCritical(logCategoryCouchbaseDatabase) << "Failed to read database, verify database is valid and open.";
        return QJsonObject();
    }
    QJsonObject total_db_object;
    auto keys = getAllDocumentKeys();
    for (const auto &key : keys) {
        total_db_object.insert(QString::fromStdString(key), getDocumentAsJsonObj(key));
    }
    return total_db_object;
}

std::vector<std::string> CouchbaseDatabase::getAllDocumentKeys() {
    if (database_ == nullptr) {
        qCCritical(logCategoryCouchbaseDatabase) << "Failed to read database, verify database is valid and open.";
        return std::vector<std::string>();
    }
    std::vector<std::string> keys;
    cbl::Query query(*database_.get(), kCBLN1QLLanguage, "SELECT _id");
    auto results = query.execute();
    for(auto it = results.begin(); it != results.end(); ++it) {
        auto r = *it;
        auto value_sl = r.valueAtIndex(0).asString();
        keys.push_back(std::string(value_sl));
    }
    return keys;
}

bool CouchbaseDatabase::startSessionReplicator(const std::string &url, const std::string &token, const std::string &cookieName,
                                const std::vector<std::string> &channels, const ReplicatorType &replicatorType,
                                std::function<void(cbl::Replicator rep, const CBLReplicatorStatus &status)> change_listener_callback,
                                std::function<void(cbl::Replicator, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents)> document_listener_callback,
                                bool continuous) {

    if (database_ == nullptr) {
        qCCritical(logCategoryCouchbaseDatabase) << "Failed to start replicator, verify DB is valid and open.";
        return false;
    }

    if (url.empty()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Failed to start replicator, URL endpoint may not be empty.";
        return false;
    }

    if (token.empty() || cookieName.empty()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Failed to start replicator, token and cookie name may not be empty.";
        return false;
    }

    replicator_configuration_ = std::make_unique<cbl::ReplicatorConfiguration>(*database_.get());

    // Set the endpoint URL to connect to
    replicator_configuration_->endpoint.setURL(url.c_str());

    replicator_configuration_->authenticator.setSession(token.c_str(), cookieName.c_str());

    switch (replicatorType) {
        case ReplicatorType::kPull:
            replicator_configuration_->replicatorType = kCBLReplicatorTypePull;
        case ReplicatorType::kPush:
            replicator_configuration_->replicatorType = kCBLReplicatorTypePush;
        default:
            replicator_configuration_->replicatorType = kCBLReplicatorTypePushAndPull;
    }

    if (channels.empty() == false) {
        auto channels_temp = fleece::MutableArray::newArray();
        for (auto &channel : channels) {
            channels_temp.append(channel);
        }
        replicator_configuration_->channels = channels_temp;
    }

    replicator_configuration_->continuous = continuous;

    // Official CBL API: Replicator CTOR can throw so this is wrapped in try/catch
    try {
        replicator_ = std::make_unique<cbl::Replicator>(*replicator_configuration_.get());
    } catch (CBLError err) {
        qCCritical(logCategoryCouchbaseDatabase) << "Problem with initialization of replicator. Error code: " << err.code << ", domain: " << err.domain << ", info: " << err.internal_info;
        return false;
    }

    if (change_listener_callback) {
        ctoken_ = std::make_unique<cbl::Replicator::ChangeListener>(replicator_->addChangeListener(std::bind(&CouchbaseDatabase::replicatorStatusChanged, this, std::placeholders::_1, std::placeholders::_2)));
        latest_replication_.change_listener_callback = change_listener_callback;
    }

    if (document_listener_callback) {
        dtoken_ = std::make_unique<cbl::Replicator::DocumentListener>(replicator_->addDocumentListener(std::bind(&CouchbaseDatabase::documentStatusChanged, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3)));
        latest_replication_.document_listener_callback = document_listener_callback;
    }

    replicator_->start();
    return true;
}

bool CouchbaseDatabase::startBasicReplicator(const std::string &url, const std::string &username, const std::string &password,
                                const std::vector<std::string> &channels, const ReplicatorType &replicatorType,
                                std::function<void(cbl::Replicator rep, const CBLReplicatorStatus &status)> change_listener_callback,
                                std::function<void(cbl::Replicator, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents)> document_listener_callback,
                                bool continuous) {
    if (database_ == nullptr) {
        qCCritical(logCategoryCouchbaseDatabase) << "Failed to start replicator, verify DB is valid and open.";
        return false;
    }

    if (url.empty()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Failed to start replicator, URL endpoint may not be empty.";
        return false;
    }

    if (username.empty() && !password.empty()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Username may not be empty if a password is provided.";
        return false;
    }

    replicator_configuration_ = std::make_unique<cbl::ReplicatorConfiguration>(*database_.get());

    // Set the endpoint URL to connect to
    replicator_configuration_->endpoint.setURL(url.c_str());

    // Set the username and password for authentication
    if (username.empty() == false) {
        replicator_configuration_->authenticator.setBasic(username.c_str(), password.c_str());
    }

    switch (replicatorType) {
        case ReplicatorType::kPull:
            replicator_configuration_->replicatorType = kCBLReplicatorTypePull;
        case ReplicatorType::kPush:
            replicator_configuration_->replicatorType = kCBLReplicatorTypePush;
        default:
            replicator_configuration_->replicatorType = kCBLReplicatorTypePushAndPull;
    }

    if (channels.empty() == false) {
        auto channels_temp = fleece::MutableArray::newArray();
        for (auto &channel : channels) {
            channels_temp.append(channel);
        }
        replicator_configuration_->channels = channels_temp;
    }

    replicator_configuration_->continuous = continuous;

    // Official CBL API: Replicator CTOR can throw so this is wrapped in try/catch
    try {
        replicator_ = std::make_unique<cbl::Replicator>(*replicator_configuration_.get());
    } catch (CBLError err) {
        qCCritical(logCategoryCouchbaseDatabase) << "Problem with initialization of replicator. Error code: " << err.code << ", domain: " << err.domain << ", info: " << err.internal_info;
        return false;
    }

    latest_replication_.url = url;
    latest_replication_.username = username;
    latest_replication_.password = password;
    latest_replication_.channels = channels;
    latest_replication_.replicatorType = replicatorType;

    if (change_listener_callback) {
        ctoken_ = std::make_unique<cbl::Replicator::ChangeListener>(replicator_->addChangeListener(std::bind(&CouchbaseDatabase::replicatorStatusChanged, this, std::placeholders::_1, std::placeholders::_2)));
        latest_replication_.change_listener_callback = change_listener_callback;
    }

    if (document_listener_callback) {
        dtoken_ = std::make_unique<cbl::Replicator::DocumentListener>(replicator_->addDocumentListener(std::bind(&CouchbaseDatabase::documentStatusChanged, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3)));
        latest_replication_.document_listener_callback = document_listener_callback;
    }

    replicator_->start();
    return true;
}

void CouchbaseDatabase::stopReplicator() {
    if (database_ == nullptr) {
        return;
    }
    if (replicator_) {
        replicator_->stop();
    }
    latest_replication_.reset();
}

void CouchbaseDatabase::joinChannel(const QString &strataLoginUsername, const QString &channel) {
    auto temp_doc = database_->getMutableDocument(database_name_);
    auto read_dict = temp_doc.properties();

    QJsonDocument json_doc = QJsonDocument::fromJson(QString::fromStdString(read_dict.toJSONString()).toUtf8());
    QJsonArray channels_arr = json_doc[channel].toArray();
    channels_arr.append(strataLoginUsername);

    QJsonObject json_obj = json_doc.object();
    json_obj.insert(channel, channels_arr);
    QJsonDocument final_Doc(json_obj);

    temp_doc.setPropertiesAsJSON(final_Doc.toJson(QJsonDocument::Compact));
    database_->saveDocument(temp_doc);
}

void CouchbaseDatabase::leaveChannel(const QString &strataLoginUsername, const QString &channel) {
    auto temp_doc = database_->getMutableDocument(database_name_);
    auto read_dict = temp_doc.properties();

    QJsonDocument json_doc = QJsonDocument::fromJson(QString::fromStdString(read_dict.toJSONString()).toUtf8());
    QJsonArray channels_arr = json_doc[channel].toArray();

    // find matching value
    int ctr = 0;
    for(auto it = channels_arr.begin(); it != channels_arr.end(); ++it) {
        QJsonValue this_value = *it;
        if (!this_value.isString()) {
            qCCritical(logCategoryCouchbaseDatabase) << "Error: channel is not in string format";
            continue;
        }
        if (this_value.toString() == strataLoginUsername) {
            qCCritical(logCategoryCouchbaseDatabase) << "Found channel, removing: " << this_value.toString();
            channels_arr.removeAt(ctr);
            break;
        }
        ++ctr;
    }

    QJsonObject json_obj = json_doc.object();
    json_obj.insert(channel, channels_arr);
    QJsonDocument final_Doc(json_obj);

    temp_doc.setPropertiesAsJSON(final_Doc.toJson(QJsonDocument::Compact));
    database_->saveDocument(temp_doc);
}

void CouchbaseDatabase::replicatorStatusChanged(cbl::Replicator rep, const CBLReplicatorStatus &status) {
    error_code_ = rep.status().error.code;

    // Set status as string for easy interfacing
    switch (status.activity) {
        case CBLReplicatorActivityLevel::kCBLReplicatorStopped:
            // Check status for error, set retry flag
            if (is_retry_) {
                startBasicReplicator(latest_replication_.url, latest_replication_.username, latest_replication_.password, latest_replication_.channels, latest_replication_.replicatorType,
                    latest_replication_.change_listener_callback, latest_replication_.document_listener_callback);
                return;
            }
            status_ = "Stopped";
            break;
        case CBLReplicatorActivityLevel::kCBLReplicatorOffline:
            status_ = "Offline";
            break;
        case CBLReplicatorActivityLevel::kCBLReplicatorConnecting:
            status_ = "Connecting";
            break;
        case CBLReplicatorActivityLevel::kCBLReplicatorIdle:
            status_ = "Idle";
            break;
        case CBLReplicatorActivityLevel::kCBLReplicatorBusy:
            status_ = "Busy";
            break;
    }

    if (rep.status().error.code != 0) {
        qCCritical(logCategoryCouchbaseDatabase) << "Received replicator error code:" << rep.status().error.code <<
            ", domain:" << rep.status().error.domain << ", info:" << rep.status().error.internal_info;
        if (rep.status().error.domain == 2 && rep.status().error.code == 5) {
            is_retry_ = true;
            return;
        }
    }

    is_retry_ = false;

    if (latest_replication_.change_listener_callback) {
        latest_replication_.change_listener_callback(rep, status);
    }
}

void CouchbaseDatabase::documentStatusChanged(cbl::Replicator rep, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents) {
    if (latest_replication_.document_listener_callback) {
        latest_replication_.document_listener_callback(rep, isPush, documents);
    }
}

std::string CouchbaseDatabase::getDatabaseName() {
    return database_name_;
}

std::string CouchbaseDatabase::getDatabasePath() {
    return database_path_;
}

std::string CouchbaseDatabase::getReplicatorStatus() {
    return status_;
}

int CouchbaseDatabase::getReplicatorError() {
    if (is_retry_ && error_code_ != 0) {
        return 0;
    }
    return error_code_;
}

void CouchbaseDatabase::setLogLevel(const QString &level) {
    if (level == "debug") {
        CBLLog_SetConsoleLevel(CBLLogDebug);
    } else if (level == "verbose") {
        CBLLog_SetConsoleLevel(CBLLogVerbose);
    } else if (level == "info") {
        CBLLog_SetConsoleLevel(CBLLogInfo);
    } else if (level == "warning") {
        CBLLog_SetConsoleLevel(CBLLogWarning);
    } else if (level == "error") {
        CBLLog_SetConsoleLevel(CBLLogError);
    } else if (level == "none") {
        CBLLog_SetConsoleLevel(CBLLogNone);
    } else {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: unknown log level";
    }
}

void CouchbaseDatabase::setLogCallback(void (*callback)(CBLLogDomain domain, CBLLogLevel level, const char *message)) {
    if (callback) {
        CBLLog_SetCallback(callback);
    } else {
        CBLLog_SetCallback(CouchbaseDatabase::logReceived);
    }
}

void CouchbaseDatabase::logReceived(CBLLogDomain /*domain*/, CBLLogLevel /*level*/, const char *message) {
    qCCritical(logCategoryCouchbaseDatabase) << "Received Couchbase log" << message;
}
