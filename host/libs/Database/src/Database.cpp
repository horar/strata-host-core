#include "logging/LoggingQtCategories.h"
#include "Database.h"

Database::Database(const QString &db_name, const QString &db_path, QObject *parent) {
    database_ = std::make_unique<CouchbaseDatabase>(db_name.toStdString(), db_path.toStdString(), parent);
}

bool Database::open() {
    return database_->open();
}

bool Database::close() {
    return database_->close();
}

bool Database::save(CouchbaseDocument *doc) {
    return database_->save(doc);
}

bool Database::deleteDoc(const QString &id) {
    return database_->deleteDoc(id.toStdString());
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
    auto key_vector = database_->getAllDocumentKeys();
    QStringList list;
    for (const auto &key : key_vector) {
        list << QString::fromStdString(key);
    }
    return list;
}

bool Database::startReplicator(const QString &url, const QString &username, const QString &password, const QStringList &channels,
                               const QString &replicator_type, std::function<void(cbl::Replicator rep, const CBLReplicatorStatus &status)> changeListener,
                               std::function<void(cbl::Replicator rep, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents)> documentListener,
                               bool continuous) {

    auto _url = url.toStdString();
    auto _username = username.toStdString();
    auto _password = password.toStdString();

    std::vector<std::string> _channels;
    for (const auto &channel : channels) {
        _channels.push_back(channel.toStdString());
    }

    CouchbaseDatabase::ReplicatorType _replicator_type;
    if (replicator_type.isEmpty() || replicator_type == "pull") {
        _replicator_type = CouchbaseDatabase::ReplicatorType::kPull;
    } else if (replicator_type == "push") {
        _replicator_type = CouchbaseDatabase::ReplicatorType::kPush;
    } else if (replicator_type == "pushandpull") {
        _replicator_type = CouchbaseDatabase::ReplicatorType::kPushAndPull;
    } else {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: Failed to start replicator, invalid replicator type provided.";
    }

    if (changeListener) {
        change_listener_callback = changeListener;
    } else {
        change_listener_callback = std::bind(&Database::default_changeListener, this, std::placeholders::_1, std::placeholders::_2);
    }

    if (documentListener) {
        document_listener_callback = documentListener;
    } else {
        document_listener_callback = std::bind(&Database::default_documentListener, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3);
    }

    if (database_->startReplicator(_url, _username, _password, _channels, _replicator_type, change_listener_callback, document_listener_callback, continuous)) {
        return true;
    }

    return false;
}

void Database::stopReplicator() {
    database_->stopReplicator();
}

QString Database::getReplicatorStatus() {
    return QString::fromStdString(database_->getReplicatorStatus());
}

int Database::getReplicatorError() {
    return database_->getReplicatorError();
}

void Database::default_changeListener(cbl::Replicator, const CBLReplicatorStatus &status) {
    qCInfo(logCategoryCouchbaseDatabase) << "--- PROGRESS: status=" << status.activity << ", fraction=" << status.progress.fractionComplete << ", err=" << status.error.domain << "/" << status.error.code;
}

void Database::default_documentListener(cbl::Replicator, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents) {
    qCInfo(logCategoryCouchbaseDatabase) << "--- " << documents.size() << " docs " << (isPush ? "pushed" : "pulled") << ":";
    for (unsigned i = 0; i < documents.size(); ++i) {
        qCInfo(logCategoryCouchbaseDatabase) << " " << documents[i].ID;
    }
}
