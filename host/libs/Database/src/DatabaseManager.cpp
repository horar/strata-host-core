#include "logging/LoggingQtCategories.h"
#include "DatabaseManager.h"

#include <QDir>
#include <QDebug>
#include <QCoreApplication>

DatabaseAccess* DatabaseManager::open(const QString &name, const QString &channel_access) {
    db_access_ = new DatabaseAccess();
    db_access_->name_ = name;

    QString channel_access_str;
    if (channel_access.isEmpty()) {
        db_access_->channel_access_ << name;
        channel_access_str = name;
    } else {
        db_access_->channel_access_ << channel_access;
        channel_access_str = channel_access;
    }

    auto userDir = createUserDirectory(name);
    if (userDir.isEmpty()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: failed to create database directory.";
        return nullptr;
    }

    auto db = std::make_unique<CouchbaseDatabase>(channel_access_str.toStdString(), userDir.toStdString());
    db_access_->database_map_.push_back(std::move(db));
    if (db_access_->database_map_.back()->open()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Opened bucket " << channel_access_str;
    } else {
        qCCritical(logCategoryCouchbaseDatabase) << "Failed to open bucket " << channel_access_str;
    }

    return db_access_;
}

DatabaseAccess* DatabaseManager::open(const QString &name, const QStringList &channel_access) {
    db_access_ = new DatabaseAccess();
    db_access_->name_ = name;
    db_access_->channel_access_ = channel_access;

    auto userDir = createUserDirectory(name);
    if (userDir.isEmpty()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: failed to create database directory.";
        return nullptr;
    }

    for (const auto& bucket : channel_access) {
        auto db = std::make_unique<CouchbaseDatabase>(bucket.toStdString(), userDir.toStdString());
        db_access_->database_map_.push_back(std::move(db));

        if (db_access_->database_map_.back()->open()) {
            qCCritical(logCategoryCouchbaseDatabase) << "Opened bucket " << bucket;
        } else {
            qCCritical(logCategoryCouchbaseDatabase) << "Failed to open bucket " << bucket;
        }
    }

    return db_access_;
}

bool DatabaseAccess::close() {
    for (const auto& bucket : database_map_) {
        if (!bucket) {
            qCCritical(logCategoryCouchbaseDatabase) << "Failed to close bucket " << QString::fromStdString(bucket->getDatabaseName());
            return false;
        }
        bucket->stopReplicator();
        bucket->close();
    }

    return true;
}

bool DatabaseAccess::write(CouchbaseDocument *doc, const QString &bucket) {
    if (!bucket.isEmpty()) {
        auto bucketObj = getBucket(bucket);
        if (!bucketObj) {
            qCCritical(logCategoryCouchbaseDatabase) << "Error: failed write operation -- bucket not found in map";
            return false;
        }
        return bucketObj->save(doc);
    } else for (const auto& _bucket : database_map_) {
        std::vector<std::string> channels;
        for (const auto& channel : channel_access_) {
            channels.push_back(channel.toStdString());
        }
        doc->tagChannelField(channels);
        if (!_bucket->save(doc)) {
            qCCritical(logCategoryCouchbaseDatabase) << "Error: failed write operation -- bucket " << QString::fromStdString(_bucket->getDatabaseName());
        }
    }

    return true;
}

bool DatabaseAccess::write(CouchbaseDocument *doc, const QStringList &buckets) {
    bool ok = true;
    for (const auto& bucket : buckets) {
        if (!write(doc, bucket)) {
            ok = false;
        }
    }
    return ok;
}

bool DatabaseAccess::deleteDoc(const QString &id, const QString &bucket) {
    if (!bucket.isEmpty()) {
        auto bucketObj = getBucket(bucket);
        if (!bucketObj) {
            qCCritical(logCategoryCouchbaseDatabase) << "Error: a valid bucket must be provided";
            return false;
        }
        return bucketObj->deleteDoc(id.toStdString());
    }

    qCCritical(logCategoryCouchbaseDatabase) << "Error: a valid bucket must be provided";
    return false;
}

QString DatabaseAccess::getDocumentAsStr(const QString &id, const QString &bucket) {
    if (!bucket.isEmpty()) {
        auto bucketObj = getBucket(bucket);
        if (!bucketObj) {
            qCCritical(logCategoryCouchbaseDatabase) << "Error: a valid bucket must be provided";
            return QString();
        }
        return QString::fromStdString(bucketObj->getDocumentAsStr(id.toStdString()));
    }

    qCCritical(logCategoryCouchbaseDatabase) << "Error: a valid bucket must be provided";
    return QString();
}

QJsonObject DatabaseAccess::getDocumentAsJsonObj(const QString &id, const QString &bucket) {
    QString bucketName;
    if (bucket.isEmpty()) {
        bucketName = channel_access_.at(0);
    } else {
        bucketName = bucket;
    }

    auto bucketObj = getBucket(bucketName);
    if (!bucketObj) {
        qDebug() << "Error: a valid bucket must be provided";
        return QJsonObject();
    }

    return bucketObj->getDocumentAsJsonObj(id.toStdString());
}

QJsonObject DatabaseAccess::getDatabaseAsJsonObj(const QString &bucket) {
    if (!bucket.isEmpty()) {
        auto bucketObj = getBucket(bucket);
        if (!bucketObj) {
            qDebug() << "Error: a valid bucket must be provided";
            return QJsonObject();
        }
        return bucketObj->getDatabaseAsJsonObj();
    }

    QJsonObject combinedObj;
    for (const auto& _bucket : database_map_) {
        auto this_obj = _bucket->getDatabaseAsJsonObj();
        for (auto it = this_obj.constBegin(); it != this_obj.constEnd(); it++) {
            combinedObj.insert(it.key(), it.value());
        }
    }

    return combinedObj;
}

QString DatabaseAccess::getDatabaseName() {
    return name_;
}

QString DatabaseAccess::getDatabasePath() {
    return user_directory_;
}

QStringList DatabaseAccess::getAllDocumentKeys(const QString &bucket) {
    if (!bucket.isEmpty()) {
        auto bucketObj = getBucket(bucket);
        if (!bucketObj) {
            qDebug() << "Error: a valid bucket must be provided";
            return QStringList();
        }

        auto key_vector = bucketObj->getAllDocumentKeys();
        QStringList list;
        for (const auto key : key_vector) {
            list << QString::fromStdString(key);
        }
        return list;
    }

    qDebug() << "Error: a valid bucket must be provided";
    return QStringList();
}

bool DatabaseAccess::startReplicator(const QString &url, const QString &username, const QString &password, const QString &replicator_type,
                               std::function<void(cbl::Replicator rep, const CBLReplicatorStatus &status)> changeListener,
                               std::function<void(cbl::Replicator rep, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents)> documentListener,
                               bool continuous) {

    auto _url = url.toStdString();
    auto _username = username.toStdString();
    auto _password = password.toStdString();

    std::vector<std::string> channels;
    for (const auto& channel : channel_access_) {
        channels.push_back(channel.toStdString());
    }

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

    for (const auto& bucket : database_map_) {
        std::vector<std::string> single_DB_channel;
        single_DB_channel.push_back(bucket->getDatabaseName());
        if (!bucket->startReplicator(_url, _username, _password, single_DB_channel, _replicator_type, change_listener_callback, document_listener_callback, continuous)) {
            qDebug() << "Error: Failed to start replicator on bucket/channel " << QString::fromStdString(bucket->getDatabaseName());
        }
    }

    return true;
}

void DatabaseAccess::stopReplicator() {
    for (const auto& bucket : database_map_) {
        bucket->stopReplicator();
    }
}

QString DatabaseAccess::getReplicatorStatus(const QString &bucket) {
    QString bucketName;
    if (bucket.isEmpty()) {
        bucketName = channel_access_.at(0);
    } else {
        bucketName = bucket;
    }

    auto bucketObj = getBucket(bucketName);
    if (!bucketObj) {
        qDebug() << "Error: a valid bucket must be provided";
        return QString();
    }

    return QString::fromStdString(bucketObj->getReplicatorStatus());
}

int DatabaseAccess::getReplicatorError(const QString &bucket) {
    QString bucketName;
    if (bucket.isEmpty()) {
        bucketName = channel_access_.at(0);
    } else {
        bucketName = bucket;
    }

    auto bucketObj = getBucket(bucketName);
    if (!bucketObj) {
        qDebug() << "Error: a valid bucket must be provided";
        return -1;
    }

    return bucketObj->getReplicatorError();
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

CouchbaseDatabase* DatabaseAccess::getBucket(const QString &bucketName) {
    for (const auto& bucket : database_map_) {
        if (QString::fromStdString(bucket->getDatabaseName()) == bucketName) {
            return bucket.get();
        }
    }

    return nullptr;
}

QString DatabaseManager::createUserDirectory(const QString &name) {
    QDir applicationDir(QCoreApplication::applicationDirPath());
    #ifdef Q_OS_MACOS
        applicationDir.cdUp();
    #endif
    const QString databases_dir = applicationDir.filePath("databases");
    QDir().mkdir(databases_dir);

    QString userDir;
    if (applicationDir.cd("databases")) {
        userDir = applicationDir.filePath(name);
        QDir().mkdir(userDir);
        db_access_->user_directory_ = userDir;
    } else {
        return QString();
    }

    return userDir;
}
