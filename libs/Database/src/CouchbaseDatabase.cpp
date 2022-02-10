/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "logging/LoggingQtCategories.h"
#include "CouchbaseDatabase.h"
#include "Database/CouchbaseDocument.h"

#include <string>
#include <thread>

#include <QDir>
#include <QJsonDocument>
#include <QJsonArray>

using namespace strata::Database;

CouchbaseDatabase::CouchbaseDatabase(const std::string &db_name, const std::string &db_path, QObject *parent) : QObject(parent), database_name_(db_name), database_path_(db_path) {

}

CouchbaseDatabase::~CouchbaseDatabase() {
    stopReplicator();
}

bool CouchbaseDatabase::open() {
    if (database_) {
        qCCritical(lcCouchbaseDatabase) << "Failed to open database (database may already be open).";
        return false;
    }

    if (database_name_.empty()) {
        qCCritical(lcCouchbaseDatabase) << "Database may not have empty name.";
        return false;
    }

    if (database_path_.empty()) {
        database_path_ = QDir::currentPath().toStdString();
    }

    QDir dir(QString::fromStdString(database_path_));
    if (dir.isAbsolute() == false) {
        qCCritical(lcCouchbaseDatabase) << "Failed to open database, an absolute path must be provided.";
        return false;
    }

    if (dir.isReadable() == false) {
        qCCritical(lcCouchbaseDatabase) << "Failed to open database, invalid path provided.";
        return false;
    }

    CBLDatabaseConfiguration db_config = {database_path_.c_str(), kCBLDatabase_Create, nullptr};

    // Official CBL API: Database CTOR can throw so this is wrapped in try/catch
    try {
        database_ = std::make_unique<cbl::Database>(database_name_.c_str(), db_config);
    } catch (CBLError err) {
        qCCritical(lcCouchbaseDatabase) << "Problem with initialization of database. Error code:" << err.code << ", domain:" << err.domain << ", info:" << err.internal_info;
        return false;
    }

    if (database_ == nullptr || database_->valid() == false) {
        qCCritical(lcCouchbaseDatabase) << "Problem with initialization of database.";
        return false;
    }
    return true;
}

bool CouchbaseDatabase::close() {
    if (database_ == nullptr) {
        qCCritical(lcCouchbaseDatabase) << "Cannot close database (database not initialized).";
        return false;
    }
    try {
        database_->close();
    } catch (CBLError err) {
        qCCritical(lcCouchbaseDatabase) << "Problem closing database. Error code:" << err.code << ", domain:" << err.domain << ", info:" << err.internal_info;
        return false;
    }
    return true;
}

bool CouchbaseDatabase::save(CouchbaseDocument *doc) {
    if (database_ == nullptr) {
        qCCritical(lcCouchbaseDatabase) << "Problem saving database, verify database is valid and open.";
        return false;
    }

    // Official CBL API: Save operation can throw so this is wrapped in try/catch
    try {
        database_->saveDocument(*doc->mutable_doc_.get());
    } catch (CBLError err) {
        qCCritical(lcCouchbaseDatabase) << "Problem saving database. Error code:" << err.code << ", domain:" << err.domain << ", info:" << err.internal_info;
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
        qCCritical(lcCouchbaseDatabase) << "Problem deleting document: not found in DB.";
        return false;
    }
    try {
        auto temp_doc = database_->getMutableDocument(id);
        temp_doc.deleteDoc();
        database_->saveDocument(temp_doc);
    } catch (CBLError err) {
        qCCritical(lcCouchbaseDatabase) << "Problem deleting document. Error code:" << err.code << ", domain:" << err.domain << ", info:" << err.internal_info;
        return false;
    }
    return true;
}

std::string CouchbaseDatabase::getDocumentAsStr(const std::string &id) {
    if (database_ == nullptr) {
        qCCritical(lcCouchbaseDatabase) << "Problem reading document, verify database is valid and open.";
        return "";
    }
    if (documentExistInDB(id) == false) {
        qCCritical(lcCouchbaseDatabase) << "Problem reading document: not found in DB.";
        return "";
    }
    return database_->getDocument(id).propertiesAsJSON();
}

QJsonObject CouchbaseDatabase::getDocumentAsJsonObj(const std::string &id) {
    if (database_ == nullptr) {
        qCCritical(lcCouchbaseDatabase) << "Problem reading document, verify database is valid and open.";
        return QJsonObject();
    }
    auto doc = database_->getMutableDocument(id);
    if (doc.valid() == false) {
        qCCritical(lcCouchbaseDatabase) << "Problem reading document: not found in DB.";
        return QJsonObject();
    }
    auto doc_json = doc.properties();
    return QJsonDocument::fromJson(QByteArray::fromStdString(doc_json.toJSONString())).object();
}

QJsonObject CouchbaseDatabase::getDatabaseAsJsonObj() {
    if (database_ == nullptr) {
        qCCritical(lcCouchbaseDatabase) << "Failed to read database, verify database is valid and open.";
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
        qCCritical(lcCouchbaseDatabase) << "Failed to read database, verify database is valid and open.";
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

bool CouchbaseDatabase::startBasicReplicator(const std::string &url, const std::string &username, const std::string &password,
    const std::vector<std::string> &channels, const ReplicatorType &replicatorType,
    std::function<void(cbl::Replicator rep, const SGActivityLevel &status)> change_listener_callback,
    std::function<void(cbl::Replicator rep, bool isPush, const std::vector<SGReplicatedDocument, std::allocator<SGReplicatedDocument>> documents)> document_listener_callback,
    bool continuous) {

    if (database_ == nullptr) {
        qCCritical(lcCouchbaseDatabase) << "Failed to start replicator, verify DB is valid and open.";
        return false;
    }

    if (url.empty()) {
        qCCritical(lcCouchbaseDatabase) << "Failed to start replicator, URL endpoint may not be empty.";
        return false;
    }

    if (username.empty() && !password.empty()) {
        qCCritical(lcCouchbaseDatabase) << "Username may not be empty if a password is provided.";
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
            break;
        case ReplicatorType::kPush:
            replicator_configuration_->replicatorType = kCBLReplicatorTypePush;
            break;
        default:
            replicator_configuration_->replicatorType = kCBLReplicatorTypePushAndPull;
    }

    if (channels.empty() == false) {
        if (channels.size() != 1 || channels[0] != database_name_) {
            auto channels_temp = fleece::MutableArray::newArray();
            for (auto &channel : channels) {
                channels_temp.append(channel);
            }
            replicator_configuration_->channels = channels_temp;
        }
    }

    replicator_configuration_->continuous = continuous;

    // Official CBL API: Replicator CTOR can throw so this is wrapped in try/catch
    try {
        replicator_ = std::make_unique<cbl::Replicator>(*replicator_configuration_.get());
    } catch (CBLError err) {
        qCCritical(lcCouchbaseDatabase) << "Problem with initialization of replicator. Error code: " << err.code << ", domain: " << err.domain << ", info: " << err.internal_info;
        return false;
    }

    if (change_listener_callback) {
        ctoken_ = std::make_unique<cbl::Replicator::ChangeListener>(replicator_->addChangeListener(std::bind(&CouchbaseDatabase::replicatorStatusChanged, this, std::placeholders::_1, std::placeholders::_2)));
        change_listener_callback_ = change_listener_callback;
    }

    if (document_listener_callback) {
        dtoken_ = std::make_unique<cbl::Replicator::DocumentListener>(replicator_->addDocumentListener(std::bind(&CouchbaseDatabase::documentStatusChanged, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3)));
        document_listener_callback_ = document_listener_callback;
    }

    replicator_->start();
    return true;
}

bool CouchbaseDatabase::startSessionReplicator(const std::string &url, const std::string &token, const std::string &cookieName,
    const std::vector<std::string> &channels, const ReplicatorType &replicatorType,
    std::function<void(cbl::Replicator rep, const SGActivityLevel &status)> change_listener_callback,
    std::function<void(cbl::Replicator rep, bool isPush, const std::vector<SGReplicatedDocument, std::allocator<SGReplicatedDocument>> documents)> document_listener_callback,
    bool continuous) {

    if (database_ == nullptr) {
        qCCritical(lcCouchbaseDatabase) << "Failed to start replicator, verify DB is valid and open.";
        return false;
    }

    if (url.empty()) {
        qCCritical(lcCouchbaseDatabase) << "Failed to start replicator, URL endpoint may not be empty.";
        return false;
    }

    if (token.empty() || cookieName.empty()) {
        qCCritical(lcCouchbaseDatabase) << "Failed to start replicator, token and cookie name may not be empty.";
        return false;
    }

    replicator_configuration_ = std::make_unique<cbl::ReplicatorConfiguration>(*database_.get());

    // Set the endpoint URL to connect to
    replicator_configuration_->endpoint.setURL(url.c_str());

    // Set the token value and cookie name
    replicator_configuration_->authenticator.setSession(token.c_str(), cookieName.c_str());

    switch (replicatorType) {
        case ReplicatorType::kPull:
            replicator_configuration_->replicatorType = kCBLReplicatorTypePull;
            break;
        case ReplicatorType::kPush:
            replicator_configuration_->replicatorType = kCBLReplicatorTypePush;
            break;
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
        qCCritical(lcCouchbaseDatabase) << "Problem with initialization of replicator. Error code: " << err.code << ", domain: " << err.domain << ", info: " << err.internal_info;
        return false;
    }

    if (change_listener_callback) {
        ctoken_ = std::make_unique<cbl::Replicator::ChangeListener>(replicator_->addChangeListener(std::bind(&CouchbaseDatabase::replicatorStatusChanged, this, std::placeholders::_1, std::placeholders::_2)));
        change_listener_callback_ = change_listener_callback;
    }

    if (document_listener_callback) {
        dtoken_ = std::make_unique<cbl::Replicator::DocumentListener>(replicator_->addDocumentListener(std::bind(&CouchbaseDatabase::documentStatusChanged, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3)));
        document_listener_callback_ = document_listener_callback;
    }

    replicator_->start();
    return true;
}

void CouchbaseDatabase::stopReplicator() {
    if (database_ == nullptr || replicator_ == nullptr) {
        return;
    }

    if (repIsStopping_) {
        return;
    }

    replicator_->stop();
    repIsStopping_ = true;
}

void CouchbaseDatabase::freeReplicator() {
    if (replicator_ == nullptr) {
        return;
    }

    replicator_ = nullptr;
    ctoken_ = nullptr;
    dtoken_ = nullptr;

    repIsStopping_ = false;
}

void CouchbaseDatabase::joinChannel(const QString &strataLoginUsername, const QString &channel) {
    auto temp_doc = database_->getMutableDocument(database_name_);
    auto read_dict = temp_doc.properties();

    QJsonDocument json_doc = QJsonDocument::fromJson(QByteArray::fromStdString(read_dict.toJSONString()));
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

    QJsonDocument json_doc = QJsonDocument::fromJson(QByteArray::fromStdString(read_dict.toJSONString()));
    QJsonArray channels_arr = json_doc[channel].toArray();

    // find matching value
    int ctr = 0;
    for(auto it = channels_arr.begin(); it != channels_arr.end(); ++it) {
        QJsonValue this_value = *it;
        if (!this_value.isString()) {
            qCCritical(lcCouchbaseDatabase) << "Error: channel is not in string format";
            continue;
        }
        if (this_value.toString() == strataLoginUsername) {
            qCCritical(lcCouchbaseDatabase) << "Found channel, removing:" << this_value.toString();
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

    switch (status.activity) {
        case CBLReplicatorActivityLevel::kCBLReplicatorStopped:
            if (repIsStopping_) {
                freeReplicator();
            }

            status_ = SGActivityLevel::CBLReplicatorStopped;
            break;
        case CBLReplicatorActivityLevel::kCBLReplicatorOffline:
            status_ = SGActivityLevel::CBLReplicatorOffline;
            break;
        case CBLReplicatorActivityLevel::kCBLReplicatorConnecting:
            status_ = SGActivityLevel::CBLReplicatorConnecting;
            break;
        case CBLReplicatorActivityLevel::kCBLReplicatorIdle:
            status_ = SGActivityLevel::CBLReplicatorIdle;
            break;
        case CBLReplicatorActivityLevel::kCBLReplicatorBusy:
            status_ = SGActivityLevel::CBLReplicatorBusy;
            break;
    }

    if (change_listener_callback_) {
        change_listener_callback_(rep, status_);
    }
}

void CouchbaseDatabase::documentStatusChanged(cbl::Replicator rep, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents) {
    if (document_listener_callback_) {
        std::vector<SGReplicatedDocument, std::allocator<SGReplicatedDocument>> SGDocuments;
        for (const auto &doc : documents) {
            CouchbaseDatabase::SGReplicatedDocument SGDocument;
            SGDocument.id = doc.ID;
            SGDocument.error = doc.error.code;
            SGDocuments.push_back(SGDocument);
        }

        document_listener_callback_(rep, isPush, SGDocuments);
    }
}

std::string CouchbaseDatabase::getDatabaseName() {
    return database_name_;
}

std::string CouchbaseDatabase::getDatabasePath() {
    return database_path_;
}

CouchbaseDatabase::SGActivityLevel CouchbaseDatabase::getReplicatorStatus() {
    return status_;
}

std::string CouchbaseDatabase::getReplicatorStatusString() {
    switch (status_) {
        case SGActivityLevel::CBLReplicatorStopped:
            return "Stopped";
        case SGActivityLevel::CBLReplicatorOffline:
            return "Offline";
        case SGActivityLevel::CBLReplicatorConnecting:
            return "Connecting";
        case SGActivityLevel::CBLReplicatorIdle:
            return "Idle";
        case SGActivityLevel::CBLReplicatorBusy:
            return "Busy";
        default:
            return "";
    }
}

int CouchbaseDatabase::getReplicatorError() {
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
        qCCritical(lcCouchbaseDatabase) << "Error: unknown log level";
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
    qCCritical(lcCouchbaseDatabase) << "Received Couchbase log" << message;
}
