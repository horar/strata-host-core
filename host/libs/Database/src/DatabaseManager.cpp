#include "logging/LoggingQtCategories.h"
#include "DatabaseManager.h"

#include <QDebug>

DatabaseAccess* DatabaseManager::open(const QString &channel_access, const QString &database_prefix) {
    db_access_ = new DatabaseAccess();
    db_access_->channel_access_ = channel_access;

    std::string database_name = channel_access.toStdString();
    if (!database_prefix.isEmpty()) {
        database_name = database_prefix.toStdString() + "_" + database_name;
    }

    db_access_->database_ = std::make_unique<CouchbaseDatabase>(database_name);

    if (db_access_->database_->open()) {
        return db_access_;
    }
    return nullptr;
}

bool DatabaseAccess::close() {
    if (!database_) {
        qCCritical(logCategoryCouchbaseDatabase) << "Cannot close database (database does not exist).";
        return false;
    }
    return database_->close();
}

bool DatabaseAccess::write(CouchbaseDocument *doc) {
    // Tag 'channels' field
    doc->tagChannelField(channel_access_.toStdString());
    return database_->save(doc);
}

QString DatabaseAccess::getChannelAccess() {
    return channel_access_;
}

bool DatabaseAccess::deleteDoc(const QString &id) {
    return database_->deleteDoc(id.toStdString());
}

QString DatabaseAccess::getDocumentAsStr(const QString &id) {
    return QString::fromStdString(database_->getDocumentAsStr(id.toStdString()));
}

QJsonObject DatabaseAccess::getDocumentAsJsonObj(const QString &id) {
    return database_->getDocumentAsJsonObj(id.toStdString());
}

QJsonObject DatabaseAccess::getDatabaseAsJsonObj() {
    return database_->getDatabaseAsJsonObj();
}

QString DatabaseAccess::getDatabaseName() {
    return QString::fromStdString(database_->getDatabaseName());
}

QString DatabaseAccess::getDatabasePath() {
    return QString::fromStdString(database_->getDatabasePath());
}

QStringList DatabaseAccess::getAllDocumentKeys() {
    auto key_vector = database_->getAllDocumentKeys();
    QStringList list;
    for (const auto key : key_vector) {
        list << QString::fromStdString(key);
    }
    return list;
}

bool DatabaseAccess::startReplicator(const QString &url, const QString &username, const QString &password, const QString &replicator_type,
                               std::function<void(cbl::Replicator rep, const CBLReplicatorStatus &status)> changeListener,
                               std::function<void(cbl::Replicator rep, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents)> documentListener,
                               bool continuous) {

    auto _url = url.toStdString();
    auto _username = username.toStdString();
    auto _password = password.toStdString();

    std::vector<std::string> _channels{channel_access_.toStdString()};

    CouchbaseDatabase::ReplicatorType _replicator_type;
    if (replicator_type.isEmpty() || replicator_type == "pull") {
        _replicator_type = CouchbaseDatabase::ReplicatorType::kPull;
    } else if (replicator_type == "push") {
        _replicator_type = CouchbaseDatabase::ReplicatorType::kPush;
    } else if (replicator_type == "pushandpull") {
        _replicator_type = CouchbaseDatabase::ReplicatorType::kPushAndPull;
    } else {
        qDebug() << "Error: Failed to start replicator, invalid replicator type provided.";
    }

    if (changeListener) {
        change_listener_callback = changeListener;
    } else {
        change_listener_callback = std::bind(&DatabaseAccess::default_changeListener, this, std::placeholders::_1, std::placeholders::_2);
    }

    if (documentListener) {
        document_listener_callback = documentListener;
    } else {
        document_listener_callback = std::bind(&DatabaseAccess::default_documentListener, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3);
    }

    if (database_->startReplicator(_url, _username, _password, _channels, _replicator_type, change_listener_callback, document_listener_callback, continuous)) {
        return true;
    }

    return false;
}

void DatabaseAccess::stopReplicator() {
    database_->stopReplicator();
}

QString DatabaseAccess::getReplicatorStatus() {
    return QString::fromStdString(database_->getReplicatorStatus());
}

int DatabaseAccess::getReplicatorError() {
    return database_->getReplicatorError();
}

void DatabaseAccess::default_changeListener(cbl::Replicator, const CBLReplicatorStatus &status) {
    qDebug() << "--- PROGRESS: status=" << status.activity << ", fraction=" << status.progress.fractionComplete << ", err=" << status.error.domain << "/" << status.error.code;
}

void DatabaseAccess::default_documentListener(cbl::Replicator, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents) {
    qDebug() << "--- " << documents.size() << " docs " << (isPush ? "pushed" : "pulled") << ":";
    for (unsigned i = 0; i < documents.size(); ++i) {
        qDebug() << " " << documents[i].ID;
    }
}
