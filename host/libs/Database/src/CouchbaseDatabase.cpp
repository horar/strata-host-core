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
    auto d = database_->getMutableDocument(id);
    auto read_dict = d.properties();
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
    cbl::Query query(*database_.get(), kCBLN1QLLanguage, "SELECT _id");
    auto results = query.execute();
    for(auto it = results.begin(); it != results.end(); ++it) {
        auto r = *it;
        auto value_sl = r.valueAtIndex(0).asString();
        keys.push_back(std::string(value_sl));
    }
    return keys;
}

bool CouchbaseDatabase::startReplicator(const std::string &url, const std::string &username, const std::string &password,
                                const std::vector<std::string> &channels, const ReplicatorType &replicator_type,
                                std::function<void(cbl::Replicator rep, const CBLReplicatorStatus &status)> change_listener_callback,
                                std::function<void(cbl::Replicator, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents)> document_listener_callback) {

    if (url.empty()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: Failed to start replicator, URL endpoint may not be empty.";
        return false;
    }

    if (username.empty() && !password.empty()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: username may not be empty if a password is provided.";
        return false;
    }

    replicator_configuration_ = std::make_unique<cbl::ReplicatorConfiguration>(*database_.get());

    // Set the endpoint URL to connect to
    replicator_configuration_->endpoint.setURL(url.c_str());

    // Set the username and password for authentication
    if (!username.empty()) {
        replicator_configuration_->authenticator.setBasic(username.c_str(), password.c_str());
    }

    switch (replicator_type) {
        case ReplicatorType::kPull:
            replicator_configuration_->replicatorType = kCBLReplicatorTypePull;
        case ReplicatorType::kPush:
            replicator_configuration_->replicatorType = kCBLReplicatorTypePush;
        default:
            replicator_configuration_->replicatorType = kCBLReplicatorTypePushAndPull;
    }

    if (!channels.empty()) {
        auto ma = fleece::MutableArray::newArray();
        for (auto &x : channels) {
            ma.append(x);
        }
        replicator_configuration_->channels = ma;
    }

    replicator_ = std::make_unique<cbl::Replicator>(*replicator_configuration_.get());

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

void CouchbaseDatabase::replicatorStatusChanged(cbl::Replicator rep, const CBLReplicatorStatus &status) {
    if (change_listener_callback_) {
        change_listener_callback_(rep, status);
    }
}

void CouchbaseDatabase::documentStatusChanged(cbl::Replicator rep, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents) {
    if (document_listener_callback_) {
        document_listener_callback_(rep, isPush, documents);
    }
}

std::string CouchbaseDatabase::getDatabaseName() {
    return database_name_;
}

std::string CouchbaseDatabase::getDatabasePath() {
    return database_path_;
}